CREATE TABLE IF NOT EXISTS p02.task_events (
  id bigserial PRIMARY KEY,
  task_id integer NOT NULL REFERENCES p02.tasks(id) ON DELETE CASCADE,
  workspace_id integer NOT NULL REFERENCES p02.workspaces(id) ON DELETE CASCADE,
  actor_id integer NOT NULL REFERENCES p02.users(id),
  from_status text NOT NULL,
  to_status text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (from_status IN ('todo', 'doing', 'done')),
  CHECK (to_status IN ('todo', 'doing', 'done'))
);

CREATE INDEX IF NOT EXISTS p02_task_events_task_idx ON p02.task_events (task_id, id);
CREATE INDEX IF NOT EXISTS p02_task_events_workspace_idx ON p02.task_events (workspace_id, id);

INSERT INTO p02.task_events (task_id, workspace_id, actor_id, from_status, to_status)
SELECT DISTINCT ON (t.id) t.id, t.workspace_id, m.user_id, t.status, t.status
FROM p02.tasks t
JOIN p02.members m ON m.workspace_id = t.workspace_id AND m.role = 'owner'
WHERE NOT EXISTS (SELECT 1 FROM p02.task_events e WHERE e.task_id = t.id)
ORDER BY t.id, m.user_id;
