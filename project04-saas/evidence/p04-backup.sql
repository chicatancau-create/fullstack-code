--
-- PostgreSQL database dump
--

\restrict GqbQeUQYMenGLm7tG3WN4vfDI11eYxDTjp83vPbJJdBDGtf2k2eq8Z0RbLGe2ld

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
1	1	1	tenant.create	tenant:1	{"plan": "team"}	2026-11-07 23:29:18.145394+08
3	1	1	client.delete	client:1	{}	2026-11-07 23:29:18.157617+08
\.


--
-- Data for Name: clients; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.clients (id, tenant_id, name, note, deleted_at, created_at) FROM stdin;
1	1	待删客户		2026-11-07 23:29:18.157617+08	2026-11-07 23:29:18.149192+08
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
1	reminder:1	2026-11-07 23:28:52.602706+08
2	reminder:2	2026-11-07 23:28:52.606051+08
3	reminder:3	2026-11-07 23:28:52.608111+08
4	reminder:4	2026-11-07 23:28:52.609684+08
5	reminder:5	2026-11-07 23:28:52.611151+08
6	reminder:6	2026-11-07 23:28:52.675595+08
7	reminder:7	2026-11-07 23:28:52.680699+08
8	reminder:8	2026-11-07 23:28:52.682035+08
9	reminder:9	2026-11-07 23:28:52.683619+08
10	reminder:10	2026-11-07 23:28:52.684625+08
11	reminder:11	2026-11-07 23:28:52.702917+08
12	reminder:12	2026-11-07 23:28:52.706726+08
13	reminder:13	2026-11-07 23:28:52.707944+08
14	reminder:14	2026-11-07 23:28:52.709128+08
15	reminder:15	2026-11-07 23:28:52.710503+08
16	reminder:16	2026-11-07 23:28:52.726604+08
17	reminder:17	2026-11-07 23:28:52.72904+08
18	reminder:18	2026-11-07 23:28:52.730652+08
19	reminder:19	2026-11-07 23:28:52.731891+08
20	reminder:20	2026-11-07 23:28:52.732968+08
21	reminder:21	2026-11-07 23:28:52.734441+08
23	reminder:23	2026-11-07 23:28:52.734551+08
22	reminder:22	2026-11-07 23:28:52.734495+08
24	reminder:24	2026-11-07 23:28:52.734533+08
25	reminder:25	2026-11-07 23:28:52.735669+08
26	reminder:26	2026-11-07 23:28:52.735834+08
27	reminder:27	2026-11-07 23:28:52.736119+08
28	reminder:28	2026-11-07 23:28:52.73642+08
29	reminder:29	2026-11-07 23:28:52.737142+08
30	reminder:30	2026-11-07 23:28:52.737193+08
31	reminder:31	2026-11-07 23:28:52.737398+08
32	reminder:32	2026-11-07 23:28:52.73769+08
33	reminder:33	2026-11-07 23:28:52.738153+08
34	reminder:34	2026-11-07 23:28:52.738329+08
35	reminder:35	2026-11-07 23:28:52.738532+08
36	reminder:36	2026-11-07 23:28:52.738933+08
37	reminder:37	2026-11-07 23:28:52.739313+08
38	reminder:38	2026-11-07 23:28:52.739348+08
39	reminder:39	2026-11-07 23:28:52.739746+08
40	reminder:40	2026-11-07 23:28:52.740033+08
41	reminder:41	2026-11-07 23:28:52.741301+08
42	reminder:42	2026-11-07 23:28:52.741341+08
44	reminder:44	2026-11-07 23:28:52.741359+08
43	reminder:43	2026-11-07 23:28:52.741326+08
45	reminder:45	2026-11-07 23:28:52.742281+08
47	reminder:47	2026-11-07 23:28:52.742316+08
46	reminder:46	2026-11-07 23:28:52.742345+08
48	reminder:48	2026-11-07 23:28:52.742808+08
49	reminder:49	2026-11-07 23:28:52.74462+08
50	reminder:50	2026-11-07 23:28:52.744652+08
51	reminder:51	2026-11-07 23:28:52.744716+08
52	reminder:52	2026-11-07 23:28:52.744798+08
54	reminder:54	2026-11-07 23:28:52.746193+08
53	reminder:53	2026-11-07 23:28:52.746086+08
55	reminder:55	2026-11-07 23:28:52.746335+08
56	reminder:56	2026-11-07 23:28:52.74666+08
57	reminder:57	2026-11-07 23:28:52.747384+08
58	reminder:58	2026-11-07 23:28:52.747567+08
59	reminder:59	2026-11-07 23:28:52.747596+08
60	reminder:60	2026-11-07 23:28:52.747761+08
62	reminder:62	2026-11-07 23:28:52.748897+08
64	reminder:64	2026-11-07 23:28:52.748907+08
61	reminder:61	2026-11-07 23:28:52.748873+08
63	reminder:63	2026-11-07 23:28:52.748926+08
65	reminder:65	2026-11-07 23:28:52.750145+08
66	reminder:66	2026-11-07 23:28:52.75026+08
67	reminder:67	2026-11-07 23:28:52.75033+08
68	reminder:68	2026-11-07 23:28:52.750695+08
69	reminder:69	2026-11-07 23:28:52.751301+08
70	reminder:70	2026-11-07 23:28:52.751213+08
71	reminder:71	2026-11-07 23:28:52.751327+08
72	reminder:72	2026-11-07 23:28:52.751668+08
74	reminder:74	2026-11-07 23:28:52.752359+08
73	reminder:73	2026-11-07 23:28:52.752226+08
75	reminder:75	2026-11-07 23:28:52.752619+08
76	reminder:76	2026-11-07 23:28:52.752745+08
77	reminder:77	2026-11-07 23:28:52.753675+08
79	reminder:79	2026-11-07 23:28:52.753951+08
78	reminder:78	2026-11-07 23:28:52.753833+08
80	reminder:80	2026-11-07 23:28:52.753993+08
81	reminder:81	2026-11-07 23:28:52.755008+08
82	reminder:82	2026-11-07 23:28:52.755034+08
83	reminder:83	2026-11-07 23:28:52.755067+08
84	reminder:84	2026-11-07 23:28:52.755048+08
85	reminder:85	2026-11-07 23:28:52.757013+08
87	reminder:87	2026-11-07 23:28:52.757111+08
86	reminder:86	2026-11-07 23:28:52.757056+08
88	reminder:88	2026-11-07 23:28:52.757414+08
89	reminder:89	2026-11-07 23:28:52.758051+08
90	reminder:90	2026-11-07 23:28:52.758142+08
91	reminder:91	2026-11-07 23:28:52.758165+08
92	reminder:92	2026-11-07 23:28:52.758353+08
93	reminder:93	2026-11-07 23:28:52.759166+08
94	reminder:94	2026-11-07 23:28:52.759415+08
95	reminder:95	2026-11-07 23:28:52.759509+08
96	reminder:96	2026-11-07 23:28:52.759776+08
97	reminder:97	2026-11-07 23:28:52.760034+08
98	reminder:98	2026-11-07 23:28:52.760265+08
99	reminder:99	2026-11-07 23:28:52.760601+08
100	reminder:100	2026-11-07 23:28:52.76063+08
101	reminder:101	2026-11-07 23:28:52.761627+08
103	reminder:103	2026-11-07 23:28:52.761661+08
102	reminder:102	2026-11-07 23:28:52.761648+08
104	reminder:104	2026-11-07 23:28:52.761677+08
105	reminder:105	2026-11-07 23:28:52.763327+08
106	reminder:106	2026-11-07 23:28:52.763378+08
107	reminder:107	2026-11-07 23:28:52.763409+08
108	reminder:108	2026-11-07 23:28:52.76349+08
110	reminder:110	2026-11-07 23:28:52.764622+08
109	reminder:109	2026-11-07 23:28:52.764578+08
111	reminder:111	2026-11-07 23:28:52.764671+08
112	reminder:112	2026-11-07 23:28:52.764907+08
113	reminder:113	2026-11-07 23:28:52.765846+08
114	reminder:114	2026-11-07 23:28:52.766052+08
115	reminder:115	2026-11-07 23:28:52.766024+08
116	reminder:116	2026-11-07 23:28:52.766081+08
117	reminder:117	2026-11-07 23:28:52.76688+08
118	reminder:118	2026-11-07 23:28:52.766925+08
120	reminder:120	2026-11-07 23:28:52.767303+08
119	reminder:119	2026-11-07 23:28:52.767232+08
121	reminder:121	2026-11-07 23:28:52.768518+08
123	reminder:123	2026-11-07 23:28:52.768569+08
122	reminder:122	2026-11-07 23:28:52.768538+08
124	reminder:124	2026-11-07 23:28:52.768559+08
125	reminder:125	2026-11-07 23:28:52.769995+08
126	reminder:126	2026-11-07 23:28:52.770166+08
128	reminder:128	2026-11-07 23:28:52.770382+08
127	reminder:127	2026-11-07 23:28:52.770231+08
129	reminder:129	2026-11-07 23:28:52.771348+08
130	reminder:130	2026-11-07 23:28:52.77142+08
131	reminder:131	2026-11-07 23:28:52.771447+08
132	reminder:132	2026-11-07 23:28:52.771487+08
133	reminder:133	2026-11-07 23:28:52.772053+08
134	reminder:134	2026-11-07 23:28:52.77211+08
135	reminder:135	2026-11-07 23:28:52.772158+08
136	reminder:136	2026-11-07 23:28:52.772289+08
137	reminder:137	2026-11-07 23:28:52.773665+08
144	reminder:144	2026-11-07 23:28:52.776523+08
148	reminder:148	2026-11-07 23:28:52.777692+08
152	reminder:152	2026-11-07 23:28:52.778502+08
156	reminder:156	2026-11-07 23:28:52.779961+08
159	reminder:159	2026-11-07 23:28:52.780949+08
162	reminder:162	2026-11-07 23:28:52.782018+08
168	reminder:168	2026-11-07 23:28:52.783996+08
173	reminder:173	2026-11-07 23:28:52.78587+08
177	reminder:177	2026-11-07 23:28:52.787059+08
180	reminder:180	2026-11-07 23:28:52.787902+08
181	reminder:181	2026-11-07 23:28:52.788847+08
185	reminder:185	2026-11-07 23:28:52.790318+08
189	reminder:189	2026-11-07 23:28:52.791106+08
193	reminder:193	2026-11-07 23:28:52.791877+08
197	reminder:197	2026-11-07 23:28:52.793561+08
205	reminder:none	2026-11-07 23:29:03.330503+08
138	reminder:138	2026-11-07 23:28:52.773875+08
142	reminder:142	2026-11-07 23:28:52.7765+08
146	reminder:146	2026-11-07 23:28:52.777578+08
150	reminder:150	2026-11-07 23:28:52.778349+08
154	reminder:154	2026-11-07 23:28:52.779236+08
158	reminder:158	2026-11-07 23:28:52.780665+08
164	reminder:164	2026-11-07 23:28:52.78203+08
166	reminder:166	2026-11-07 23:28:52.783638+08
171	reminder:171	2026-11-07 23:28:52.784923+08
175	reminder:175	2026-11-07 23:28:52.786211+08
178	reminder:178	2026-11-07 23:28:52.787145+08
184	reminder:184	2026-11-07 23:28:52.788882+08
188	reminder:188	2026-11-07 23:28:52.790633+08
191	reminder:191	2026-11-07 23:28:52.791354+08
195	reminder:195	2026-11-07 23:28:52.792246+08
198	reminder:198	2026-11-07 23:28:52.793971+08
140	reminder:140	2026-11-07 23:28:52.774117+08
141	reminder:141	2026-11-07 23:28:52.77646+08
145	reminder:145	2026-11-07 23:28:52.77755+08
149	reminder:149	2026-11-07 23:28:52.778287+08
153	reminder:153	2026-11-07 23:28:52.779202+08
157	reminder:157	2026-11-07 23:28:52.780416+08
163	reminder:163	2026-11-07 23:28:52.782048+08
167	reminder:167	2026-11-07 23:28:52.783785+08
170	reminder:170	2026-11-07 23:28:52.784958+08
174	reminder:174	2026-11-07 23:28:52.785947+08
179	reminder:179	2026-11-07 23:28:52.787165+08
182	reminder:182	2026-11-07 23:28:52.78887+08
186	reminder:186	2026-11-07 23:28:52.790494+08
190	reminder:190	2026-11-07 23:28:52.791255+08
194	reminder:194	2026-11-07 23:28:52.791964+08
199	reminder:199	2026-11-07 23:28:52.794+08
139	reminder:139	2026-11-07 23:28:52.773935+08
143	reminder:143	2026-11-07 23:28:52.776493+08
147	reminder:147	2026-11-07 23:28:52.777668+08
151	reminder:151	2026-11-07 23:28:52.778543+08
155	reminder:155	2026-11-07 23:28:52.779484+08
160	reminder:160	2026-11-07 23:28:52.781079+08
161	reminder:161	2026-11-07 23:28:52.781988+08
165	reminder:165	2026-11-07 23:28:52.783571+08
169	reminder:169	2026-11-07 23:28:52.784864+08
172	reminder:172	2026-11-07 23:28:52.785922+08
176	reminder:176	2026-11-07 23:28:52.786966+08
183	reminder:183	2026-11-07 23:28:52.788897+08
187	reminder:187	2026-11-07 23:28:52.790467+08
192	reminder:192	2026-11-07 23:28:52.791398+08
196	reminder:196	2026-11-07 23:28:52.792325+08
200	reminder:200	2026-11-07 23:28:52.794091+08
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.jobs (id, tenant_id, kind, dedupe_key, payload, run_at, status, attempts, locked_at, last_error, created_at, updated_at) FROM stdin;
3	1	followup.reminder	job-3	{"clientId": 3}	2026-11-07 23:28:52.52768+08	done	1	\N	\N	2026-11-07 23:28:52.52768+08	2026-11-07 23:28:52.608111+08
4	1	followup.reminder	job-4	{"clientId": 4}	2026-11-07 23:28:52.528202+08	done	1	\N	\N	2026-11-07 23:28:52.528202+08	2026-11-07 23:28:52.609684+08
6	1	followup.reminder	job-6	{"clientId": 6}	2026-11-07 23:28:52.528905+08	done	1	\N	\N	2026-11-07 23:28:52.528905+08	2026-11-07 23:28:52.675595+08
7	1	followup.reminder	job-7	{"clientId": 7}	2026-11-07 23:28:52.529823+08	done	1	\N	\N	2026-11-07 23:28:52.529823+08	2026-11-07 23:28:52.680699+08
8	1	followup.reminder	job-8	{"clientId": 8}	2026-11-07 23:28:52.530261+08	done	1	\N	\N	2026-11-07 23:28:52.530261+08	2026-11-07 23:28:52.682035+08
9	1	followup.reminder	job-9	{"clientId": 9}	2026-11-07 23:28:52.530652+08	done	1	\N	\N	2026-11-07 23:28:52.530652+08	2026-11-07 23:28:52.683619+08
10	1	followup.reminder	job-10	{"clientId": 10}	2026-11-07 23:28:52.531052+08	done	1	\N	\N	2026-11-07 23:28:52.531052+08	2026-11-07 23:28:52.684625+08
11	1	followup.reminder	job-11	{"clientId": 11}	2026-11-07 23:28:52.531431+08	done	1	\N	\N	2026-11-07 23:28:52.531431+08	2026-11-07 23:28:52.702917+08
12	1	followup.reminder	job-12	{"clientId": 12}	2026-11-07 23:28:52.531709+08	done	1	\N	\N	2026-11-07 23:28:52.531709+08	2026-11-07 23:28:52.706726+08
13	1	followup.reminder	job-13	{"clientId": 13}	2026-11-07 23:28:52.531966+08	done	1	\N	\N	2026-11-07 23:28:52.531966+08	2026-11-07 23:28:52.707944+08
14	1	followup.reminder	job-14	{"clientId": 14}	2026-11-07 23:28:52.532438+08	done	1	\N	\N	2026-11-07 23:28:52.532438+08	2026-11-07 23:28:52.709128+08
15	1	followup.reminder	job-15	{"clientId": 15}	2026-11-07 23:28:52.532847+08	done	1	\N	\N	2026-11-07 23:28:52.532847+08	2026-11-07 23:28:52.710503+08
16	1	followup.reminder	job-16	{"clientId": 16}	2026-11-07 23:28:52.533266+08	done	1	\N	\N	2026-11-07 23:28:52.533266+08	2026-11-07 23:28:52.726604+08
17	1	followup.reminder	job-17	{"clientId": 17}	2026-11-07 23:28:52.533648+08	done	1	\N	\N	2026-11-07 23:28:52.533648+08	2026-11-07 23:28:52.72904+08
18	1	followup.reminder	job-18	{"clientId": 18}	2026-11-07 23:28:52.533956+08	done	1	\N	\N	2026-11-07 23:28:52.533956+08	2026-11-07 23:28:52.730652+08
19	1	followup.reminder	job-19	{"clientId": 19}	2026-11-07 23:28:52.534225+08	done	1	\N	\N	2026-11-07 23:28:52.534225+08	2026-11-07 23:28:52.731891+08
20	1	followup.reminder	job-20	{"clientId": 20}	2026-11-07 23:28:52.534526+08	done	1	\N	\N	2026-11-07 23:28:52.534526+08	2026-11-07 23:28:52.732968+08
25	1	followup.reminder	job-25	{"clientId": 25}	2026-11-07 23:28:52.536888+08	done	1	\N	\N	2026-11-07 23:28:52.536888+08	2026-11-07 23:28:52.735669+08
26	1	followup.reminder	job-26	{"clientId": 26}	2026-11-07 23:28:52.537397+08	done	1	\N	\N	2026-11-07 23:28:52.537397+08	2026-11-07 23:28:52.735834+08
27	1	followup.reminder	job-27	{"clientId": 27}	2026-11-07 23:28:52.537787+08	done	1	\N	\N	2026-11-07 23:28:52.537787+08	2026-11-07 23:28:52.736119+08
29	1	followup.reminder	job-29	{"clientId": 29}	2026-11-07 23:28:52.538347+08	done	1	\N	\N	2026-11-07 23:28:52.538347+08	2026-11-07 23:28:52.737142+08
30	1	followup.reminder	job-30	{"clientId": 30}	2026-11-07 23:28:52.538603+08	done	1	\N	\N	2026-11-07 23:28:52.538603+08	2026-11-07 23:28:52.737193+08
31	1	followup.reminder	job-31	{"clientId": 31}	2026-11-07 23:28:52.538816+08	done	1	\N	\N	2026-11-07 23:28:52.538816+08	2026-11-07 23:28:52.737398+08
32	1	followup.reminder	job-32	{"clientId": 32}	2026-11-07 23:28:52.539033+08	done	1	\N	\N	2026-11-07 23:28:52.539033+08	2026-11-07 23:28:52.73769+08
33	1	followup.reminder	job-33	{"clientId": 33}	2026-11-07 23:28:52.539577+08	done	1	\N	\N	2026-11-07 23:28:52.539577+08	2026-11-07 23:28:52.738153+08
34	1	followup.reminder	job-34	{"clientId": 34}	2026-11-07 23:28:52.540251+08	done	1	\N	\N	2026-11-07 23:28:52.540251+08	2026-11-07 23:28:52.738329+08
35	1	followup.reminder	job-35	{"clientId": 35}	2026-11-07 23:28:52.540706+08	done	1	\N	\N	2026-11-07 23:28:52.540706+08	2026-11-07 23:28:52.738532+08
36	1	followup.reminder	job-36	{"clientId": 36}	2026-11-07 23:28:52.541003+08	done	1	\N	\N	2026-11-07 23:28:52.541003+08	2026-11-07 23:28:52.738933+08
37	1	followup.reminder	job-37	{"clientId": 37}	2026-11-07 23:28:52.541257+08	done	1	\N	\N	2026-11-07 23:28:52.541257+08	2026-11-07 23:28:52.739313+08
38	1	followup.reminder	job-38	{"clientId": 38}	2026-11-07 23:28:52.541491+08	done	1	\N	\N	2026-11-07 23:28:52.541491+08	2026-11-07 23:28:52.739348+08
39	1	followup.reminder	job-39	{"clientId": 39}	2026-11-07 23:28:52.541716+08	done	1	\N	\N	2026-11-07 23:28:52.541716+08	2026-11-07 23:28:52.739746+08
40	1	followup.reminder	job-40	{"clientId": 40}	2026-11-07 23:28:52.541963+08	done	1	\N	\N	2026-11-07 23:28:52.541963+08	2026-11-07 23:28:52.740033+08
41	1	followup.reminder	job-41	{"clientId": 41}	2026-11-07 23:28:52.542265+08	done	1	\N	\N	2026-11-07 23:28:52.542265+08	2026-11-07 23:28:52.741301+08
45	1	followup.reminder	job-45	{"clientId": 45}	2026-11-07 23:28:52.543901+08	done	1	\N	\N	2026-11-07 23:28:52.543901+08	2026-11-07 23:28:52.742281+08
47	1	followup.reminder	job-47	{"clientId": 47}	2026-11-07 23:28:52.544651+08	done	1	\N	\N	2026-11-07 23:28:52.544651+08	2026-11-07 23:28:52.742316+08
46	1	followup.reminder	job-46	{"clientId": 46}	2026-11-07 23:28:52.54431+08	done	1	\N	\N	2026-11-07 23:28:52.54431+08	2026-11-07 23:28:52.742345+08
48	1	followup.reminder	job-48	{"clientId": 48}	2026-11-07 23:28:52.545023+08	done	1	\N	\N	2026-11-07 23:28:52.545023+08	2026-11-07 23:28:52.742808+08
49	1	followup.reminder	job-49	{"clientId": 49}	2026-11-07 23:28:52.545276+08	done	1	\N	\N	2026-11-07 23:28:52.545276+08	2026-11-07 23:28:52.74462+08
50	1	followup.reminder	job-50	{"clientId": 50}	2026-11-07 23:28:52.545565+08	done	1	\N	\N	2026-11-07 23:28:52.545565+08	2026-11-07 23:28:52.744652+08
51	1	followup.reminder	job-51	{"clientId": 51}	2026-11-07 23:28:52.546357+08	done	1	\N	\N	2026-11-07 23:28:52.546357+08	2026-11-07 23:28:52.744716+08
52	1	followup.reminder	job-52	{"clientId": 52}	2026-11-07 23:28:52.546739+08	done	1	\N	\N	2026-11-07 23:28:52.546739+08	2026-11-07 23:28:52.744798+08
54	1	followup.reminder	job-54	{"clientId": 54}	2026-11-07 23:28:52.547268+08	done	1	\N	\N	2026-11-07 23:28:52.547268+08	2026-11-07 23:28:52.746193+08
55	1	followup.reminder	job-55	{"clientId": 55}	2026-11-07 23:28:52.547709+08	done	1	\N	\N	2026-11-07 23:28:52.547709+08	2026-11-07 23:28:52.746335+08
53	1	followup.reminder	job-53	{"clientId": 53}	2026-11-07 23:28:52.547009+08	done	1	\N	\N	2026-11-07 23:28:52.547009+08	2026-11-07 23:28:52.746086+08
63	1	followup.reminder	job-63	{"clientId": 63}	2026-11-07 23:28:52.551048+08	done	1	\N	\N	2026-11-07 23:28:52.551048+08	2026-11-07 23:28:52.748926+08
65	1	followup.reminder	job-65	{"clientId": 65}	2026-11-07 23:28:52.551782+08	done	1	\N	\N	2026-11-07 23:28:52.551782+08	2026-11-07 23:28:52.750145+08
66	1	followup.reminder	job-66	{"clientId": 66}	2026-11-07 23:28:52.552169+08	done	1	\N	\N	2026-11-07 23:28:52.552169+08	2026-11-07 23:28:52.75026+08
67	1	followup.reminder	job-67	{"clientId": 67}	2026-11-07 23:28:52.552477+08	done	1	\N	\N	2026-11-07 23:28:52.552477+08	2026-11-07 23:28:52.75033+08
68	1	followup.reminder	job-68	{"clientId": 68}	2026-11-07 23:28:52.552921+08	done	1	\N	\N	2026-11-07 23:28:52.552921+08	2026-11-07 23:28:52.750695+08
69	1	followup.reminder	job-69	{"clientId": 69}	2026-11-07 23:28:52.553329+08	done	1	\N	\N	2026-11-07 23:28:52.553329+08	2026-11-07 23:28:52.751301+08
70	1	followup.reminder	job-70	{"clientId": 70}	2026-11-07 23:28:52.553703+08	done	1	\N	\N	2026-11-07 23:28:52.553703+08	2026-11-07 23:28:52.751213+08
71	1	followup.reminder	job-71	{"clientId": 71}	2026-11-07 23:28:52.554093+08	done	1	\N	\N	2026-11-07 23:28:52.554093+08	2026-11-07 23:28:52.751327+08
72	1	followup.reminder	job-72	{"clientId": 72}	2026-11-07 23:28:52.55446+08	done	1	\N	\N	2026-11-07 23:28:52.55446+08	2026-11-07 23:28:52.751668+08
74	1	followup.reminder	job-74	{"clientId": 74}	2026-11-07 23:28:52.555179+08	done	1	\N	\N	2026-11-07 23:28:52.555179+08	2026-11-07 23:28:52.752359+08
75	1	followup.reminder	job-75	{"clientId": 75}	2026-11-07 23:28:52.555469+08	done	1	\N	\N	2026-11-07 23:28:52.555469+08	2026-11-07 23:28:52.752619+08
73	1	followup.reminder	job-73	{"clientId": 73}	2026-11-07 23:28:52.554848+08	done	1	\N	\N	2026-11-07 23:28:52.554848+08	2026-11-07 23:28:52.752226+08
77	1	followup.reminder	job-77	{"clientId": 77}	2026-11-07 23:28:52.556393+08	done	1	\N	\N	2026-11-07 23:28:52.556393+08	2026-11-07 23:28:52.753675+08
78	1	followup.reminder	job-78	{"clientId": 78}	2026-11-07 23:28:52.556768+08	done	1	\N	\N	2026-11-07 23:28:52.556768+08	2026-11-07 23:28:52.753833+08
79	1	followup.reminder	job-79	{"clientId": 79}	2026-11-07 23:28:52.557182+08	done	1	\N	\N	2026-11-07 23:28:52.557182+08	2026-11-07 23:28:52.753951+08
80	1	followup.reminder	job-80	{"clientId": 80}	2026-11-07 23:28:52.557715+08	done	1	\N	\N	2026-11-07 23:28:52.557715+08	2026-11-07 23:28:52.753993+08
81	1	followup.reminder	job-81	{"clientId": 81}	2026-11-07 23:28:52.558088+08	done	1	\N	\N	2026-11-07 23:28:52.558088+08	2026-11-07 23:28:52.755008+08
82	1	followup.reminder	job-82	{"clientId": 82}	2026-11-07 23:28:52.55842+08	done	1	\N	\N	2026-11-07 23:28:52.55842+08	2026-11-07 23:28:52.755034+08
83	1	followup.reminder	job-83	{"clientId": 83}	2026-11-07 23:28:52.558722+08	done	1	\N	\N	2026-11-07 23:28:52.558722+08	2026-11-07 23:28:52.755067+08
85	1	followup.reminder	job-85	{"clientId": 85}	2026-11-07 23:28:52.559827+08	done	1	\N	\N	2026-11-07 23:28:52.559827+08	2026-11-07 23:28:52.757013+08
87	1	followup.reminder	job-87	{"clientId": 87}	2026-11-07 23:28:52.560595+08	done	1	\N	\N	2026-11-07 23:28:52.560595+08	2026-11-07 23:28:52.757111+08
86	1	followup.reminder	job-86	{"clientId": 86}	2026-11-07 23:28:52.560284+08	done	1	\N	\N	2026-11-07 23:28:52.560284+08	2026-11-07 23:28:52.757056+08
88	1	followup.reminder	job-88	{"clientId": 88}	2026-11-07 23:28:52.560834+08	done	1	\N	\N	2026-11-07 23:28:52.560834+08	2026-11-07 23:28:52.757414+08
89	1	followup.reminder	job-89	{"clientId": 89}	2026-11-07 23:28:52.561125+08	done	1	\N	\N	2026-11-07 23:28:52.561125+08	2026-11-07 23:28:52.758051+08
90	1	followup.reminder	job-90	{"clientId": 90}	2026-11-07 23:28:52.561469+08	done	1	\N	\N	2026-11-07 23:28:52.561469+08	2026-11-07 23:28:52.758142+08
91	1	followup.reminder	job-91	{"clientId": 91}	2026-11-07 23:28:52.561767+08	done	1	\N	\N	2026-11-07 23:28:52.561767+08	2026-11-07 23:28:52.758165+08
92	1	followup.reminder	job-92	{"clientId": 92}	2026-11-07 23:28:52.56211+08	done	1	\N	\N	2026-11-07 23:28:52.56211+08	2026-11-07 23:28:52.758353+08
93	1	followup.reminder	job-93	{"clientId": 93}	2026-11-07 23:28:52.562511+08	done	1	\N	\N	2026-11-07 23:28:52.562511+08	2026-11-07 23:28:52.759166+08
94	1	followup.reminder	job-94	{"clientId": 94}	2026-11-07 23:28:52.563314+08	done	1	\N	\N	2026-11-07 23:28:52.563314+08	2026-11-07 23:28:52.759415+08
95	1	followup.reminder	job-95	{"clientId": 95}	2026-11-07 23:28:52.563781+08	done	1	\N	\N	2026-11-07 23:28:52.563781+08	2026-11-07 23:28:52.759509+08
96	1	followup.reminder	job-96	{"clientId": 96}	2026-11-07 23:28:52.564164+08	done	1	\N	\N	2026-11-07 23:28:52.564164+08	2026-11-07 23:28:52.759776+08
97	1	followup.reminder	job-97	{"clientId": 97}	2026-11-07 23:28:52.564421+08	done	1	\N	\N	2026-11-07 23:28:52.564421+08	2026-11-07 23:28:52.760034+08
98	1	followup.reminder	job-98	{"clientId": 98}	2026-11-07 23:28:52.564649+08	done	1	\N	\N	2026-11-07 23:28:52.564649+08	2026-11-07 23:28:52.760265+08
99	1	followup.reminder	job-99	{"clientId": 99}	2026-11-07 23:28:52.564878+08	done	1	\N	\N	2026-11-07 23:28:52.564878+08	2026-11-07 23:28:52.760601+08
100	1	followup.reminder	job-100	{"clientId": 100}	2026-11-07 23:28:52.565131+08	done	1	\N	\N	2026-11-07 23:28:52.565131+08	2026-11-07 23:28:52.76063+08
103	1	followup.reminder	job-103	{"clientId": 103}	2026-11-07 23:28:52.566711+08	done	1	\N	\N	2026-11-07 23:28:52.566711+08	2026-11-07 23:28:52.761661+08
101	1	followup.reminder	job-101	{"clientId": 101}	2026-11-07 23:28:52.565485+08	done	1	\N	\N	2026-11-07 23:28:52.565485+08	2026-11-07 23:28:52.761627+08
104	1	followup.reminder	job-104	{"clientId": 104}	2026-11-07 23:28:52.567058+08	done	1	\N	\N	2026-11-07 23:28:52.567058+08	2026-11-07 23:28:52.761677+08
105	1	followup.reminder	job-105	{"clientId": 105}	2026-11-07 23:28:52.56745+08	done	1	\N	\N	2026-11-07 23:28:52.56745+08	2026-11-07 23:28:52.763327+08
106	1	followup.reminder	job-106	{"clientId": 106}	2026-11-07 23:28:52.567807+08	done	1	\N	\N	2026-11-07 23:28:52.567807+08	2026-11-07 23:28:52.763378+08
107	1	followup.reminder	job-107	{"clientId": 107}	2026-11-07 23:28:52.568182+08	done	1	\N	\N	2026-11-07 23:28:52.568182+08	2026-11-07 23:28:52.763409+08
108	1	followup.reminder	job-108	{"clientId": 108}	2026-11-07 23:28:52.568469+08	done	1	\N	\N	2026-11-07 23:28:52.568469+08	2026-11-07 23:28:52.76349+08
110	1	followup.reminder	job-110	{"clientId": 110}	2026-11-07 23:28:52.569023+08	done	1	\N	\N	2026-11-07 23:28:52.569023+08	2026-11-07 23:28:52.764622+08
109	1	followup.reminder	job-109	{"clientId": 109}	2026-11-07 23:28:52.568774+08	done	1	\N	\N	2026-11-07 23:28:52.568774+08	2026-11-07 23:28:52.764578+08
117	1	followup.reminder	job-117	{"clientId": 117}	2026-11-07 23:28:52.571193+08	done	1	\N	\N	2026-11-07 23:28:52.571193+08	2026-11-07 23:28:52.76688+08
118	1	followup.reminder	job-118	{"clientId": 118}	2026-11-07 23:28:52.571408+08	done	1	\N	\N	2026-11-07 23:28:52.571408+08	2026-11-07 23:28:52.766925+08
120	1	followup.reminder	job-120	{"clientId": 120}	2026-11-07 23:28:52.572011+08	done	1	\N	\N	2026-11-07 23:28:52.572011+08	2026-11-07 23:28:52.767303+08
122	1	followup.reminder	job-122	{"clientId": 122}	2026-11-07 23:28:52.572745+08	done	1	\N	\N	2026-11-07 23:28:52.572745+08	2026-11-07 23:28:52.768538+08
121	1	followup.reminder	job-121	{"clientId": 121}	2026-11-07 23:28:52.572283+08	done	1	\N	\N	2026-11-07 23:28:52.572283+08	2026-11-07 23:28:52.768518+08
126	1	followup.reminder	job-126	{"clientId": 126}	2026-11-07 23:28:52.574148+08	done	1	\N	\N	2026-11-07 23:28:52.574148+08	2026-11-07 23:28:52.770166+08
125	1	followup.reminder	job-125	{"clientId": 125}	2026-11-07 23:28:52.573865+08	done	1	\N	\N	2026-11-07 23:28:52.573865+08	2026-11-07 23:28:52.769995+08
128	1	followup.reminder	job-128	{"clientId": 128}	2026-11-07 23:28:52.574884+08	done	1	\N	\N	2026-11-07 23:28:52.574884+08	2026-11-07 23:28:52.770382+08
127	1	followup.reminder	job-127	{"clientId": 127}	2026-11-07 23:28:52.574494+08	done	1	\N	\N	2026-11-07 23:28:52.574494+08	2026-11-07 23:28:52.770231+08
129	1	followup.reminder	job-129	{"clientId": 129}	2026-11-07 23:28:52.575123+08	done	1	\N	\N	2026-11-07 23:28:52.575123+08	2026-11-07 23:28:52.771348+08
130	1	followup.reminder	job-130	{"clientId": 130}	2026-11-07 23:28:52.575401+08	done	1	\N	\N	2026-11-07 23:28:52.575401+08	2026-11-07 23:28:52.77142+08
131	1	followup.reminder	job-131	{"clientId": 131}	2026-11-07 23:28:52.575631+08	done	1	\N	\N	2026-11-07 23:28:52.575631+08	2026-11-07 23:28:52.771447+08
132	1	followup.reminder	job-132	{"clientId": 132}	2026-11-07 23:28:52.576406+08	done	1	\N	\N	2026-11-07 23:28:52.576406+08	2026-11-07 23:28:52.771487+08
133	1	followup.reminder	job-133	{"clientId": 133}	2026-11-07 23:28:52.576979+08	done	1	\N	\N	2026-11-07 23:28:52.576979+08	2026-11-07 23:28:52.772053+08
134	1	followup.reminder	job-134	{"clientId": 134}	2026-11-07 23:28:52.577356+08	done	1	\N	\N	2026-11-07 23:28:52.577356+08	2026-11-07 23:28:52.77211+08
135	1	followup.reminder	job-135	{"clientId": 135}	2026-11-07 23:28:52.577683+08	done	1	\N	\N	2026-11-07 23:28:52.577683+08	2026-11-07 23:28:52.772158+08
136	1	followup.reminder	job-136	{"clientId": 136}	2026-11-07 23:28:52.57812+08	done	1	\N	\N	2026-11-07 23:28:52.57812+08	2026-11-07 23:28:52.772289+08
137	1	followup.reminder	job-137	{"clientId": 137}	2026-11-07 23:28:52.578508+08	done	1	\N	\N	2026-11-07 23:28:52.578508+08	2026-11-07 23:28:52.773665+08
138	1	followup.reminder	job-138	{"clientId": 138}	2026-11-07 23:28:52.578871+08	done	1	\N	\N	2026-11-07 23:28:52.578871+08	2026-11-07 23:28:52.773875+08
140	1	followup.reminder	job-140	{"clientId": 140}	2026-11-07 23:28:52.579539+08	done	1	\N	\N	2026-11-07 23:28:52.579539+08	2026-11-07 23:28:52.774117+08
141	1	followup.reminder	job-141	{"clientId": 141}	2026-11-07 23:28:52.579901+08	done	1	\N	\N	2026-11-07 23:28:52.579901+08	2026-11-07 23:28:52.77646+08
142	1	followup.reminder	job-142	{"clientId": 142}	2026-11-07 23:28:52.580342+08	done	1	\N	\N	2026-11-07 23:28:52.580342+08	2026-11-07 23:28:52.7765+08
143	1	followup.reminder	job-143	{"clientId": 143}	2026-11-07 23:28:52.580622+08	done	1	\N	\N	2026-11-07 23:28:52.580622+08	2026-11-07 23:28:52.776493+08
144	1	followup.reminder	job-144	{"clientId": 144}	2026-11-07 23:28:52.580843+08	done	1	\N	\N	2026-11-07 23:28:52.580843+08	2026-11-07 23:28:52.776523+08
145	1	followup.reminder	job-145	{"clientId": 145}	2026-11-07 23:28:52.581053+08	done	1	\N	\N	2026-11-07 23:28:52.581053+08	2026-11-07 23:28:52.77755+08
146	1	followup.reminder	job-146	{"clientId": 146}	2026-11-07 23:28:52.581275+08	done	1	\N	\N	2026-11-07 23:28:52.581275+08	2026-11-07 23:28:52.777578+08
147	1	followup.reminder	job-147	{"clientId": 147}	2026-11-07 23:28:52.581643+08	done	1	\N	\N	2026-11-07 23:28:52.581643+08	2026-11-07 23:28:52.777668+08
148	1	followup.reminder	job-148	{"clientId": 148}	2026-11-07 23:28:52.582004+08	done	1	\N	\N	2026-11-07 23:28:52.582004+08	2026-11-07 23:28:52.777692+08
149	1	followup.reminder	job-149	{"clientId": 149}	2026-11-07 23:28:52.582284+08	done	1	\N	\N	2026-11-07 23:28:52.582284+08	2026-11-07 23:28:52.778287+08
150	1	followup.reminder	job-150	{"clientId": 150}	2026-11-07 23:28:52.582617+08	done	1	\N	\N	2026-11-07 23:28:52.582617+08	2026-11-07 23:28:52.778349+08
151	1	followup.reminder	job-151	{"clientId": 151}	2026-11-07 23:28:52.58298+08	done	1	\N	\N	2026-11-07 23:28:52.58298+08	2026-11-07 23:28:52.778543+08
152	1	followup.reminder	job-152	{"clientId": 152}	2026-11-07 23:28:52.583275+08	done	1	\N	\N	2026-11-07 23:28:52.583275+08	2026-11-07 23:28:52.778502+08
153	1	followup.reminder	job-153	{"clientId": 153}	2026-11-07 23:28:52.583569+08	done	1	\N	\N	2026-11-07 23:28:52.583569+08	2026-11-07 23:28:52.779202+08
154	1	followup.reminder	job-154	{"clientId": 154}	2026-11-07 23:28:52.583856+08	done	1	\N	\N	2026-11-07 23:28:52.583856+08	2026-11-07 23:28:52.779236+08
156	1	followup.reminder	job-156	{"clientId": 156}	2026-11-07 23:28:52.584376+08	done	1	\N	\N	2026-11-07 23:28:52.584376+08	2026-11-07 23:28:52.779961+08
155	1	followup.reminder	job-155	{"clientId": 155}	2026-11-07 23:28:52.584084+08	done	1	\N	\N	2026-11-07 23:28:52.584084+08	2026-11-07 23:28:52.779484+08
157	1	followup.reminder	job-157	{"clientId": 157}	2026-11-07 23:28:52.584699+08	done	1	\N	\N	2026-11-07 23:28:52.584699+08	2026-11-07 23:28:52.780416+08
158	1	followup.reminder	job-158	{"clientId": 158}	2026-11-07 23:28:52.585063+08	done	1	\N	\N	2026-11-07 23:28:52.585063+08	2026-11-07 23:28:52.780665+08
159	1	followup.reminder	job-159	{"clientId": 159}	2026-11-07 23:28:52.585341+08	done	1	\N	\N	2026-11-07 23:28:52.585341+08	2026-11-07 23:28:52.780949+08
160	1	followup.reminder	job-160	{"clientId": 160}	2026-11-07 23:28:52.585645+08	done	1	\N	\N	2026-11-07 23:28:52.585645+08	2026-11-07 23:28:52.781079+08
161	1	followup.reminder	job-161	{"clientId": 161}	2026-11-07 23:28:52.585991+08	done	1	\N	\N	2026-11-07 23:28:52.585991+08	2026-11-07 23:28:52.781988+08
164	1	followup.reminder	job-164	{"clientId": 164}	2026-11-07 23:28:52.587572+08	done	1	\N	\N	2026-11-07 23:28:52.587572+08	2026-11-07 23:28:52.78203+08
163	1	followup.reminder	job-163	{"clientId": 163}	2026-11-07 23:28:52.587255+08	done	1	\N	\N	2026-11-07 23:28:52.587255+08	2026-11-07 23:28:52.782048+08
165	1	followup.reminder	job-165	{"clientId": 165}	2026-11-07 23:28:52.587958+08	done	1	\N	\N	2026-11-07 23:28:52.587958+08	2026-11-07 23:28:52.783571+08
1	1	followup.reminder	job-1	{"clientId": 1}	2026-11-07 23:28:52.525197+08	done	1	\N	\N	2026-11-07 23:28:52.525197+08	2026-11-07 23:28:52.602706+08
2	1	followup.reminder	job-2	{"clientId": 2}	2026-11-07 23:28:52.527007+08	done	1	\N	\N	2026-11-07 23:28:52.527007+08	2026-11-07 23:28:52.606051+08
5	1	followup.reminder	job-5	{"clientId": 5}	2026-11-07 23:28:52.528588+08	done	1	\N	\N	2026-11-07 23:28:52.528588+08	2026-11-07 23:28:52.611151+08
21	1	followup.reminder	job-21	{"clientId": 21}	2026-11-07 23:28:52.534996+08	done	1	\N	\N	2026-11-07 23:28:52.534996+08	2026-11-07 23:28:52.734441+08
23	1	followup.reminder	job-23	{"clientId": 23}	2026-11-07 23:28:52.535572+08	done	1	\N	\N	2026-11-07 23:28:52.535572+08	2026-11-07 23:28:52.734551+08
22	1	followup.reminder	job-22	{"clientId": 22}	2026-11-07 23:28:52.535304+08	done	1	\N	\N	2026-11-07 23:28:52.535304+08	2026-11-07 23:28:52.734495+08
24	1	followup.reminder	job-24	{"clientId": 24}	2026-11-07 23:28:52.535838+08	done	1	\N	\N	2026-11-07 23:28:52.535838+08	2026-11-07 23:28:52.734533+08
28	1	followup.reminder	job-28	{"clientId": 28}	2026-11-07 23:28:52.53809+08	done	1	\N	\N	2026-11-07 23:28:52.53809+08	2026-11-07 23:28:52.73642+08
42	1	followup.reminder	job-42	{"clientId": 42}	2026-11-07 23:28:52.54261+08	done	1	\N	\N	2026-11-07 23:28:52.54261+08	2026-11-07 23:28:52.741341+08
44	1	followup.reminder	job-44	{"clientId": 44}	2026-11-07 23:28:52.543485+08	done	1	\N	\N	2026-11-07 23:28:52.543485+08	2026-11-07 23:28:52.741359+08
43	1	followup.reminder	job-43	{"clientId": 43}	2026-11-07 23:28:52.543002+08	done	1	\N	\N	2026-11-07 23:28:52.543002+08	2026-11-07 23:28:52.741326+08
56	1	followup.reminder	job-56	{"clientId": 56}	2026-11-07 23:28:52.548074+08	done	1	\N	\N	2026-11-07 23:28:52.548074+08	2026-11-07 23:28:52.74666+08
57	1	followup.reminder	job-57	{"clientId": 57}	2026-11-07 23:28:52.548964+08	done	1	\N	\N	2026-11-07 23:28:52.548964+08	2026-11-07 23:28:52.747384+08
58	1	followup.reminder	job-58	{"clientId": 58}	2026-11-07 23:28:52.549348+08	done	1	\N	\N	2026-11-07 23:28:52.549348+08	2026-11-07 23:28:52.747567+08
59	1	followup.reminder	job-59	{"clientId": 59}	2026-11-07 23:28:52.549788+08	done	1	\N	\N	2026-11-07 23:28:52.549788+08	2026-11-07 23:28:52.747596+08
60	1	followup.reminder	job-60	{"clientId": 60}	2026-11-07 23:28:52.550081+08	done	1	\N	\N	2026-11-07 23:28:52.550081+08	2026-11-07 23:28:52.747761+08
62	1	followup.reminder	job-62	{"clientId": 62}	2026-11-07 23:28:52.550647+08	done	1	\N	\N	2026-11-07 23:28:52.550647+08	2026-11-07 23:28:52.748897+08
64	1	followup.reminder	job-64	{"clientId": 64}	2026-11-07 23:28:52.551359+08	done	1	\N	\N	2026-11-07 23:28:52.551359+08	2026-11-07 23:28:52.748907+08
171	1	followup.reminder	job-171	{"clientId": 171}	2026-11-07 23:28:52.589819+08	done	1	\N	\N	2026-11-07 23:28:52.589819+08	2026-11-07 23:28:52.784923+08
172	1	followup.reminder	job-172	{"clientId": 172}	2026-11-07 23:28:52.590202+08	done	1	\N	\N	2026-11-07 23:28:52.590202+08	2026-11-07 23:28:52.785922+08
173	1	followup.reminder	job-173	{"clientId": 173}	2026-11-07 23:28:52.590619+08	done	1	\N	\N	2026-11-07 23:28:52.590619+08	2026-11-07 23:28:52.78587+08
176	1	followup.reminder	job-176	{"clientId": 176}	2026-11-07 23:28:52.591321+08	done	1	\N	\N	2026-11-07 23:28:52.591321+08	2026-11-07 23:28:52.786966+08
177	1	followup.reminder	job-177	{"clientId": 177}	2026-11-07 23:28:52.591528+08	done	1	\N	\N	2026-11-07 23:28:52.591528+08	2026-11-07 23:28:52.787059+08
178	1	followup.reminder	job-178	{"clientId": 178}	2026-11-07 23:28:52.591744+08	done	1	\N	\N	2026-11-07 23:28:52.591744+08	2026-11-07 23:28:52.787145+08
179	1	followup.reminder	job-179	{"clientId": 179}	2026-11-07 23:28:52.592006+08	done	1	\N	\N	2026-11-07 23:28:52.592006+08	2026-11-07 23:28:52.787165+08
180	1	followup.reminder	job-180	{"clientId": 180}	2026-11-07 23:28:52.592235+08	done	1	\N	\N	2026-11-07 23:28:52.592235+08	2026-11-07 23:28:52.787902+08
181	1	followup.reminder	job-181	{"clientId": 181}	2026-11-07 23:28:52.592503+08	done	1	\N	\N	2026-11-07 23:28:52.592503+08	2026-11-07 23:28:52.788847+08
183	1	followup.reminder	job-183	{"clientId": 183}	2026-11-07 23:28:52.59309+08	done	1	\N	\N	2026-11-07 23:28:52.59309+08	2026-11-07 23:28:52.788897+08
182	1	followup.reminder	job-182	{"clientId": 182}	2026-11-07 23:28:52.592856+08	done	1	\N	\N	2026-11-07 23:28:52.592856+08	2026-11-07 23:28:52.78887+08
184	1	followup.reminder	job-184	{"clientId": 184}	2026-11-07 23:28:52.593492+08	done	1	\N	\N	2026-11-07 23:28:52.593492+08	2026-11-07 23:28:52.788882+08
185	1	followup.reminder	job-185	{"clientId": 185}	2026-11-07 23:28:52.594325+08	done	1	\N	\N	2026-11-07 23:28:52.594325+08	2026-11-07 23:28:52.790318+08
186	1	followup.reminder	job-186	{"clientId": 186}	2026-11-07 23:28:52.594715+08	done	1	\N	\N	2026-11-07 23:28:52.594715+08	2026-11-07 23:28:52.790494+08
187	1	followup.reminder	job-187	{"clientId": 187}	2026-11-07 23:28:52.59514+08	done	1	\N	\N	2026-11-07 23:28:52.59514+08	2026-11-07 23:28:52.790467+08
189	1	followup.reminder	job-189	{"clientId": 189}	2026-11-07 23:28:52.59584+08	done	1	\N	\N	2026-11-07 23:28:52.59584+08	2026-11-07 23:28:52.791106+08
190	1	followup.reminder	job-190	{"clientId": 190}	2026-11-07 23:28:52.596226+08	done	1	\N	\N	2026-11-07 23:28:52.596226+08	2026-11-07 23:28:52.791255+08
191	1	followup.reminder	job-191	{"clientId": 191}	2026-11-07 23:28:52.596598+08	done	1	\N	\N	2026-11-07 23:28:52.596598+08	2026-11-07 23:28:52.791354+08
192	1	followup.reminder	job-192	{"clientId": 192}	2026-11-07 23:28:52.596963+08	done	1	\N	\N	2026-11-07 23:28:52.596963+08	2026-11-07 23:28:52.791398+08
193	1	followup.reminder	job-193	{"clientId": 193}	2026-11-07 23:28:52.59732+08	done	1	\N	\N	2026-11-07 23:28:52.59732+08	2026-11-07 23:28:52.791877+08
195	1	followup.reminder	job-195	{"clientId": 195}	2026-11-07 23:28:52.597888+08	done	1	\N	\N	2026-11-07 23:28:52.597888+08	2026-11-07 23:28:52.792246+08
194	1	followup.reminder	job-194	{"clientId": 194}	2026-11-07 23:28:52.597632+08	done	1	\N	\N	2026-11-07 23:28:52.597632+08	2026-11-07 23:28:52.791964+08
196	1	followup.reminder	job-196	{"clientId": 196}	2026-11-07 23:28:52.598205+08	done	1	\N	\N	2026-11-07 23:28:52.598205+08	2026-11-07 23:28:52.792325+08
197	1	followup.reminder	job-197	{"clientId": 197}	2026-11-07 23:28:52.598608+08	done	1	\N	\N	2026-11-07 23:28:52.598608+08	2026-11-07 23:28:52.793561+08
198	1	followup.reminder	job-198	{"clientId": 198}	2026-11-07 23:28:52.598993+08	done	1	\N	\N	2026-11-07 23:28:52.598993+08	2026-11-07 23:28:52.793971+08
200	1	followup.reminder	job-200	{"clientId": 200}	2026-11-07 23:28:52.599894+08	done	1	\N	\N	2026-11-07 23:28:52.599894+08	2026-11-07 23:28:52.794091+08
199	1	followup.reminder	job-199	{"clientId": 199}	2026-11-07 23:28:52.5995+08	done	1	\N	\N	2026-11-07 23:28:52.5995+08	2026-11-07 23:28:52.794+08
61	1	followup.reminder	job-61	{"clientId": 61}	2026-11-07 23:28:52.550323+08	done	1	\N	\N	2026-11-07 23:28:52.550323+08	2026-11-07 23:28:52.748873+08
111	1	followup.reminder	job-111	{"clientId": 111}	2026-11-07 23:28:52.569333+08	done	1	\N	\N	2026-11-07 23:28:52.569333+08	2026-11-07 23:28:52.764671+08
114	1	followup.reminder	job-114	{"clientId": 114}	2026-11-07 23:28:52.570422+08	done	1	\N	\N	2026-11-07 23:28:52.570422+08	2026-11-07 23:28:52.766052+08
123	1	followup.reminder	job-123	{"clientId": 123}	2026-11-07 23:28:52.573119+08	done	1	\N	\N	2026-11-07 23:28:52.573119+08	2026-11-07 23:28:52.768569+08
167	1	followup.reminder	job-167	{"clientId": 167}	2026-11-07 23:28:52.58855+08	done	1	\N	\N	2026-11-07 23:28:52.58855+08	2026-11-07 23:28:52.783785+08
170	1	followup.reminder	job-170	{"clientId": 170}	2026-11-07 23:28:52.589457+08	done	1	\N	\N	2026-11-07 23:28:52.589457+08	2026-11-07 23:28:52.784958+08
174	1	followup.reminder	job-174	{"clientId": 174}	2026-11-07 23:28:52.590877+08	done	1	\N	\N	2026-11-07 23:28:52.590877+08	2026-11-07 23:28:52.785947+08
76	1	followup.reminder	job-76	{"clientId": 76}	2026-11-07 23:28:52.555712+08	done	1	\N	\N	2026-11-07 23:28:52.555712+08	2026-11-07 23:28:52.752745+08
115	1	followup.reminder	job-115	{"clientId": 115}	2026-11-07 23:28:52.570724+08	done	1	\N	\N	2026-11-07 23:28:52.570724+08	2026-11-07 23:28:52.766024+08
162	1	followup.reminder	job-162	{"clientId": 162}	2026-11-07 23:28:52.586892+08	done	1	\N	\N	2026-11-07 23:28:52.586892+08	2026-11-07 23:28:52.782018+08
168	1	followup.reminder	job-168	{"clientId": 168}	2026-11-07 23:28:52.588777+08	done	1	\N	\N	2026-11-07 23:28:52.588777+08	2026-11-07 23:28:52.783996+08
204	1	followup.reminder	fail-once	{"fail": true}	2026-11-07 23:28:58.30698+08	failed	3	\N	forced_failure	2026-11-07 23:28:52.796828+08	2026-11-07 23:28:59.813338+08
205	1	followup.reminder	crash-recover	{}	2026-11-07 23:29:03.328083+08	done	1	\N	stale_recovered	2026-11-07 23:29:03.328083+08	2026-11-07 23:29:03.330503+08
84	1	followup.reminder	job-84	{"clientId": 84}	2026-11-07 23:28:52.559009+08	done	1	\N	\N	2026-11-07 23:28:52.559009+08	2026-11-07 23:28:52.755048+08
113	1	followup.reminder	job-113	{"clientId": 113}	2026-11-07 23:28:52.570054+08	done	1	\N	\N	2026-11-07 23:28:52.570054+08	2026-11-07 23:28:52.765846+08
124	1	followup.reminder	job-124	{"clientId": 124}	2026-11-07 23:28:52.573506+08	done	1	\N	\N	2026-11-07 23:28:52.573506+08	2026-11-07 23:28:52.768559+08
139	1	followup.reminder	job-139	{"clientId": 139}	2026-11-07 23:28:52.579155+08	done	1	\N	\N	2026-11-07 23:28:52.579155+08	2026-11-07 23:28:52.773935+08
169	1	followup.reminder	job-169	{"clientId": 169}	2026-11-07 23:28:52.589081+08	done	1	\N	\N	2026-11-07 23:28:52.589081+08	2026-11-07 23:28:52.784864+08
102	1	followup.reminder	job-102	{"clientId": 102}	2026-11-07 23:28:52.565873+08	done	1	\N	\N	2026-11-07 23:28:52.565873+08	2026-11-07 23:28:52.761648+08
112	1	followup.reminder	job-112	{"clientId": 112}	2026-11-07 23:28:52.569678+08	done	1	\N	\N	2026-11-07 23:28:52.569678+08	2026-11-07 23:28:52.764907+08
116	1	followup.reminder	job-116	{"clientId": 116}	2026-11-07 23:28:52.570965+08	done	1	\N	\N	2026-11-07 23:28:52.570965+08	2026-11-07 23:28:52.766081+08
119	1	followup.reminder	job-119	{"clientId": 119}	2026-11-07 23:28:52.571684+08	done	1	\N	\N	2026-11-07 23:28:52.571684+08	2026-11-07 23:28:52.767232+08
166	1	followup.reminder	job-166	{"clientId": 166}	2026-11-07 23:28:52.588236+08	done	1	\N	\N	2026-11-07 23:28:52.588236+08	2026-11-07 23:28:52.783638+08
175	1	followup.reminder	job-175	{"clientId": 175}	2026-11-07 23:28:52.591101+08	done	1	\N	\N	2026-11-07 23:28:52.591101+08	2026-11-07 23:28:52.786211+08
188	1	followup.reminder	job-188	{"clientId": 188}	2026-11-07 23:28:52.595518+08	done	1	\N	\N	2026-11-07 23:28:52.595518+08	2026-11-07 23:28:52.790633+08
\.


--
-- Data for Name: memberships; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.memberships (tenant_id, user_id, role, created_at) FROM stdin;
1	1	owner	2026-11-07 23:29:18.145394+08
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
d260dba95b3fcfae94a2a1baf1b2897e7373c3db5313a65a3dab3e22abc107ef	1	2026-11-08 11:29:18.141+08	2026-11-07 23:29:18.143063+08
\.


--
-- Data for Name: tenants; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.tenants (id, name, plan, seat_limit, created_at) FROM stdin;
1	团队	team	5	2026-11-07 23:29:18.145394+08
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: p04; Owner: -
--

COPY p04.users (id, email, name, password_hash, created_at) FROM stdin;
1	owner@example.com	测试用户	fb3ad9aa05b25ab71cd736894d877d25:230441adb0788e044460479659a644131a76b3283da0b3872f7e001414e8e5997bdf8e29d3bb20973538785650dda36b6851416ea7fadeb5cafcfd4fdcd9cf86	2026-11-07 23:29:18.114601+08
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

SELECT pg_catalog.setval('p04.jobs_id_seq', 205, true);


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

\unrestrict GqbQeUQYMenGLm7tG3WN4vfDI11eYxDTjp83vPbJJdBDGtf2k2eq8Z0RbLGe2ld

