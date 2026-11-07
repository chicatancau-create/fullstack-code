--
-- PostgreSQL database dump
--

\restrict wuzgPHth34cfESWP5sQzE5TlXajKb9TZbcs02RV8vJCcTHSGJnPpbWV4q9I1Ko1

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
    CONSTRAINT jobs_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'running'::text, 'done'::text, 'failed'::text])))
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
-- Name: jobs id; Type: DEFAULT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.jobs ALTER COLUMN id SET DEFAULT nextval('p04.jobs_id_seq'::regclass);


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
1	1	1	tenant.create	tenant:1	{"plan": "team"}	2026-11-08 01:43:32.269681+08
3	1	1	client.delete	client:1	{}	2026-11-08 01:43:32.286131+08
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.clients (id, tenant_id, name, note, deleted_at, created_at) FROM stdin;
1	1	待删客户		2026-11-08 01:43:32.286131+08	2026-11-08 01:43:32.274932+08
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
-- Data for Name: job_results; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.job_results (job_id, result, created_at) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.jobs (id, tenant_id, kind, dedupe_key, payload, run_at, status, attempts, locked_at, last_error, created_at, updated_at) FROM stdin;
1	99	followup.reminder	alert-1	{}	2026-11-08 01:43:19.123926+08	pending	0	\N	\N	2026-11-08 01:43:19.123926+08	2026-11-08 01:43:19.123926+08
2	99	followup.reminder	alert-2	{}	2026-11-08 01:43:19.125918+08	pending	0	\N	\N	2026-11-08 01:43:19.125918+08	2026-11-08 01:43:19.125918+08
3	99	followup.reminder	alert-3	{}	2026-11-08 01:43:19.127219+08	pending	0	\N	\N	2026-11-08 01:43:19.127219+08	2026-11-08 01:43:19.127219+08
4	99	followup.reminder	alert-4	{}	2026-11-08 01:43:19.127861+08	pending	0	\N	\N	2026-11-08 01:43:19.127861+08	2026-11-08 01:43:19.127861+08
5	99	followup.reminder	alert-5	{}	2026-11-08 01:43:19.128695+08	pending	0	\N	\N	2026-11-08 01:43:19.128695+08	2026-11-08 01:43:19.128695+08
6	99	followup.reminder	alert-6	{}	2026-11-08 01:43:19.12924+08	pending	0	\N	\N	2026-11-08 01:43:19.12924+08	2026-11-08 01:43:19.12924+08
7	99	followup.reminder	alert-7	{}	2026-11-08 01:43:19.129826+08	pending	0	\N	\N	2026-11-08 01:43:19.129826+08	2026-11-08 01:43:19.129826+08
8	99	followup.reminder	alert-8	{}	2026-11-08 01:43:19.130728+08	pending	0	\N	\N	2026-11-08 01:43:19.130728+08	2026-11-08 01:43:19.130728+08
9	99	followup.reminder	alert-9	{}	2026-11-08 01:43:19.131193+08	pending	0	\N	\N	2026-11-08 01:43:19.131193+08	2026-11-08 01:43:19.131193+08
10	99	followup.reminder	alert-10	{}	2026-11-08 01:43:19.131529+08	pending	0	\N	\N	2026-11-08 01:43:19.131529+08	2026-11-08 01:43:19.131529+08
11	99	followup.reminder	alert-11	{}	2026-11-08 01:43:19.131873+08	pending	0	\N	\N	2026-11-08 01:43:19.131873+08	2026-11-08 01:43:19.131873+08
12	99	followup.reminder	alert-12	{}	2026-11-08 01:43:19.132184+08	pending	0	\N	\N	2026-11-08 01:43:19.132184+08	2026-11-08 01:43:19.132184+08
13	99	followup.reminder	alert-13	{}	2026-11-08 01:43:19.132504+08	pending	0	\N	\N	2026-11-08 01:43:19.132504+08	2026-11-08 01:43:19.132504+08
14	99	followup.reminder	alert-14	{}	2026-11-08 01:43:19.133568+08	pending	0	\N	\N	2026-11-08 01:43:19.133568+08	2026-11-08 01:43:19.133568+08
15	99	followup.reminder	alert-15	{}	2026-11-08 01:43:19.134066+08	pending	0	\N	\N	2026-11-08 01:43:19.134066+08	2026-11-08 01:43:19.134066+08
16	99	followup.reminder	alert-16	{}	2026-11-08 01:43:19.134398+08	pending	0	\N	\N	2026-11-08 01:43:19.134398+08	2026-11-08 01:43:19.134398+08
17	99	followup.reminder	alert-17	{}	2026-11-08 01:43:19.134673+08	pending	0	\N	\N	2026-11-08 01:43:19.134673+08	2026-11-08 01:43:19.134673+08
18	99	followup.reminder	alert-18	{}	2026-11-08 01:43:19.135121+08	pending	0	\N	\N	2026-11-08 01:43:19.135121+08	2026-11-08 01:43:19.135121+08
19	99	followup.reminder	alert-19	{}	2026-11-08 01:43:19.135595+08	pending	0	\N	\N	2026-11-08 01:43:19.135595+08	2026-11-08 01:43:19.135595+08
20	99	followup.reminder	alert-20	{}	2026-11-08 01:43:19.135981+08	pending	0	\N	\N	2026-11-08 01:43:19.135981+08	2026-11-08 01:43:19.135981+08
21	99	followup.reminder	alert-21	{}	2026-11-08 01:43:19.136646+08	pending	0	\N	\N	2026-11-08 01:43:19.136646+08	2026-11-08 01:43:19.136646+08
22	99	followup.reminder	alert-22	{}	2026-11-08 01:43:19.137136+08	pending	0	\N	\N	2026-11-08 01:43:19.137136+08	2026-11-08 01:43:19.137136+08
23	99	followup.reminder	alert-23	{}	2026-11-08 01:43:19.137675+08	pending	0	\N	\N	2026-11-08 01:43:19.137675+08	2026-11-08 01:43:19.137675+08
24	99	followup.reminder	alert-24	{}	2026-11-08 01:43:19.138193+08	pending	0	\N	\N	2026-11-08 01:43:19.138193+08	2026-11-08 01:43:19.138193+08
25	99	followup.reminder	alert-25	{}	2026-11-08 01:43:19.138629+08	pending	0	\N	\N	2026-11-08 01:43:19.138629+08	2026-11-08 01:43:19.138629+08
26	99	followup.reminder	alert-26	{}	2026-11-08 01:43:19.139015+08	pending	0	\N	\N	2026-11-08 01:43:19.139015+08	2026-11-08 01:43:19.139015+08
27	99	followup.reminder	alert-27	{}	2026-11-08 01:43:19.139364+08	pending	0	\N	\N	2026-11-08 01:43:19.139364+08	2026-11-08 01:43:19.139364+08
28	99	followup.reminder	alert-28	{}	2026-11-08 01:43:19.13978+08	pending	0	\N	\N	2026-11-08 01:43:19.13978+08	2026-11-08 01:43:19.13978+08
29	99	followup.reminder	alert-29	{}	2026-11-08 01:43:19.14036+08	pending	0	\N	\N	2026-11-08 01:43:19.14036+08	2026-11-08 01:43:19.14036+08
30	99	followup.reminder	alert-30	{}	2026-11-08 01:43:19.14087+08	pending	0	\N	\N	2026-11-08 01:43:19.14087+08	2026-11-08 01:43:19.14087+08
31	99	followup.reminder	alert-31	{}	2026-11-08 01:43:19.141409+08	pending	0	\N	\N	2026-11-08 01:43:19.141409+08	2026-11-08 01:43:19.141409+08
32	99	followup.reminder	alert-32	{}	2026-11-08 01:43:19.141791+08	pending	0	\N	\N	2026-11-08 01:43:19.141791+08	2026-11-08 01:43:19.141791+08
33	99	followup.reminder	alert-33	{}	2026-11-08 01:43:19.142141+08	pending	0	\N	\N	2026-11-08 01:43:19.142141+08	2026-11-08 01:43:19.142141+08
34	99	followup.reminder	alert-34	{}	2026-11-08 01:43:19.142416+08	pending	0	\N	\N	2026-11-08 01:43:19.142416+08	2026-11-08 01:43:19.142416+08
35	99	followup.reminder	alert-35	{}	2026-11-08 01:43:19.142674+08	pending	0	\N	\N	2026-11-08 01:43:19.142674+08	2026-11-08 01:43:19.142674+08
36	99	followup.reminder	alert-36	{}	2026-11-08 01:43:19.143132+08	pending	0	\N	\N	2026-11-08 01:43:19.143132+08	2026-11-08 01:43:19.143132+08
37	99	followup.reminder	alert-37	{}	2026-11-08 01:43:19.143817+08	pending	0	\N	\N	2026-11-08 01:43:19.143817+08	2026-11-08 01:43:19.143817+08
38	99	followup.reminder	alert-38	{}	2026-11-08 01:43:19.144283+08	pending	0	\N	\N	2026-11-08 01:43:19.144283+08	2026-11-08 01:43:19.144283+08
39	99	followup.reminder	alert-39	{}	2026-11-08 01:43:19.144614+08	pending	0	\N	\N	2026-11-08 01:43:19.144614+08	2026-11-08 01:43:19.144614+08
40	99	followup.reminder	alert-40	{}	2026-11-08 01:43:19.145039+08	pending	0	\N	\N	2026-11-08 01:43:19.145039+08	2026-11-08 01:43:19.145039+08
41	99	followup.reminder	alert-41	{}	2026-11-08 01:43:19.145393+08	pending	0	\N	\N	2026-11-08 01:43:19.145393+08	2026-11-08 01:43:19.145393+08
42	99	followup.reminder	alert-42	{}	2026-11-08 01:43:19.145683+08	pending	0	\N	\N	2026-11-08 01:43:19.145683+08	2026-11-08 01:43:19.145683+08
43	99	followup.reminder	alert-43	{}	2026-11-08 01:43:19.145955+08	pending	0	\N	\N	2026-11-08 01:43:19.145955+08	2026-11-08 01:43:19.145955+08
44	99	followup.reminder	alert-44	{}	2026-11-08 01:43:19.146245+08	pending	0	\N	\N	2026-11-08 01:43:19.146245+08	2026-11-08 01:43:19.146245+08
45	99	followup.reminder	alert-45	{}	2026-11-08 01:43:19.146749+08	pending	0	\N	\N	2026-11-08 01:43:19.146749+08	2026-11-08 01:43:19.146749+08
46	99	followup.reminder	alert-46	{}	2026-11-08 01:43:19.147298+08	pending	0	\N	\N	2026-11-08 01:43:19.147298+08	2026-11-08 01:43:19.147298+08
47	99	followup.reminder	alert-47	{}	2026-11-08 01:43:19.147706+08	pending	0	\N	\N	2026-11-08 01:43:19.147706+08	2026-11-08 01:43:19.147706+08
48	99	followup.reminder	alert-48	{}	2026-11-08 01:43:19.148063+08	pending	0	\N	\N	2026-11-08 01:43:19.148063+08	2026-11-08 01:43:19.148063+08
49	99	followup.reminder	alert-49	{}	2026-11-08 01:43:19.148362+08	pending	0	\N	\N	2026-11-08 01:43:19.148362+08	2026-11-08 01:43:19.148362+08
50	99	followup.reminder	alert-50	{}	2026-11-08 01:43:19.148639+08	pending	0	\N	\N	2026-11-08 01:43:19.148639+08	2026-11-08 01:43:19.148639+08
51	99	followup.reminder	alert-51	{}	2026-11-08 01:43:19.148911+08	pending	0	\N	\N	2026-11-08 01:43:19.148911+08	2026-11-08 01:43:19.148911+08
52	99	followup.reminder	alert-52	{}	2026-11-08 01:43:19.149196+08	pending	0	\N	\N	2026-11-08 01:43:19.149196+08	2026-11-08 01:43:19.149196+08
53	99	followup.reminder	alert-53	{}	2026-11-08 01:43:19.149581+08	pending	0	\N	\N	2026-11-08 01:43:19.149581+08	2026-11-08 01:43:19.149581+08
54	99	followup.reminder	alert-54	{}	2026-11-08 01:43:19.150642+08	pending	0	\N	\N	2026-11-08 01:43:19.150642+08	2026-11-08 01:43:19.150642+08
55	99	followup.reminder	alert-55	{}	2026-11-08 01:43:19.151009+08	pending	0	\N	\N	2026-11-08 01:43:19.151009+08	2026-11-08 01:43:19.151009+08
56	99	followup.reminder	alert-56	{}	2026-11-08 01:43:19.151302+08	pending	0	\N	\N	2026-11-08 01:43:19.151302+08	2026-11-08 01:43:19.151302+08
57	99	followup.reminder	alert-57	{}	2026-11-08 01:43:19.151751+08	pending	0	\N	\N	2026-11-08 01:43:19.151751+08	2026-11-08 01:43:19.151751+08
58	99	followup.reminder	alert-58	{}	2026-11-08 01:43:19.152145+08	pending	0	\N	\N	2026-11-08 01:43:19.152145+08	2026-11-08 01:43:19.152145+08
59	99	followup.reminder	alert-59	{}	2026-11-08 01:43:19.152967+08	pending	0	\N	\N	2026-11-08 01:43:19.152967+08	2026-11-08 01:43:19.152967+08
60	99	followup.reminder	alert-60	{}	2026-11-08 01:43:19.153875+08	pending	0	\N	\N	2026-11-08 01:43:19.153875+08	2026-11-08 01:43:19.153875+08
\.


