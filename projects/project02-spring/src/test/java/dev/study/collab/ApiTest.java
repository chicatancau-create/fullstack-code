package dev.study.collab;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.Map;
import java.util.List;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
class ApiTest {
    @Autowired
    MockMvc mvc;
    @Autowired
    JdbcTemplate jdbc;
    @Autowired
    ObjectMapper json;

    @BeforeEach
    void clean() {
        jdbc.update("DELETE FROM tasks");
        jdbc.update("DELETE FROM memberships");
        jdbc.update("DELETE FROM sessions");
        jdbc.update("DELETE FROM workspaces");
        jdbc.update("DELETE FROM users");
    }

    private MvcResult postJson(String path, String token, Object body) throws Exception {
        var request = post(path).contentType(MediaType.APPLICATION_JSON).content(json.writeValueAsString(body));
        if (token != null) request.header("Authorization", "Bearer " + token);
        return mvc.perform(request).andReturn();
    }

    private String register(String email) throws Exception {
        MvcResult result = postJson("/auth/register", null, Map.of("email", email, "password", "correct-horse-1"));
        assertThat(result.getResponse().getStatus()).isEqualTo(201);
        return email;
    }

    private String login(String email) throws Exception {
        MvcResult result = postJson("/auth/login", null, Map.of("email", email, "password", "correct-horse-1"));
        assertThat(result.getResponse().getStatus()).isEqualTo(200);
        return json.readTree(result.getResponse().getContentAsString()).get("token").asText();
    }

    private JsonNode body(MvcResult result) throws Exception {
        return json.readTree(result.getResponse().getContentAsString());
    }

    @Test
    void healthIsPublicAndOtherRoutesRequireToken() throws Exception {
        mvc.perform(get("/health")).andExpect(status().isOk());
        mvc.perform(get("/workspaces")).andExpect(status().isUnauthorized());
        mvc.perform(get("/workspaces").header("Authorization", "Bearer not-a-token")).andExpect(status().isUnauthorized());
    }

    @Test
    void registerLoginAndDuplicateRules() throws Exception {
        register("owner@example.com");
        MvcResult duplicate = postJson("/auth/register", null, Map.of("email", "owner@example.com", "password", "correct-horse-1"));
        assertThat(duplicate.getResponse().getStatus()).isEqualTo(409);
        MvcResult weak = postJson("/auth/register", null, Map.of("email", "weak@example.com", "password", "short"));
        assertThat(weak.getResponse().getStatus()).isEqualTo(400);
        MvcResult wrong = postJson("/auth/login", null, Map.of("email", "owner@example.com", "password", "wrong-pass-1"));
        assertThat(wrong.getResponse().getStatus()).isEqualTo(401);
        MvcResult malformed = mvc.perform(post("/auth/login").contentType(MediaType.APPLICATION_JSON).content("{bad"))
                .andReturn();
        assertThat(malformed.getResponse().getStatus()).isEqualTo(400);
    }

    @Test
    void ownerCreatesWorkspaceAndMemberIsolationHolds() throws Exception {
        register("owner@example.com");
        register("bob@example.com");
        register("eve@example.com");
        String owner = login("owner@example.com");
        String bob = login("bob@example.com");
        String eve = login("eve@example.com");

        MvcResult created = postJson("/workspaces", owner, Map.of("name", "研发团队"));
        assertThat(created.getResponse().getStatus()).isEqualTo(201);
        long workspaceId = body(created).get("id").asLong();

        MvcResult add = postJson("/workspaces/" + workspaceId + "/members", owner, Map.of("email", "bob@example.com"));
        assertThat(add.getResponse().getStatus()).isEqualTo(201);
        MvcResult addAgain = postJson("/workspaces/" + workspaceId + "/members", owner, Map.of("email", "bob@example.com"));
        assertThat(addAgain.getResponse().getStatus()).isEqualTo(409);
        MvcResult memberAttempt = postJson("/workspaces/" + workspaceId + "/members", bob, Map.of("email", "eve@example.com"));
        assertThat(memberAttempt.getResponse().getStatus()).isEqualTo(403);

        MvcResult tasks = postJson("/workspaces/" + workspaceId + "/tasks", bob, Map.of("title", "写迁移文档"));
        assertThat(tasks.getResponse().getStatus()).isEqualTo(201);
        MvcResult duplicateTask = postJson("/workspaces/" + workspaceId + "/tasks", bob, Map.of("title", "写迁移文档"));
        assertThat(duplicateTask.getResponse().getStatus()).isEqualTo(409);

        MvcResult outsider = mvc.perform(get("/workspaces/" + workspaceId + "/tasks").header("Authorization", "Bearer " + eve))
                .andReturn();
        assertThat(outsider.getResponse().getStatus()).isEqualTo(404);

        MvcResult list = mvc.perform(get("/workspaces/" + workspaceId + "/tasks").header("Authorization", "Bearer " + bob)).andReturn();
        assertThat(body(list).get("tasks")).hasSize(1);
    }

