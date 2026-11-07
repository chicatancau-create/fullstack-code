CREATE SCHEMA IF NOT EXISTS p02;

CREATE TABLE IF NOT EXISTS p02.users (
  id serial PRIMARY KEY,
  email text NOT NULL UNIQUE,
  password_hash text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS p02.sessions (
  token text PRIMARY KEY,
  user_id integer NOT NULL REFERENCES p02.users(id) ON DELETE CASCADE,
  expires_at timestamptz NOT NULL
);

CREATE TABLE IF NOT EXISTS p02.workspaces (
  id serial PRIMARY KEY,
  slug text NOT NULL UNIQUE,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS p02.members (
  workspace_id integer NOT NULL REFERENCES p02.workspaces(id) ON DELETE CASCADE,
  user_id integer NOT NULL REFERENCES p02.users(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('owner', 'member')),
  PRIMARY KEY (workspace_id, user_id)
);

CREATE TABLE IF NOT EXISTS p02.tasks (
  id serial PRIMARY KEY,
  workspace_id integer NOT NULL REFERENCES p02.workspaces(id) ON DELETE CASCADE,
  title text NOT NULL CHECK (length(title) BETWEEN 1 AND 80),
  status text NOT NULL DEFAULT 'todo' CHECK (status IN ('todo', 'doing', 'done')),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (workspace_id, title)
);

CREATE INDEX IF NOT EXISTS p02_members_user_idx ON p02.members (user_id);
CREATE INDEX IF NOT EXISTS p02_tasks_workspace_status_idx ON p02.tasks (workspace_id, status);