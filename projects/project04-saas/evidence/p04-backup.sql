--
-- PostgreSQL database dump
--

\restrict T25OS8HwOXoE5FH38ZbeT8spK6CGHNJWSLroiUWd601qsYkTfR18PMiTIyWvDtS

-- Dumped from database version 18.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: p04; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA p04;


--
-- Name: fail_audit(); Type: FUNCTION; Schema: p04; Owner: -
--

CREATE FUNCTION p04.fail_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    BEGIN RAISE EXCEPTION 'audit unavailable'; END; $$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_events; Type: TABLE; Schema: p04; Owner: -
--

CREATE TABLE p04.audit_events (
    id bigint NOT NULL,
    tenant_id integer NOT NULL,
    actor_id integer NOT NULL,
    action text NOT NULL,
    target text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    before jsonb,
    after jsonb,
    request_id text DEFAULT ''::text NOT NULL
);


--
-- Name: audit_events_id_seq; Type: SEQUENCE; Schema: p04; Owner: -
--

CREATE SEQUENCE p04.audit_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_events_id_seq; Type: SEQUENCE OWNED BY; Schema: p04; Owner: -
--

ALTER SEQUENCE p04.audit_events_id_seq OWNED BY p04.audit_events.id;


--
-- Name: clients; Type: TABLE; Schema: p04; Owner: -
--

CREATE TABLE p04.clients (
    id integer NOT NULL,
    tenant_id integer NOT NULL,
    name text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    deleted_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: clients_id_seq; Type: SEQUENCE; Schema: p04; Owner: -
--

CREATE SEQUENCE p04.clients_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clients_id_seq; Type: SEQUENCE OWNED BY; Schema: p04; Owner: -
--

ALTER SEQUENCE p04.clients_id_seq OWNED BY p04.clients.id;


--
-- Name: followups; Type: TABLE; Schema: p04; Owner: -
--

CREATE TABLE p04.followups (
    id integer NOT NULL,
    tenant_id integer NOT NULL,
    client_id integer NOT NULL,
    author_id integer NOT NULL,
    summary text NOT NULL,
    next_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: followups_id_seq; Type: SEQUENCE; Schema: p04; Owner: -
--

CREATE SEQUENCE p04.followups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: followups_id_seq; Type: SEQUENCE OWNED BY; Schema: p04; Owner: -
--

ALTER SEQUENCE p04.followups_id_seq OWNED BY p04.followups.id;


--
-- Name: invitations; Type: TABLE; Schema: p04; Owner: -
--

CREATE TABLE p04.invitations (
    id integer NOT NULL,
    tenant_id integer NOT NULL,
    email text NOT NULL,
    role text NOT NULL,
    token_hash text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    accepted_at timestamp with time zone,
    CONSTRAINT invitations_role_check CHECK ((role = ANY (ARRAY['admin'::text, 'member'::text, 'viewer'::text]))),
    CONSTRAINT invitations_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'accepted'::text, 'revoked'::text, 'expired'::text])))
);


--
-- Name: invitations_id_seq; Type: SEQUENCE; Schema: p04; Owner: -
--

CREATE SEQUENCE p04.invitations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invitations_id_seq; Type: SEQUENCE OWNED BY; Schema: p04; Owner: -
--

ALTER SEQUENCE p04.invitations_id_seq OWNED BY p04.invitations.id;


--
-- Name: job_dead_letter; Type: TABLE; Schema: p04; Owner: -
--

