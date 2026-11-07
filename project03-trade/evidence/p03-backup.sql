--
-- PostgreSQL database dump
--

\restrict Zgr00zfMvLzNwkpkvUksftWEVyLCDiLatf3kXnMU3Jjh9cbeK7QNQQYgAMylmsc

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
-- Name: p03; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA p03;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: inventory; Type: TABLE; Schema: p03; Owner: -
--

CREATE TABLE p03.inventory (
    sku text NOT NULL,
    title text NOT NULL,
    unit_price integer NOT NULL,
    stock integer NOT NULL,
    CONSTRAINT inventory_stock_check CHECK ((stock >= 0)),
    CONSTRAINT inventory_unit_price_check CHECK ((unit_price > 0))
);


--
-- Name: order_items; Type: TABLE; Schema: p03; Owner: -
--

CREATE TABLE p03.order_items (
    order_id integer NOT NULL,
    sku text NOT NULL,
    title text NOT NULL,
    unit_price integer NOT NULL,
    qty integer NOT NULL
);


--
-- Name: orders; Type: TABLE; Schema: p03; Owner: -
--

CREATE TABLE p03.orders (
    id integer NOT NULL,
    user_id text NOT NULL,
    idem_key text NOT NULL,
    request_hash text NOT NULL,
    sku text NOT NULL,
    qty integer NOT NULL,
    unit_price integer NOT NULL,
    amount integer NOT NULL,
    status text DEFAULT 'created'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    paid_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    CONSTRAINT orders_amount_check CHECK ((amount > 0)),
    CONSTRAINT orders_qty_check CHECK ((qty > 0)),
    CONSTRAINT orders_status_check CHECK ((status = ANY (ARRAY['created'::text, 'paid'::text, 'cancelled'::text]))),
    CONSTRAINT orders_unit_price_check CHECK ((unit_price > 0))
);


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: p03; Owner: -
--

CREATE SEQUENCE p03.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: p03; Owner: -
--

ALTER SEQUENCE p03.orders_id_seq OWNED BY p03.orders.id;


--
-- Name: payment_events; Type: TABLE; Schema: p03; Owner: -
--

CREATE TABLE p03.payment_events (
    event_id text NOT NULL,
    order_id integer NOT NULL,
    result text NOT NULL,
    applied boolean DEFAULT false NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT payment_events_result_check CHECK ((result = ANY (ARRAY['success'::text, 'failed'::text])))
);


--
-- Name: schema_migrations; Type: TABLE; Schema: p03; Owner: -
--

