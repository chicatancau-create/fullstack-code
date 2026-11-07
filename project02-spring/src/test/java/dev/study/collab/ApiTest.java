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

import static org.assertj.core.api.Assertions.assertThat;
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