CREATE TABLE p04.job_dead_letter (
    job_id bigint NOT NULL,
    tenant_id integer NOT NULL,
    payload jsonb NOT NULL,
    last_error text NOT NULL,
    attempts integer NOT NULL,
    moved_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: job_notifications; Type: TABLE; Schema: p04; Owner: -
--

CREATE TABLE p04.job_notifications (
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    tenant_id integer NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: job_notifications_id_seq; Type: SEQUENCE; Schema: p04; Owner: -
--

CREATE SEQUENCE p04.job_notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: job_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: p04; Owner: -
--

ALTER SEQUENCE p04.job_notifications_id_seq OWNED BY p04.job_notifications.id;


--
-- Name: job_results; Type: TABLE; Schema: p04; Owner: -
--

CREATE TABLE p04.job_results (
    job_id bigint NOT NULL,
    result text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: jobs; Type: TABLE; Schema: p04; Owner: -
--

CREATE TABLE p04.jobs (
    id bigint NOT NULL,
    tenant_id integer NOT NULL,
    kind text NOT NULL,
    dedupe_key text NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    run_at timestamp with time zone DEFAULT now() NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    locked_at timestamp with time zone,
    last_error text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    tenant_seq bigint DEFAULT 0 NOT NULL,
    CONSTRAINT jobs_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'running'::text, 'done'::text, 'failed'::text, 'dead'::text])))
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: p04; Owner: -
--

CREATE SEQUENCE p04.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: p04; Owner: -
--

ALTER SEQUENCE p04.jobs_id_seq OWNED BY p04.jobs.id;


--
-- Name: memberships; Type: TABLE; Schema: p04; Owner: -
--

CREATE TABLE p04.memberships (
    tenant_id integer NOT NULL,
    user_id integer NOT NULL,
    role text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT memberships_role_check CHECK ((role = ANY (ARRAY['owner'::text, 'admin'::text, 'member'::text, 'viewer'::text])))
);


--
-- Name: reminders; Type: TABLE; Schema: p04; Owner: -
--

CREATE TABLE p04.reminders (
    id bigint NOT NULL,
    tenant_id integer NOT NULL,
    followup_id integer NOT NULL,
    due_at timestamp with time zone NOT NULL,
    status text DEFAULT 'scheduled'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT reminders_status_check CHECK ((status = ANY (ARRAY['scheduled'::text, 'sent'::text, 'cancelled'::text])))
);


--
-- Name: reminders_id_seq; Type: SEQUENCE; Schema: p04; Owner: -
--

CREATE SEQUENCE p04.reminders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reminders_id_seq; Type: SEQUENCE OWNED BY; Schema: p04; Owner: -
--

ALTER SEQUENCE p04.reminders_id_seq OWNED BY p04.reminders.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: p04; Owner: -
--

