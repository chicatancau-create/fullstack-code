--
-- PostgreSQL database dump
--

\restrict DUdPKhvEpxCPYchowVaLR3zLAkxd6ege4hAgBb379rzc8gjs74Q7fbaKSfUM0Ui

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
    created_at timestamp with time zone DEFAULT now() NOT NULL
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
    CONSTRAINT invitations_role_check CHECK ((role = ANY (ARRAY['admin'::text, 'member'::text]))),
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
-- Name: memberships; Type: TABLE; Schema: p04; Owner: -
--

CREATE TABLE p04.memberships (
    tenant_id integer NOT NULL,
    user_id integer NOT NULL,
    role text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT memberships_role_check CHECK ((role = ANY (ARRAY['owner'::text, 'admin'::text, 'member'::text])))
);


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

COPY p04.audit_events (id, tenant_id, actor_id, action, target, metadata, created_at) FROM stdin;
1	1	1	tenant.create	tenant:1	{"plan": "team"}	2026-11-07 23:27:00.440542+08
3	1	1	client.delete	client:1	{}	2026-11-07 23:27:00.454387+08
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.clients (id, tenant_id, name, note, deleted_at, created_at) FROM stdin;
1	1	待删客户		2026-11-07 23:27:00.454387+08	2026-11-07 23:27:00.444664+08
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
-- Data for Name: memberships; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.memberships (tenant_id, user_id, role, created_at) FROM stdin;
1	1	owner	2026-11-07 23:27:00.440542+08
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.schema_migrations (filename, applied_at) FROM stdin;
001_init.sql	2026-11-07 22:06:42.187378+08
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.sessions (token_hash, user_id, expires_at, created_at) FROM stdin;
1b3b4977ac30937e0a88a721450ec21625a0493614df45080a427a7147804d4c	1	2026-11-08 11:27:00.436+08	2026-11-07 23:27:00.43782+08
\.


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.tenants (id, name, plan, seat_limit, created_at) FROM stdin;
1	团队	team	5	2026-11-07 23:27:00.440542+08
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.users (id, email, name, password_hash, created_at) FROM stdin;
1	owner@example.com	测试用户	c1efd0797734aa81b4fc432c0991b44f:4714b53263dbf18639d889aaadd6e9e3d973aee1f41e25f63640ccd63a97a907920112a63364d2fefa217d82e24c9b2b3d0ab2ee2636c9fc3d9c132e77fed149	2026-11-07 23:27:00.405187+08
\.


--
-- Name: audit_events_id_seq; Type: SEQUENCE SET; Schema: p04; Owner: -
--

SELECT pg_catalog.setval('p04.audit_events_id_seq', 3, true);


--
-- Name: clients_id_seq; Type: SEQUENCE SET; Schema: p04; Owner: -
--

SELECT pg_catalog.setval('p04.clients_id_seq', 1, true);


--
-- Name: followups_id_seq; Type: SEQUENCE SET; Schema: p04; Owner: -
--

SELECT pg_catalog.setval('p04.followups_id_seq', 1, false);


--
-- Name: invitations_id_seq; Type: SEQUENCE SET; Schema: p04; Owner: -
--

SELECT pg_catalog.setval('p04.invitations_id_seq', 1, false);


--
-- Name: tenants_id_seq; Type: SEQUENCE SET; Schema: p04; Owner: -
--

SELECT pg_catalog.setval('p04.tenants_id_seq', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: p04; Owner: -
--

SELECT pg_catalog.setval('p04.users_id_seq', 1, true);


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
-- Name: memberships memberships_pkey; Type: CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.memberships
    ADD CONSTRAINT memberships_pkey PRIMARY KEY (tenant_id, user_id);


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
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES p04.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict DUdPKhvEpxCPYchowVaLR3zLAkxd6ege4hAgBb379rzc8gjs74Q7fbaKSfUM0Ui