--
-- Data for Name: memberships; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.memberships (tenant_id, user_id, role, created_at) FROM stdin;
1	1	owner	2026-11-08 01:43:32.269681+08
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.schema_migrations (filename, applied_at) FROM stdin;
001_init.sql	2026-11-07 22:06:42.187378+08
002_jobs.sql	2026-11-07 23:28:35.363998+08
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.sessions (token_hash, user_id, expires_at, created_at) FROM stdin;
91cd809938f0d69cdffdef4dd04b2c4ebb0f063bcc914551668d5554b1d3a7b2	1	2026-11-08 13:43:32.266+08	2026-11-08 01:43:32.267228+08
\.


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.tenants (id, name, plan, seat_limit, created_at) FROM stdin;
1	团队	team	5	2026-11-08 01:43:32.269681+08
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.users (id, email, name, password_hash, created_at) FROM stdin;
1	owner@example.com	测试用户	50e136b3f93efb115e1e5a89bf26e82d:062af33c625c13fbe8e8f8b7b62483b300724ded06318ac277be3977e2b62dba262f1c77bc6e98295239e569d40e3c4a39358a33d01c5707f93ef1c63a1562ae	2026-11-08 01:43:32.235172+08
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
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: p04; Owner: -
--

SELECT pg_catalog.setval('p04.jobs_id_seq', 60, true);


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
-- Name: jobs_due_idx; Type: INDEX; Schema: p04; Owner: -
--

CREATE INDEX jobs_due_idx ON p04.jobs USING btree (run_at, id) WHERE (status = 'pending'::text);


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
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: p04; Owner: -
--

ALTER TABLE ONLY p04.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES p04.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict wuzgPHth34cfESWP5sQzE5TlXajKb9TZbcs02RV8vJCcTHSGJnPpbWV4q9I1Ko1