CREATE TABLE p04.schema_migrations (
    filename text NOT NULL,
    applied_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: p04; Owner: -
--

CREATE TABLE p04.sessions (
    token_hash text NOT NULL,
    user_id integer NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: tenants; Type: TABLE; Schema: p04; Owner: -
--

CREATE TABLE p04.tenants (
    id integer NOT NULL,
    name text NOT NULL,
    plan text DEFAULT 'free'::text NOT NULL,
    seat_limit integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    capacity_tier text DEFAULT 'normal'::text NOT NULL,
    CONSTRAINT tenants_capacity_tier_check CHECK ((capacity_tier = ANY (ARRAY['normal'::text, 'peak'::text, 'over'::text]))),
    CONSTRAINT tenants_plan_check CHECK ((plan = ANY (ARRAY['free'::text, 'team'::text]))),
    CONSTRAINT tenants_seat_limit_check CHECK ((seat_limit > 0))
);


--
-- Name: tenants_id_seq; Type: SEQUENCE; Schema: p04; Owner: -
--

CREATE SEQUENCE p04.tenants_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenants_id_seq; Type: SEQUENCE OWNED BY; Schema: p04; Owner: -
--

ALTER SEQUENCE p04.tenants_id_seq OWNED BY p04.tenants.id;


--
-- Name: users; Type: TABLE; Schema: p04; Owner: -
--

CREATE TABLE p04.users (
    id integer NOT NULL,
    email text NOT NULL,
    name text NOT NULL,
    password_hash text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: p04; Owner: -
--

CREATE SEQUENCE p04.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: p04; Owner: -
--

ALTER SEQUENCE p04.users_id_seq OWNED BY p04.users.id;


--
-- Name: worker_inbox; Type: TABLE; Schema: p04; Owner: -
--

CREATE TABLE p04.worker_inbox (
    consumer text NOT NULL,
    job_id bigint NOT NULL,
    processed_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: audit_events id; Type: DEFAULT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.audit_events ALTER COLUMN id SET DEFAULT nextval('p04.audit_events_id_seq'::regclass);


--
-- Name: clients id; Type: DEFAULT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.clients ALTER COLUMN id SET DEFAULT nextval('p04.clients_id_seq'::regclass);


--
-- Name: followups id; Type: DEFAULT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.followups ALTER COLUMN id SET DEFAULT nextval('p04.followups_id_seq'::regclass);


--
-- Name: invitations id; Type: DEFAULT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.invitations ALTER COLUMN id SET DEFAULT nextval('p04.invitations_id_seq'::regclass);


--
-- Name: job_notifications id; Type: DEFAULT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.job_notifications ALTER COLUMN id SET DEFAULT nextval('p04.job_notifications_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.jobs ALTER COLUMN id SET DEFAULT nextval('p04.jobs_id_seq'::regclass);


--
-- Name: reminders id; Type: DEFAULT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.reminders ALTER COLUMN id SET DEFAULT nextval('p04.reminders_id_seq'::regclass);


--
-- Name: tenants id; Type: DEFAULT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.tenants ALTER COLUMN id SET DEFAULT nextval('p04.tenants_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.users ALTER COLUMN id SET DEFAULT nextval('p04.users_id_seq'::regclass);


--
-- Data for Name: audit_events; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.audit_events (id, tenant_id, actor_id, action, target, metadata, created_at, before, after, request_id) FROM stdin;
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.clients (id, tenant_id, name, note, deleted_at, created_at) FROM stdin;
\.


--
-- Data for Name: followups; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.followups (id, tenant_id, client_id, author_id, summary, next_at, created_at) FROM stdin;
\.


--
-- Data for Name: invitations; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.invitations (id, tenant_id, email, role, token_hash, status, expires_at, created_by, created_at, accepted_at) FROM stdin;
\.


--
-- Data for Name: job_dead_letter; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.job_dead_letter (job_id, tenant_id, payload, last_error, attempts, moved_at) FROM stdin;
\.


--
-- Data for Name: job_notifications; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.job_notifications (id, job_id, tenant_id, message, created_at) FROM stdin;
\.


--
-- Data for Name: job_results; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.job_results (job_id, result, created_at) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.jobs (id, tenant_id, kind, dedupe_key, payload, run_at, status, attempts, locked_at, last_error, created_at, updated_at, priority, tenant_seq) FROM stdin;
\.


--
-- Data for Name: memberships; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.memberships (tenant_id, user_id, role, created_at) FROM stdin;
\.


--
-- Data for Name: reminders; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.reminders (id, tenant_id, followup_id, due_at, status, created_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.schema_migrations (filename, applied_at) FROM stdin;
001_init.sql	2026-11-07 22:06:42.187378+08
002_jobs.sql	2026-11-07 23:28:35.363998+08
003_full.sql	2026-11-09 08:51:24.429615+08
004_rbac_viewer.sql	2026-11-09 09:00:27.541922+08
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.sessions (token_hash, user_id, expires_at, created_at) FROM stdin;
\.


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.tenants (id, name, plan, seat_limit, created_at, capacity_tier) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.users (id, email, name, password_hash, created_at) FROM stdin;
\.


--
-- Data for Name: worker_inbox; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.worker_inbox (consumer, job_id, processed_at) FROM stdin;
\.


--
-- Name: audit_events_id_seq; Type: SEQUENCE SET; Schema: p04; Owner: -
--

SELECT pg_catalog.setval('p04.audit_events_id_seq', 1, false);


--
-- Name: clients_id_seq; Type: SEQUENCE SET; Schema: p04; Owner: -
--

SELECT pg_catalog.setval('p04.clients_id_seq', 1, false);


--
-- Name: followups_id_seq; Type: SEQUENCE SET; Schema: p04; Owner: -
--

SELECT pg_catalog.setval('p04.followups_id_seq', 1, false);


--
-- Name: invitations_id_seq; Type: SEQUENCE SET; Schema: p04; Owner: -
--

SELECT pg_catalog.setval('p04.invitations_id_seq', 1, false);


--
-- Name: job_notifications_id_seq; Type: SEQUENCE SET; Schema: p04; Owner: -
--

SELECT pg_catalog.setval('p04.job_notifications_id_seq', 1, false);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: p04; Owner: -
--

SELECT pg_catalog.setval('p04.jobs_id_seq', 1, false);


--
-- Name: reminders_id_seq; Type: SEQUENCE SET; Schema: p04; Owner: -
--

SELECT pg_catalog.setval('p04.reminders_id_seq', 1, false);


--
-- Name: tenants_id_seq; Type: SEQUENCE SET; Schema: p04; Owner: -
--

SELECT pg_catalog.setval('p04.tenants_id_seq', 1, false);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: p04; Owner: -
--

SELECT pg_catalog.setval('p04.users_id_seq', 1, false);


--
-- Name: audit_events audit_events_pkey; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.audit_events
    ADD CONSTRAINT audit_events_pkey PRIMARY KEY (id);


--
-- Name: clients clients_pkey; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.clients
    ADD CONSTRAINT clients_pkey PRIMARY KEY (id);


--
-- Name: followups followups_pkey; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.followups
    ADD CONSTRAINT followups_pkey PRIMARY KEY (id);


--
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: invitations invitations_token_hash_key; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.invitations
    ADD CONSTRAINT invitations_token_hash_key UNIQUE (token_hash);


--
-- Name: job_dead_letter job_dead_letter_pkey; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.job_dead_letter
    ADD CONSTRAINT job_dead_letter_pkey PRIMARY KEY (job_id);


--
-- Name: job_notifications job_notifications_pkey; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.job_notifications
    ADD CONSTRAINT job_notifications_pkey PRIMARY KEY (id);


--
-- Name: job_results job_results_pkey; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.job_results
    ADD CONSTRAINT job_results_pkey PRIMARY KEY (job_id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_tenant_id_dedupe_key_key; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.jobs
    ADD CONSTRAINT jobs_tenant_id_dedupe_key_key UNIQUE (tenant_id, dedupe_key);


--
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (tenant_id, user_id);


--
-- Name: reminders reminders_pkey; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.reminders
    ADD CONSTRAINT reminders_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (filename);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (token_hash);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: worker_inbox worker_inbox_pkey; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.worker_inbox
    ADD CONSTRAINT worker_inbox_pkey PRIMARY KEY (consumer, job_id);


--
-- Name: audit_tenant_id_idx; Type: INDEX; Schema: p04; Owner: -
--

CREATE INDEX audit_tenant_id_idx ON p04.audit_events USING btree (tenant_id, id DESC);


--
-- Name: clients_tenant_idx; Type: INDEX; Schema: p04; Owner: -
--

CREATE INDEX clients_tenant_idx ON p04.clients USING btree (tenant_id, id) WHERE (deleted_at IS NULL);


--
-- Name: invitations_pending_email; Type: INDEX; Schema: p04; Owner: -
--

CREATE UNIQUE INDEX invitations_pending_email ON p04.invitations USING btree (tenant_id, lower(email)) WHERE (status = 'pending'::text);


--
-- Name: jobs_due_idx; Type: INDEX; Schema: p04; Owner: -
--

CREATE INDEX jobs_due_idx ON p04.jobs USING btree (run_at, id) WHERE (status = 'pending'::text);


--
-- Name: jobs_fair_idx; Type: INDEX; Schema: p04; Owner: -
--

CREATE INDEX jobs_fair_idx ON p04.jobs USING btree (status, priority DESC, run_at, tenant_id, id);


--
-- Name: jobs_stale_idx; Type: INDEX; Schema: p04; Owner: -
--

CREATE INDEX jobs_stale_idx ON p04.jobs USING btree (locked_at) WHERE (status = 'running'::text);


--
-- Name: audit_events audit_events_actor_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.audit_events
    ADD CONSTRAINT audit_events_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES p04.users(id);


--
-- Name: audit_events audit_events_tenant_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.audit_events
    ADD CONSTRAINT audit_events_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES p04.tenants(id) ON DELETE CASCADE;


--
-- Name: clients clients_tenant_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.clients
    ADD CONSTRAINT clients_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES p04.tenants(id) ON DELETE CASCADE;


--
-- Name: followups followups_author_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.followups
    ADD CONSTRAINT followups_author_id_fkey FOREIGN KEY (author_id) REFERENCES p04.users(id);


--
-- Name: followups followups_client_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.followups
    ADD CONSTRAINT followups_client_id_fkey FOREIGN KEY (client_id) REFERENCES p04.clients(id) ON DELETE CASCADE;


--
-- Name: followups followups_tenant_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.followups
    ADD CONSTRAINT followups_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES p04.tenants(id) ON DELETE CASCADE;


--
-- Name: invitations invitations_created_by_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.invitations
    ADD CONSTRAINT invitations_created_by_fkey FOREIGN KEY (created_by) REFERENCES p04.users(id);


--
-- Name: invitations invitations_tenant_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.invitations
    ADD CONSTRAINT invitations_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES p04.tenants(id) ON DELETE CASCADE;


--
-- Name: job_notifications job_notifications_job_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.job_notifications
    ADD CONSTRAINT job_notifications_job_id_fkey FOREIGN KEY (job_id) REFERENCES p04.jobs(id) ON DELETE CASCADE;


--
-- Name: job_notifications job_notifications_tenant_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.job_notifications
    ADD CONSTRAINT job_notifications_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES p04.tenants(id) ON DELETE CASCADE;


--
-- Name: job_results job_results_job_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.job_results
    ADD CONSTRAINT job_results_job_id_fkey FOREIGN KEY (job_id) REFERENCES p04.jobs(id) ON DELETE CASCADE;


--
-- Name: memberships memberships_tenant_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.memberships
    ADD CONSTRAINT memberships_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES p04.tenants(id) ON DELETE CASCADE;


--
-- Name: memberships memberships_user_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.memberships
    ADD CONSTRAINT memberships_user_id_fkey FOREIGN KEY (user_id) REFERENCES p04.users(id) ON DELETE CASCADE;


--
-- Name: reminders reminders_followup_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.reminders
    ADD CONSTRAINT reminders_followup_id_fkey FOREIGN KEY (followup_id) REFERENCES p04.followups(id) ON DELETE CASCADE;


--
-- Name: reminders reminders_tenant_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.reminders
    ADD CONSTRAINT reminders_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES p04.tenants(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES p04.users(id) ON DELETE CASCADE;


--
-- Name: clients; Type: ROW SECURITY; Schema: p04; Owner: -
--

ALTER TABLE p04.clients ENABLE ROW LEVEL SECURITY;

--
-- Name: clients clients_tenant_isolation; Type: POLICY; Schema: p04; Owner: -
--

CREATE POLICY clients_tenant_isolation ON p04.clients USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::integer)) WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::integer));


--
-- Name: followups; Type: ROW SECURITY; Schema: p04; Owner: -
--

ALTER TABLE p04.followups ENABLE ROW LEVEL SECURITY;

--
-- Name: followups followups_tenant_isolation; Type: POLICY; Schema: p04; Owner: -
--

CREATE POLICY followups_tenant_isolation ON p04.followups USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::integer)) WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::integer));


--
-- Name: jobs; Type: ROW SECURITY; Schema: p04; Owner: -
--

ALTER TABLE p04.jobs ENABLE ROW LEVEL SECURITY;

--
-- Name: jobs jobs_tenant_isolation; Type: POLICY; Schema: p04; Owner: -
--

CREATE POLICY jobs_tenant_isolation ON p04.jobs USING ((tenant_id = (current_setting('app.tenant_id'::text, true))::integer)) WITH CHECK ((tenant_id = (current_setting('app.tenant_id'::text, true))::integer));


--
-- PostgreSQL database dump complete
--

\unrestrict T25OS8HwOXoE5FH38ZbeT8spK6CGHNJWSLroiUWd601qsYkTfR18PMiTIyWvDtS