CREATE TABLE p03.schema_migrations (
    filename text NOT NULL,
    applied_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: orders id; Type: DEFAULT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.orders ALTER COLUMN id SET DEFAULT nextval('p03.orders_id_seq'::regclass);


--
-- Data for Name: inventory; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.inventory (sku, title, unit_price, stock) FROM stdin;
sku-2	显示器	1299	1
sku-1	机械键盘	299	10
load-sku	压测商品	10	0
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.order_items (order_id, sku, title, unit_price, qty) FROM stdin;
1	sku-1	机械键盘	299	2
2	load-sku	压测商品	10	1
3	load-sku	压测商品	10	1
4	load-sku	压测商品	10	1
5	load-sku	压测商品	10	1
6	load-sku	压测商品	10	1
7	load-sku	压测商品	10	1
8	load-sku	压测商品	10	1
9	load-sku	压测商品	10	1
10	load-sku	压测商品	10	1
11	load-sku	压测商品	10	1
12	load-sku	压测商品	10	1
13	load-sku	压测商品	10	1
14	load-sku	压测商品	10	1
15	load-sku	压测商品	10	1
16	load-sku	压测商品	10	1
17	load-sku	压测商品	10	1
18	load-sku	压测商品	10	1
19	load-sku	压测商品	10	1
20	load-sku	压测商品	10	1
21	load-sku	压测商品	10	1
22	load-sku	压测商品	10	1
23	load-sku	压测商品	10	1
24	load-sku	压测商品	10	1
25	load-sku	压测商品	10	1
26	load-sku	压测商品	10	1
27	load-sku	压测商品	10	1
28	load-sku	压测商品	10	1
29	load-sku	压测商品	10	1
30	load-sku	压测商品	10	1
31	load-sku	压测商品	10	1
32	load-sku	压测商品	10	1
33	load-sku	压测商品	10	1
34	load-sku	压测商品	10	1
35	load-sku	压测商品	10	1
36	load-sku	压测商品	10	1
37	load-sku	压测商品	10	1
38	load-sku	压测商品	10	1
39	load-sku	压测商品	10	1
40	load-sku	压测商品	10	1
41	load-sku	压测商品	10	1
42	load-sku	压测商品	10	1
43	load-sku	压测商品	10	1
44	load-sku	压测商品	10	1
45	load-sku	压测商品	10	1
46	load-sku	压测商品	10	1
47	load-sku	压测商品	10	1
48	load-sku	压测商品	10	1
49	load-sku	压测商品	10	1
50	load-sku	压测商品	10	1
51	load-sku	压测商品	10	1
52	load-sku	压测商品	10	1
53	load-sku	压测商品	10	1
54	load-sku	压测商品	10	1
55	load-sku	压测商品	10	1
56	load-sku	压测商品	10	1
57	load-sku	压测商品	10	1
58	load-sku	压测商品	10	1
59	load-sku	压测商品	10	1
60	load-sku	压测商品	10	1
61	load-sku	压测商品	10	1
62	load-sku	压测商品	10	1
63	load-sku	压测商品	10	1
64	load-sku	压测商品	10	1
65	load-sku	压测商品	10	1
66	load-sku	压测商品	10	1
67	load-sku	压测商品	10	1
68	load-sku	压测商品	10	1
69	load-sku	压测商品	10	1
70	load-sku	压测商品	10	1
71	load-sku	压测商品	10	1
72	load-sku	压测商品	10	1
73	load-sku	压测商品	10	1
74	load-sku	压测商品	10	1
75	load-sku	压测商品	10	1
76	load-sku	压测商品	10	1
77	load-sku	压测商品	10	1
78	load-sku	压测商品	10	1
79	load-sku	压测商品	10	1
80	load-sku	压测商品	10	1
81	load-sku	压测商品	10	1
82	load-sku	压测商品	10	1
83	load-sku	压测商品	10	1
84	load-sku	压测商品	10	1
85	load-sku	压测商品	10	1
86	load-sku	压测商品	10	1
87	load-sku	压测商品	10	1
88	load-sku	压测商品	10	1
89	load-sku	压测商品	10	1
90	load-sku	压测商品	10	1
91	load-sku	压测商品	10	1
92	load-sku	压测商品	10	1
93	load-sku	压测商品	10	1
94	load-sku	压测商品	10	1
95	load-sku	压测商品	10	1
96	load-sku	压测商品	10	1
97	load-sku	压测商品	10	1
98	load-sku	压测商品	10	1
99	load-sku	压测商品	10	1
100	load-sku	压测商品	10	1
101	load-sku	压测商品	10	1
102	load-sku	压测商品	10	1
103	load-sku	压测商品	10	1
104	load-sku	压测商品	10	1
105	load-sku	压测商品	10	1
106	load-sku	压测商品	10	1
107	load-sku	压测商品	10	1
108	load-sku	压测商品	10	1
109	load-sku	压测商品	10	1
110	load-sku	压测商品	10	1
111	load-sku	压测商品	10	1
112	load-sku	压测商品	10	1
113	load-sku	压测商品	10	1
114	load-sku	压测商品	10	1
115	load-sku	压测商品	10	1
116	load-sku	压测商品	10	1
117	load-sku	压测商品	10	1
118	load-sku	压测商品	10	1
119	load-sku	压测商品	10	1
120	load-sku	压测商品	10	1
121	load-sku	压测商品	10	1
124	load-sku	压测商品	10	1
129	load-sku	压测商品	10	1
132	load-sku	压测商品	10	1
135	load-sku	压测商品	10	1
144	load-sku	压测商品	10	1
122	load-sku	压测商品	10	1
125	load-sku	压测商品	10	1
128	load-sku	压测商品	10	1
131	load-sku	压测商品	10	1
146	load-sku	压测商品	10	1
123	load-sku	压测商品	10	1
127	load-sku	压测商品	10	1
140	load-sku	压测商品	10	1
150	load-sku	压测商品	10	1
126	load-sku	压测商品	10	1
130	load-sku	压测商品	10	1
134	load-sku	压测商品	10	1
137	load-sku	压测商品	10	1
142	load-sku	压测商品	10	1
145	load-sku	压测商品	10	1
148	load-sku	压测商品	10	1
149	load-sku	压测商品	10	1
133	load-sku	压测商品	10	1
136	load-sku	压测商品	10	1
147	load-sku	压测商品	10	1
138	load-sku	压测商品	10	1
139	load-sku	压测商品	10	1
141	load-sku	压测商品	10	1
143	load-sku	压测商品	10	1
151	load-sku	压测商品	10	1
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.orders (id, user_id, idem_key, request_hash, sku, qty, unit_price, amount, status, created_at, paid_at, cancelled_at) FROM stdin;
1	alice	43f7b6f1-b00d-4b98-bcec-8ef7fbddb5e9	a4a4e939dfcf57e86e0ffccf780a78b868c9bd6a285ece3377f0345e1f02d22c	sku-1	2	299	598	cancelled	2026-11-07 22:01:57.207269+08	\N	2026-11-07 22:01:57.212418+08
2	load-1	c3c8108d-73b0-44be-84ce-8576b011b76d	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.825632+08	\N	\N
3	load-13	1f89a209-9cff-456f-90c8-e08f388f4d78	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.845533+08	\N	\N
4	load-14	0ed61049-e55a-4170-bc78-d208fee228b7	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.85604+08	\N	\N
5	load-15	c625c4fd-5328-40ba-8125-868f1bd3832c	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.861047+08	\N	\N
6	load-16	87309a6f-69e9-4a73-a096-395b5c1fffd1	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.866321+08	\N	\N
7	load-17	9fdea815-bf8f-4b89-be1e-b624670b41e6	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.870873+08	\N	\N
8	load-18	c63cdba6-514d-444f-9f1a-f3e5df31c27e	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.877424+08	\N	\N
9	load-19	d25d2034-791a-4c71-a1bd-f1c0d22fc87f	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.88409+08	\N	\N
10	load-20	a0a9aec1-adce-48ba-b8f8-c21f3f6498d5	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.889505+08	\N	\N
11	load-1	91f95de1-5857-4689-bb03-404e6db6f003	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.893978+08	\N	\N
12	load-13	c8609bd9-8fc5-4081-858c-4928ae9cfb6d	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.899829+08	\N	\N
13	load-14	1ef53a65-a4de-4c77-a5d6-f37c564d976b	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.904927+08	\N	\N
14	load-15	d2fea0b2-f02a-4776-9f26-81066144dc1c	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.909739+08	\N	\N
15	load-16	a89aabb6-1950-4bb6-a83c-c81dcf1d5886	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.914774+08	\N	\N
16	load-17	1d0fbdce-42a3-47c4-9728-6b470abae90b	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.919327+08	\N	\N
17	load-18	a1676efd-0c59-44d1-a2b7-db0be3d45180	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.924324+08	\N	\N
18	load-19	f08f738e-54f5-4919-bc00-431f50e51a0b	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.929249+08	\N	\N
19	load-20	9cceec02-930e-436f-b288-09eabd9d6d63	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.934229+08	\N	\N
20	load-1	eec4ab5d-c5f5-427c-a601-8b55118cdc10	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.938411+08	\N	\N
21	load-13	c4e0574f-e4b8-417b-afae-d355aa79f957	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.942239+08	\N	\N
22	load-14	0479d606-a160-4eb9-91e4-0b052ae21d21	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.946298+08	\N	\N
23	load-15	65ac8230-f1c9-4f0d-868c-b9c4e341e878	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.950777+08	\N	\N
24	load-16	e81d5e15-f697-45c1-b809-0432d246c223	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.955401+08	\N	\N
25	load-2	fc85b029-b30e-4360-88e8-f2bc6a556e33	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.955111+08	\N	\N
26	load-17	87180dbc-5447-46f8-8024-c2f4d8bff992	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.960022+08	\N	\N
27	load-18	1c4716d9-a903-49b1-8b53-b6b8d2005f60	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.964075+08	\N	\N
28	load-19	1117152c-c0a5-4f0c-9495-5187e5a3e0e8	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.966425+08	\N	\N
29	load-20	75edb91d-dea4-44b7-a765-d3dde605f983	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.969365+08	\N	\N
30	load-1	b8e3e158-ad0b-45ec-937a-3f535e0afce1	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.972738+08	\N	\N
31	load-13	a23ccec2-eee1-45c8-b0c5-8d96d92ab8a5	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.975532+08	\N	\N
32	load-14	dced2eac-996f-48ad-8d0a-069f37426194	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.978726+08	\N	\N
33	load-15	0d4f26e1-6241-4273-a2ec-34fd823b6d65	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.981891+08	\N	\N
34	load-16	b139337d-560d-46d2-85bd-eba3df9a44eb	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.985472+08	\N	\N
35	load-2	f7507f21-8cec-4e68-8b7d-5aa9f7b60703	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.989207+08	\N	\N
36	load-17	914756e7-b77c-494e-abf3-dc43f3e68586	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.994161+08	\N	\N
37	load-18	e73d9765-ff9a-4483-820f-2f705d5535f9	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.996653+08	\N	\N
38	load-3	a36d8571-4d86-47ac-aad2-eff74613c6c9	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.996375+08	\N	\N
39	load-19	de51b143-0fd0-4348-923e-38f311129cdf	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:57.999291+08	\N	\N
40	load-20	34a9f47a-7a23-4102-9995-6f7f00aa7558	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.00166+08	\N	\N
41	load-1	e6d1de11-901a-4dd5-ae0d-f5665f0cb926	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.00553+08	\N	\N
42	load-13	a4e08271-e112-40f3-a116-9f9b6a28239a	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.008117+08	\N	\N
43	load-14	6ac6df42-35d8-4cc0-977a-2117c895f56f	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.011037+08	\N	\N
44	load-15	6dc01627-eed0-4823-8d82-87dba90de731	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.013507+08	\N	\N
47	load-17	845fdc22-0a3c-4a4f-ab8e-97f67aa0faa5	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.021757+08	\N	\N
50	load-19	bbc56ff4-7d1d-4c54-a074-366b707b9947	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.030716+08	\N	\N
53	load-13	bc5040a7-476b-4bc8-bafc-e5298c5e4b06	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.037799+08	\N	\N
56	load-16	6d5b5d23-2604-4211-beb8-e9986c008458	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.044567+08	\N	\N
58	load-18	d51a53e5-f7ac-4709-ba4e-b18199df2f6d	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.051198+08	\N	\N
62	load-19	7df77dde-b76a-4f23-bfb1-ed6163de117b	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.057325+08	\N	\N
66	load-14	d37ac4fa-b8d4-4bcd-94fc-ca66a85270e8	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.06804+08	\N	\N
70	load-18	2ab51af6-1e83-4736-8f07-ab1fb975af13	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.076335+08	\N	\N
74	load-19	6b8fc0a5-9d12-4e3d-9ebc-65f103e93760	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.085281+08	\N	\N
78	load-14	68493f52-a2aa-47fb-8f27-38b3383ecfec	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.094134+08	\N	\N
84	load-18	e39731a3-09db-4441-a214-48ad3bbc81ce	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.102197+08	\N	\N
89	load-1	85806d1f-70ae-4981-8cd3-3d55abbb884d	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.113925+08	\N	\N
94	load-5	1ad1b637-caae-48cc-81f2-ae789df3203c	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.129027+08	\N	\N
99	load-19	a111fcc1-d382-4a60-ac7c-61192fcc1d25	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.144585+08	\N	\N
108	load-14	6b371f5e-32f9-4f22-93d6-c49604d46aa2	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.159842+08	\N	\N
111	load-4	35796865-59a8-4c22-8e74-55121a5ef7ab	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.185216+08	\N	\N
117	load-6	2325f87e-cbb3-45ac-a8a9-c473b42f7dd9	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.193965+08	\N	\N
133	load-13	10d8f05c-179d-4276-b6d4-c86893da2ed8	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.21133+08	\N	\N
136	load-17	e7113fd0-41ad-4e43-a926-472afdbbe585	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.265872+08	\N	\N
147	load-6	db78fbd9-9d2b-4897-b246-ffe584e02e80	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.275838+08	\N	\N
45	load-16	44bb9bea-86b8-4c6c-9d2f-f6f85d3ae32c	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.015936+08	\N	\N
48	load-18	971918d5-b4ac-4080-a7f0-12648479d91d	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.024555+08	\N	\N
51	load-20	c50305e4-41d8-4fb3-b6b5-f2ab94239e52	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.033249+08	\N	\N
54	load-14	4f941719-ddde-44cf-8031-fe26eaa22cc5	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.039888+08	\N	\N
57	load-2	ff5a0306-6de7-4808-a46e-fcdfd74d7f4a	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.046664+08	\N	\N
60	load-3	1423146c-1f4e-489d-99c1-ac016af002c7	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.054693+08	\N	\N
64	load-1	a39068b8-2a5f-4ac4-b712-d847fcb13eb4	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.061712+08	\N	\N
67	load-16	a492608e-0fe9-484b-8fdd-685028bffeb7	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.072011+08	\N	\N
71	load-17	4db0e4c0-924a-4639-8e92-9a0f99397992	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.078679+08	\N	\N
75	load-20	9dae7b72-313b-4a8a-8edf-fc78fc19a6d8	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.087437+08	\N	\N
79	load-16	d57da699-41d6-4f68-86b5-58713a9d4aee	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.096371+08	\N	\N
85	load-17	6ad81104-a27b-4801-8357-01630c34f3c7	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.104068+08	\N	\N
92	load-13	d92ceb34-9a87-4ae7-8802-31f755b15cce	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.116756+08	\N	\N
97	load-18	8e580958-5e54-4870-8137-18cb24de05af	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.138823+08	\N	\N
102	load-1	67f9e0f1-fcf9-47f8-ab51-3a7d7954006d	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.154149+08	\N	\N
105	load-5	6f654276-58ec-4286-b76f-10efb4e73884	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.167892+08	\N	\N
112	load-18	941bb3cb-ba8b-4d89-895f-638d41b83ff1	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.177116+08	\N	\N
118	load-15	e798bcce-17ec-477f-869d-2dde0d4b4288	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.196942+08	\N	\N
138	load-3	dfa77437-8a6b-4d45-be6b-4cafb63ff95e	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.214618+08	\N	\N
141	load-7	9dd4d743-a6a3-419a-8464-288c7d3edf7b	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.28186+08	\N	\N
151	load-13	2481b776-7a2b-4160-9a5e-76a5eaea9c2e	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.291181+08	\N	\N
46	load-2	852035c8-1d33-4e04-a442-3d4a4c8d218b	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.018426+08	\N	\N
49	load-3	dcec69a9-46d6-4df2-98ac-8d2ca5a6991c	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.027917+08	\N	\N
52	load-1	fc699c20-8726-4905-8efd-f831aaf7b388	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.035303+08	\N	\N
55	load-15	b82ec1be-4e0a-4de3-8e4f-075ebad17393	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.042228+08	\N	\N
59	load-17	c8a0aaf1-3823-4c87-893b-98bb39632878	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.049082+08	\N	\N
61	load-4	9da12e29-2884-457d-b0d7-7ce7b3f07fc2	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.055146+08	\N	\N
63	load-20	72118a11-c8c3-495b-a5c8-0e8af88a43be	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.059533+08	\N	\N
65	load-13	fb4a5a89-0bcf-4685-8b9e-0d793f95eda0	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.065918+08	\N	\N
68	load-15	44063aa2-b691-46bc-9382-2e90804bd280	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.069831+08	\N	\N
69	load-2	945c8c61-93a5-49fa-a7b0-d1608ea00bc1	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.074305+08	\N	\N
72	load-3	2a573b10-2c18-4144-872f-b93ac575b65e	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.08105+08	\N	\N
73	load-4	2226767d-07d5-4021-aed9-409309dd9553	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.083419+08	\N	\N
76	load-1	d3b557e7-921a-499f-97d8-3340700fe39b	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.08942+08	\N	\N
77	load-13	b15b1893-ea0f-4e1c-a385-f65b088edb7f	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.091565+08	\N	\N
80	load-15	c6f626ef-233e-4c28-be0d-6abd209cc510	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.09823+08	\N	\N
81	load-5	ea9890c5-f17c-40b5-b406-ad902f8a70aa	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.09902+08	\N	\N
82	load-2	8e0d7c91-963e-4846-af2e-0841aedc074a	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.10013+08	\N	\N
83	load-3	e37467f3-21fe-46c1-b734-e289421ee55d	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.105917+08	\N	\N
86	load-19	3e2ef70e-125a-4790-9f73-713c03320d3b	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.110069+08	\N	\N
87	load-4	5ceeddee-5247-46e3-8134-7051da65292e	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.108696+08	\N	\N
88	load-20	24f74b0e-4eb6-4a4a-85e4-902e62595b52	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.112067+08	\N	\N
90	load-16	e8fc2f91-951b-4f32-8011-88c4b03775f3	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.122946+08	\N	\N
91	load-14	9d87e489-2a35-491d-8a96-7f2c26a209ab	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.119953+08	\N	\N
93	load-15	9799378c-ebb6-4daa-a00a-7aeccba7f0f3	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.12625+08	\N	\N
95	load-2	7fec5379-b238-4203-8962-d96cd8305580	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.131576+08	\N	\N
96	load-3	d5db76f3-4be9-499e-83b4-eee87d74a629	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.135968+08	\N	\N
98	load-17	48d5589a-9f51-409b-a649-b141b7f2e64f	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.141893+08	\N	\N
100	load-4	298cf7c5-f97e-49cc-8fee-f8ce35bc2a98	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.148016+08	\N	\N
101	load-16	07722d6b-4f7f-4056-a3fa-1422e242ed2c	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.156672+08	\N	\N
103	load-6	765170c1-61a1-4915-95d1-2c6cf2346502	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.157026+08	\N	\N
104	load-15	cf38d743-b30a-40e1-99a1-80ce15c40f1a	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.164958+08	\N	\N
106	load-20	be74696a-988e-4d53-a389-cd7e72f0d675	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.151274+08	\N	\N
107	load-2	40978286-6fb3-4b83-ac1b-3db6bc2f0e7d	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.171923+08	\N	\N
109	load-13	ad5282c0-68e0-45c1-a2ca-90e23c6efa88	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.162587+08	\N	\N
110	load-3	12e08f4b-2ae8-4a3e-a4d7-826482d2c008	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.173928+08	\N	\N
113	load-1	f61d3749-93ec-4a5b-8b01-bec27f4eca42	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.190727+08	\N	\N
114	load-17	b477b034-14ff-4003-a619-bfe176177eca	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.179626+08	\N	\N
115	load-19	a72b411f-4851-4e17-b3e6-3206947ca5d7	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.182467+08	\N	\N
116	load-16	ee7761e7-4d2f-4e95-bcf2-b0236fb264f0	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.188035+08	\N	\N
119	load-5	170b5870-7d5a-464d-aa62-5e2dbf348838	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.19999+08	\N	\N
120	load-20	1be26752-d3d2-4086-9dea-7dbd8262316f	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.202887+08	\N	\N
121	load-4	99c59095-7ec4-46a3-a7ce-5ffb278029d2	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.217778+08	\N	\N
122	load-2	25a3130c-63c4-474a-984f-bee350b53cc4	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.205869+08	\N	\N
123	load-18	e58c4875-42b1-40d2-b366-b0b4c466a3ca	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.222221+08	\N	\N
127	load-19	cb4e0f34-9c11-4e68-900f-3ff4834dc594	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.23115+08	\N	\N
140	load-5	827c5725-6730-4d66-b320-907a6e07ef11	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.243595+08	\N	\N
150	load-4	6dea4f6c-ecc7-4e26-b637-deee23e5ca34	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.288598+08	\N	\N
124	load-1	64f8e010-46e3-4e45-95cb-a1ca7c275f34	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.226006+08	\N	\N
129	load-16	9024f641-e3b3-4e75-9295-3f1b53ee6772	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.234029+08	\N	\N
132	load-4	270d3a96-47be-4d58-9990-095f545a5424	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.25058+08	\N	\N
135	load-1	3e54bdc8-2211-4fc0-b220-313288985098	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.261511+08	\N	\N
144	load-19	bc9adf4f-4277-4bc8-9f5c-8316c543b377	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.272683+08	\N	\N
125	load-17	5da0cff3-cf00-4154-ad07-2a3f21cacc22	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.228664+08	\N	\N
128	load-6	76c93e4b-9b71-4ee3-9639-df28ef39fac3	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.236861+08	\N	\N
131	load-20	85adc273-6777-4c1c-85e6-88a8dfdad5a1	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.247095+08	\N	\N
146	load-18	bc16d0ac-29d3-4916-8625-5bb1512eecf1	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.258751+08	\N	\N
126	load-14	5ac8409d-1013-4e55-8059-34fa116df937	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.208183+08	\N	\N
130	load-7	7806ef89-fb56-4dd1-8df1-073fe094dbca	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.220903+08	\N	\N
134	load-2	91d13e0e-6f8b-44f7-b9e8-da62a1fff972	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.255631+08	\N	\N
137	load-15	19bdffa8-7237-42cb-9849-64d75b617a17	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.240431+08	\N	\N
139	load-8	f85af5d2-4a3c-4d5e-a181-bdd1deeed7ed	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.271569+08	\N	\N
142	load-16	5eed3a4f-3c48-4cf2-9900-a55e524665f3	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.278666+08	\N	\N
143	load-20	c87ac259-abc1-4525-a8f1-c95dd5bd77e6	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.286331+08	\N	\N
145	load-2	fdd5c977-417b-4ba5-8787-cdc0e72e60d9	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.293698+08	\N	\N
148	load-15	4bb9487f-2a4a-46f9-aea4-9bd93ff53ef5	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.30322+08	\N	\N
149	load-14	22c5f2bd-8d89-4e02-822d-0a1c99cd84e5	994292b6af4949500ff85b9d32a616e1bb26277b61fee8bad2ffe4c1201f17a4	load-sku	1	10	10	created	2026-11-07 22:01:58.269394+08	\N	\N
\.


--
-- Data for Name: payment_events; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.payment_events (event_id, order_id, result, applied, note, received_at) FROM stdin;
46dabfef-1f3c-41f4-894f-bb6020a6270e	1	success	f	order_cancelled	2026-11-07 22:01:57.21262+08
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.schema_migrations (filename, applied_at) FROM stdin;
001_init.sql	2026-11-07 21:54:30.616181+08
\.


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: p03; Owner: -
--

SELECT pg_catalog.setval('p03.orders_id_seq', 151, true);


--
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (sku);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (order_id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: orders orders_user_id_idem_key_key; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.orders
    ADD CONSTRAINT orders_user_id_idem_key_key UNIQUE (user_id, idem_key);


--
-- Name: payment_events payment_events_pkey; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.payment_events
    ADD CONSTRAINT payment_events_pkey PRIMARY KEY (event_id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (filename);


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES p03.orders(id) ON DELETE CASCADE;


--
-- Name: payment_events payment_events_order_id_fkey; Type: FK CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.payment_events
    ADD CONSTRAINT payment_events_order_id_fkey FOREIGN KEY (order_id) REFERENCES p03.orders(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict Zgr00zfMvLzNwkpkvUksftWEVyLCDiLatf3kXnMU3Jjh9cbeK7QNQQYgAMylmsc