    @Test
    void invitationFlowWritesAuditAndEnforcesEmail() throws Exception {
        register("owner@example.com");
        register("bob@example.com");
        register("alice@example.com");
        String owner = login("owner@example.com");
        String bob = login("bob@example.com");
        String alice = login("alice@example.com");
        long workspaceId = body(postJson("/workspaces", owner, Map.of("name", "Invite Team"))).get("id").asLong();

        MvcResult invite = postJson("/workspaces/" + workspaceId + "/invitations", owner, Map.of("email", "bob@example.com", "role", "member"));
        assertThat(invite.getResponse().getStatus()).isEqualTo(201);
        String inviteToken = body(invite).get("token").asText();
        MvcResult wrongEmail = postJson("/invitations/accept", alice, Map.of("token", inviteToken));
        assertThat(wrongEmail.getResponse().getStatus()).isEqualTo(403);
        MvcResult accepted = postJson("/invitations/accept", bob, Map.of("token", inviteToken));
        assertThat(accepted.getResponse().getStatus()).isEqualTo(200);
        assertThat(body(accepted).get("idempotent").asBoolean()).isFalse();
        MvcResult again = postJson("/invitations/accept", bob, Map.of("token", inviteToken));
        assertThat(again.getResponse().getStatus()).isEqualTo(200);
        assertThat(body(again).get("idempotent").asBoolean()).isTrue();
        MvcResult duplicate = postJson("/workspaces/" + workspaceId + "/invitations", owner, Map.of("email", "bob@example.com", "role", "member"));
        assertThat(duplicate.getResponse().getStatus()).isEqualTo(409);

        MvcResult audit = mvc.perform(get("/workspaces/" + workspaceId + "/audit").header("Authorization", "Bearer " + owner)).andReturn();
        assertThat(audit.getResponse().getStatus()).isEqualTo(200);
        List<String> actions = body(audit).get("events").findValuesAsText("action");
        assertThat(actions).contains("workspace.create", "invitation.create", "invitation.accept");
        MvcResult memberAudit = mvc.perform(get("/workspaces/" + workspaceId + "/audit").header("Authorization", "Bearer " + bob)).andReturn();
        assertThat(memberAudit.getResponse().getStatus()).isEqualTo(403);
    }

    @Test
    void lastOwnerIsProtectedAndConcurrentRemovalKeepsOneOwner() throws Exception {
        register("owner@example.com");
        register("bob@example.com");
        String owner = login("owner@example.com");
        String bob = login("bob@example.com");
        long workspaceId = body(postJson("/workspaces", owner, Map.of("name", "Owner Team"))).get("id").asLong();
        long ownerId = jdbc.queryForObject("SELECT id FROM users WHERE email = 'owner@example.com'", Long.class);
        MvcResult selfRemove = mvc.perform(delete("/workspaces/" + workspaceId + "/members/" + ownerId).header("Authorization", "Bearer " + owner)).andReturn();
        assertThat(selfRemove.getResponse().getStatus()).isEqualTo(409);

        String inviteToken = body(postJson("/workspaces/" + workspaceId + "/invitations", owner, Map.of("email", "bob@example.com", "role", "owner"))).get("token").asText();
        assertThat(postJson("/invitations/accept", bob, Map.of("token", inviteToken)).getResponse().getStatus()).isEqualTo(200);
        long bobId = jdbc.queryForObject("SELECT id FROM users WHERE email = 'bob@example.com'", Long.class);

        ExecutorService pool = Executors.newFixedThreadPool(2);
        try {
            Callable<Integer> ownerDeletesBob = () -> mvc.perform(delete("/workspaces/" + workspaceId + "/members/" + bobId)
                    .header("Authorization", "Bearer " + owner)).andReturn().getResponse().getStatus();
            Callable<Integer> bobDeletesOwner = () -> mvc.perform(delete("/workspaces/" + workspaceId + "/members/" + ownerId)
                    .header("Authorization", "Bearer " + bob)).andReturn().getResponse().getStatus();
            Future<Integer> first = pool.submit(ownerDeletesBob);
            Future<Integer> second = pool.submit(bobDeletesOwner);
            List<Integer> statuses = List.of(first.get(), second.get());
            assertThat(statuses).contains(204);
            assertThat(statuses).containsAnyOf(404, 409);
        } finally {
            pool.shutdownNow();
        }
        Integer owners = jdbc.queryForObject("SELECT COUNT(*) FROM memberships WHERE workspace_id = ? AND role = 'owner'", Integer.class, workspaceId);
        assertThat(owners).isEqualTo(1);
    }

    @Test
    void actuatorRequiresAuthenticationExceptHealth() throws Exception {
        mvc.perform(get("/actuator/health")).andExpect(status().isOk());
        mvc.perform(get("/actuator/metrics")).andExpect(status().isUnauthorized());
        register("owner@example.com");
        String token = login("owner@example.com");
        mvc.perform(get("/actuator/metrics").header("Authorization", "Bearer " + token)).andExpect(status().isOk());
    }

    @Test
    void logoutInvalidatesSession() throws Exception {
        register("owner@example.com");
        String token = login("owner@example.com");
        MvcResult logout = postJson("/auth/logout", token, Map.of());
        assertThat(logout.getResponse().getStatus()).isEqualTo(200);
        mvc.perform(get("/workspaces").header("Authorization", "Bearer " + token)).andExpect(status().isUnauthorized());
    }
}
