package dev.study.collab;

import jakarta.servlet.http.HttpServletRequest;
import java.security.SecureRandom;
import java.time.Instant;
import java.util.HexFormat;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping
public class ApiController {
    private final JdbcTemplate jdbc;
    private final BCryptPasswordEncoder passwords = new BCryptPasswordEncoder();
    private final SecureRandom random = new SecureRandom();

    public ApiController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public record Register(String email, String password) {}
    public record Login(String email, String password) {}
    public record Workspace(String name) {}
    public record Member(String email) {}
    public record Task(String title) {}

    private static final String EMAIL = "^[^\\s@]{1,64}@[^\\s@]{1,64}\\.[^\\s@]{2,}$";

    @GetMapping("/health")
    public Map<String, String> health() {
        return Map.of("status", "ok");
    }

    @PostMapping("/auth/register")
    public ResponseEntity<Map<String, Object>> register(@RequestBody Register body) {
        if (body.email() == null || !body.email().matches(EMAIL) || body.password() == null
                || body.password().length() < 10 || body.password().length() > 200) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "invalid_credentials");
        }
        String email = body.email().toLowerCase();
        jdbc.update("INSERT INTO users (email, password_hash) VALUES (?, ?)", email, passwords.encode(body.password()));
        Long id = jdbc.queryForObject("SELECT id FROM users WHERE email = ?", Long.class, email);
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("id", id, "email", email));
    }

    @PostMapping("/auth/login")
    public Map<String, Object> login(@RequestBody Login body) {
        if (body.email() == null || body.password() == null) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "bad_login");
        }
        List<Map<String, Object>> users = jdbc.queryForList("SELECT id, password_hash FROM users WHERE email = ?", body.email().toLowerCase());
        if (users.isEmpty() || !passwords.matches(body.password(), (String) users.getFirst().get("password_hash"))) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "bad_login");
        }
        Long userId = ((Number) users.getFirst().get("id")).longValue();
        byte[] raw = new byte[32];
        random.nextBytes(raw);
        String token = HexFormat.of().formatHex(raw);
        jdbc.update("INSERT INTO sessions (token_hash, user_id, expires_at) VALUES (?, ?, ?)",
                AuthFilter.sha256(token), userId, java.sql.Timestamp.from(Instant.now().plusSeconds(12 * 3600)));
        return Map.of("token", token);
    }

    @PostMapping("/auth/logout")
    public Map<String, String> logout(HttpServletRequest request) {
        String header = request.getHeader("Authorization");
        jdbc.update("DELETE FROM sessions WHERE token_hash = ?", AuthFilter.sha256(header.substring(7)));
        return Map.of("status", "logged_out");
    }

    private long userId(HttpServletRequest request) {
        return (Long) request.getAttribute(AuthFilter.USER_ID);
    }

    private void requireMember(long workspaceId, long userId) {
        Integer count = jdbc.queryForObject("SELECT COUNT(*) FROM memberships WHERE workspace_id = ? AND user_id = ?",
                Integer.class, workspaceId, userId);
        if (count == null || count == 0) {
            throw new ApiException(HttpStatus.NOT_FOUND, "not_found");
        }
    }

    @PostMapping("/workspaces")
    @Transactional
    public ResponseEntity<Map<String, Object>> createWorkspace(HttpServletRequest request, @RequestBody Workspace body) {
        if (body.name() == null || body.name().trim().length() < 2 || body.name().trim().length() > 120) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "invalid_name");
        }
        String slug = UUID.randomUUID().toString();
        jdbc.update("INSERT INTO workspaces (name, slug) VALUES (?, ?)", body.name().trim(), slug);
        Long id = jdbc.queryForObject("SELECT id FROM workspaces WHERE slug = ?", Long.class, slug);
        jdbc.update("INSERT INTO memberships (workspace_id, user_id, role) VALUES (?, ?, 'owner')", id, userId(request));
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("id", id, "name", body.name().trim(), "role", "owner"));
    }

    @GetMapping("/workspaces")
    public Map<String, Object> listWorkspaces(HttpServletRequest request) {
        List<Map<String, Object>> rows = jdbc.queryForList(
                "SELECT w.id, w.name, m.role FROM memberships m JOIN workspaces w ON w.id = m.workspace_id WHERE m.user_id = ? ORDER BY w.id",
                userId(request));
        return Map.of("workspaces", rows);
    }

    @PostMapping("/workspaces/{id}/members")
    public ResponseEntity<Map<String, Object>> addMember(HttpServletRequest request, @PathVariable long id, @RequestBody Member body) {
        String role = jdbc.query(
                "SELECT role FROM memberships WHERE workspace_id = ? AND user_id = ?",
                rs -> rs.next() ? rs.getString(1) : null, id, userId(request));
        if (role == null) throw new ApiException(HttpStatus.NOT_FOUND, "not_found");
        if (!"owner".equals(role)) throw new ApiException(HttpStatus.FORBIDDEN, "forbidden");
        List<Long> target = jdbc.queryForList("SELECT id FROM users WHERE email = ?", Long.class, body.email().toLowerCase());
        if (target.isEmpty()) throw new ApiException(HttpStatus.NOT_FOUND, "user_not_found");
        try {
            jdbc.update("INSERT INTO memberships (workspace_id, user_id, role) VALUES (?, ?, 'member')", id, target.getFirst());
        } catch (DuplicateKeyException error) {
            throw new ApiException(HttpStatus.CONFLICT, "already_member");
        }
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("workspace_id", id, "user_id", target.getFirst(), "role", "member"));
    }

    @GetMapping("/workspaces/{id}/members")
    public Map<String, Object> members(HttpServletRequest request, @PathVariable long id) {
        requireMember(id, userId(request));
        List<Map<String, Object>> rows = jdbc.queryForList(
                "SELECT u.id, u.email, m.role FROM memberships m JOIN users u ON u.id = m.user_id WHERE m.workspace_id = ? ORDER BY u.id", id);
        return Map.of("members", rows);
    }

    @PostMapping("/workspaces/{id}/tasks")
    public ResponseEntity<Map<String, Object>> createTask(HttpServletRequest request, @PathVariable long id, @RequestBody Task body) {
        requireMember(id, userId(request));
        if (body.title() == null || body.title().trim().isEmpty() || body.title().trim().length() > 200) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "invalid_title");
        }
        try {
            jdbc.update("INSERT INTO tasks (workspace_id, title) VALUES (?, ?)", id, body.title().trim());
        } catch (DuplicateKeyException error) {
            throw new ApiException(HttpStatus.CONFLICT, "duplicate_title");
        }
        Map<String, Object> task = jdbc.queryForMap("SELECT id, title, status FROM tasks WHERE workspace_id = ? AND title = ?", id, body.title().trim());
        return ResponseEntity.status(HttpStatus.CREATED).body(Map.of("id", ((Number) task.get("id")).longValue(), "title", task.get("title"), "status", task.get("status")));
    }

    @GetMapping("/workspaces/{id}/tasks")
    public Map<String, Object> tasks(HttpServletRequest request, @PathVariable long id) {
        requireMember(id, userId(request));
        List<Map<String, Object>> rows = jdbc.queryForList(
                "SELECT id, title, status FROM tasks WHERE workspace_id = ? ORDER BY id", id);
        return Map.of("tasks", rows);
    }
}
