package dev.study.collab;

import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

@Service
public class MembershipService {
    private final JdbcTemplate jdbc;
    private final TransactionTemplate tx;

    public MembershipService(JdbcTemplate jdbc, PlatformTransactionManager transactionManager) {
        this.jdbc = jdbc;
        this.tx = new TransactionTemplate(transactionManager);
    }

    public void removeMember(long workspaceId, long actorId, long targetId) {
        tx.executeWithoutResult(status -> removeInTransaction(workspaceId, actorId, targetId));
    }

    private void removeInTransaction(long workspaceId, long actorId, long targetId) {
        List<Long> workspace = jdbc.queryForList("SELECT id FROM workspaces WHERE id = ? FOR UPDATE", Long.class, workspaceId);
        if (workspace.isEmpty()) throw new ApiException(HttpStatus.NOT_FOUND, "not_found");
        String actorRole = jdbc.query("SELECT role FROM memberships WHERE workspace_id = ? AND user_id = ?",
                rs -> rs.next() ? rs.getString(1) : null, workspaceId, actorId);
        if (actorRole == null) throw new ApiException(HttpStatus.NOT_FOUND, "not_found");
        if (!"owner".equals(actorRole)) throw new ApiException(HttpStatus.FORBIDDEN, "forbidden");
        String targetRole = jdbc.query("SELECT role FROM memberships WHERE workspace_id = ? AND user_id = ?",
                rs -> rs.next() ? rs.getString(1) : null, workspaceId, targetId);
        if (targetRole == null) throw new ApiException(HttpStatus.NOT_FOUND, "not_found");
        if ("owner".equals(targetRole)) {
            List<Long> owners = jdbc.queryForList(
                    "SELECT user_id FROM memberships WHERE workspace_id = ? AND role = 'owner' FOR UPDATE", Long.class, workspaceId);
            if (owners.size() <= 1) throw new ApiException(HttpStatus.CONFLICT, "last_owner");
        }
        jdbc.update("DELETE FROM memberships WHERE workspace_id = ? AND user_id = ?", workspaceId, targetId);
        jdbc.update("INSERT INTO audit_events (workspace_id, actor_id, action, target, metadata) VALUES (?, ?, 'member.remove', ?, CAST('{}' AS JSON))",
                workspaceId, actorId, "user:" + targetId);
    }
}
