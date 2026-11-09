--
-- PostgreSQL database dump
--

\restrict smMMOYENq2jGDmsQXgpgu6zxtT3HnyXlTHruZj5l1JkuXYIS7OUW6QEZrqK8v2J

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
-- Name: audit_log; Type: TABLE; Schema: p03; Owner: -
--

CREATE TABLE p03.audit_log (
    id bigint NOT NULL,
    actor text NOT NULL,
    action text NOT NULL,
    order_id integer,
    request_id text NOT NULL,
    before jsonb,
    after jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: p03; Owner: -
--

CREATE SEQUENCE p03.audit_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: p03; Owner: -
--

ALTER SEQUENCE p03.audit_log_id_seq OWNED BY p03.audit_log.id;


--
-- Name: inbox; Type: TABLE; Schema: p03; Owner: -
--

CREATE TABLE p03.inbox (
    consumer text NOT NULL,
    event_id text NOT NULL,
    processed_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: inventory; Type: TABLE; Schema: p03; Owner: -
--

CREATE TABLE p03.inventory (
    sku text NOT NULL,
    title text NOT NULL,
    unit_price integer NOT NULL,
    stock integer NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    CONSTRAINT inventory_stock_check CHECK ((stock >= 0)),
    CONSTRAINT inventory_unit_price_check CHECK ((unit_price > 0))
);


--
-- Name: notifications; Type: TABLE; Schema: p03; Owner: -
--

CREATE TABLE p03.notifications (
    event_id text NOT NULL,
    order_id integer NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
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
    status text DEFAULT 'pending_payment'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    paid_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    version integer DEFAULT 0 NOT NULL,
    shipped_at timestamp with time zone,
    completed_at timestamp with time zone,
    refunding_at timestamp with time zone,
    refunded_at timestamp with time zone,
    CONSTRAINT orders_amount_check CHECK ((amount > 0)),
    CONSTRAINT orders_qty_check CHECK ((qty > 0)),
    CONSTRAINT orders_status_check CHECK ((status = ANY (ARRAY['pending_payment'::text, 'paid'::text, 'shipped'::text, 'completed'::text, 'cancelled'::text, 'refunding'::text, 'refunded'::text]))),
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
-- Name: outbox; Type: TABLE; Schema: p03; Owner: -
--

CREATE TABLE p03.outbox (
    event_id text NOT NULL,
    type text NOT NULL,
    payload jsonb NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    sent_at timestamp with time zone,
    last_error text DEFAULT ''::text NOT NULL,
    CONSTRAINT outbox_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'sent'::text, 'dead'::text])))
);


--
-- Name: payment_attempts; Type: TABLE; Schema: p03; Owner: -
--

CREATE TABLE p03.payment_attempts (
    id integer NOT NULL,
    payment_id integer NOT NULL,
    attempt_no integer NOT NULL,
    result text NOT NULL,
    note text DEFAULT ''::text NOT NULL,
    latency_ms integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT payment_attempts_result_check CHECK ((result = ANY (ARRAY['succeeded'::text, 'failed'::text])))
);


--
-- Name: payment_attempts_id_seq; Type: SEQUENCE; Schema: p03; Owner: -
--

CREATE SEQUENCE p03.payment_attempts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: p03; Owner: -
--

ALTER SEQUENCE p03.payment_attempts_id_seq OWNED BY p03.payment_attempts.id;


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
    fingerprint text DEFAULT ''::text NOT NULL,
    CONSTRAINT payment_events_result_check CHECK ((result = ANY (ARRAY['success'::text, 'failed'::text])))
);


--
-- Name: payments; Type: TABLE; Schema: p03; Owner: -
--

CREATE TABLE p03.payments (
    id integer NOT NULL,
    order_id integer NOT NULL,
    amount integer NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    provider_ref text,
    attempts integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT payments_amount_check CHECK ((amount > 0)),
    CONSTRAINT payments_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'succeeded'::text, 'failed'::text, 'refunded'::text])))
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: p03; Owner: -
--

CREATE SEQUENCE p03.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: p03; Owner: -
--

ALTER SEQUENCE p03.payments_id_seq OWNED BY p03.payments.id;


--
-- Name: products; Type: TABLE; Schema: p03; Owner: -
--

CREATE TABLE p03.products (
    sku text NOT NULL,
    title text NOT NULL,
    price_cents integer NOT NULL,
    active boolean DEFAULT true NOT NULL,
    CONSTRAINT products_price_cents_check CHECK ((price_cents > 0))
);


--
-- Name: refunds; Type: TABLE; Schema: p03; Owner: -
--

CREATE TABLE p03.refunds (
    id integer NOT NULL,
    order_id integer NOT NULL,
    payment_id integer,
    amount integer NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    reason text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    settled_at timestamp with time zone,
    CONSTRAINT refunds_amount_check CHECK ((amount > 0)),
    CONSTRAINT refunds_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'succeeded'::text, 'failed'::text])))
);


--
-- Name: refunds_id_seq; Type: SEQUENCE; Schema: p03; Owner: -
--

CREATE SEQUENCE p03.refunds_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refunds_id_seq; Type: SEQUENCE OWNED BY; Schema: p03; Owner: -
--

ALTER SEQUENCE p03.refunds_id_seq OWNED BY p03.refunds.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: p03; Owner: -
--

CREATE TABLE p03.schema_migrations (
    filename text NOT NULL,
    applied_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: audit_log id; Type: DEFAULT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.audit_log ALTER COLUMN id SET DEFAULT nextval('p03.audit_log_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.orders ALTER COLUMN id SET DEFAULT nextval('p03.orders_id_seq'::regclass);


--
-- Name: payment_attempts id; Type: DEFAULT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.payment_attempts ALTER COLUMN id SET DEFAULT nextval('p03.payment_attempts_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.payments ALTER COLUMN id SET DEFAULT nextval('p03.payments_id_seq'::regclass);


--
-- Name: refunds id; Type: DEFAULT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.refunds ALTER COLUMN id SET DEFAULT nextval('p03.refunds_id_seq'::regclass);


--
-- Data for Name: audit_log; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.audit_log (id, actor, action, order_id, request_id, before, after, created_at) FROM stdin;
1	load-1	order.create	1	7eb834f7-f660-4f18-a678-feb3c4b72fb9	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.046677+08
2	load-13	order.create	2	4c0ca58a-68b5-41b7-86dc-e017aa323e78	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.07474+08
3	load-14	order.create	3	b404b3e7-067e-47a0-844d-1dee702592d1	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.091878+08
4	load-15	order.create	4	e41878fb-5f82-4c7f-9fc6-55cd5e38f9fb	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.100818+08
5	load-16	order.create	5	8edf82f2-cb24-4da2-960d-960e284b28f3	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.111805+08
6	load-17	order.create	6	c5858e86-a38d-490d-b801-10735e411a9f	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.120779+08
7	load-18	order.create	7	da27ba56-62e1-4686-82f3-5b0afb4f0ce8	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.129195+08
8	load-19	order.create	8	769d9d44-a220-42f5-a597-ecf978fbd972	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.139184+08
9	load-20	order.create	9	6ee9c1cc-85ff-44b1-acf6-4b987da36b40	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.146137+08
10	load-1	order.create	10	734fc1f8-d4e7-4302-8f33-21d28f7fc376	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.166622+08
11	load-13	order.create	11	06af7c15-fdee-4949-b259-172bfd4d85a8	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.174762+08
12	load-14	order.create	12	4e13df0a-8f72-4446-8001-7902e4d38a18	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.181896+08
13	load-15	order.create	13	d6ca9cc8-26f0-487c-952a-aaa59f12cd28	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.191085+08
14	load-16	order.create	14	faa4ca08-3d66-481b-8b28-160f6c607ae0	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.198976+08
15	load-17	order.create	15	8d290d29-d18d-4639-8c7b-ad453d8592da	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.205113+08
16	load-2	order.create	16	19ad0f86-949d-4471-8c6c-3fd8fb588e94	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.20563+08
17	load-18	order.create	17	5cd77ae3-7bbd-4fc7-a3e8-2f0a10036404	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.212113+08
18	load-19	order.create	18	032e7d97-c829-4d87-a77a-86d1aed1ebbb	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.217706+08
19	load-20	order.create	19	c8bfd9f7-5095-476b-85c1-9b5c04a31117	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.221444+08
20	load-1	order.create	20	dd4279b2-b2ff-4ac9-ac89-8a7bafeaff45	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.227939+08
21	load-13	order.create	21	983c19f5-4bc9-4c8b-9a5f-2cc0cea6046c	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.231248+08
22	load-14	order.create	22	45890024-4b20-4351-8ceb-b16856dcc4fa	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.235934+08
23	load-15	order.create	23	bba61035-0e71-4448-b2cf-5d6385d7b539	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.240356+08
24	load-16	order.create	24	59fa67ae-1248-439f-b530-7d557d4524b0	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.244906+08
25	load-3	order.create	25	e8d0c2cd-474a-4be5-a770-9a8cc999ed66	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.246878+08
26	load-17	order.create	26	1e840e17-142d-467e-b104-e39722b57457	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.249616+08
27	load-2	order.create	27	0daedb8f-eed3-4a92-b8e3-fc8f1d880bff	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.253028+08
28	load-18	order.create	28	301ecf56-3c24-49d2-a6b1-1a4830efabc8	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.259596+08
29	load-19	order.create	29	1b07bb14-b61f-4f7e-8241-1e2fdbd99462	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.263593+08
30	load-20	order.create	30	7a672400-6cc8-4c93-87db-84245f873dba	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.267598+08
31	load-1	order.create	31	3cb800e1-ecfd-4fab-a2ef-8857d66ea304	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.271536+08
32	load-13	order.create	32	915e8465-3736-4758-b422-2f65682e0c2e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.275332+08
33	load-14	order.create	33	bdd51eb8-5d7e-4c02-8363-d75223e2a0e1	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.280063+08
34	load-15	order.create	34	5ef012c8-5a11-47db-b355-39f74b8a964a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.284115+08
35	load-16	order.create	35	a65444eb-9e60-4523-b651-6571e0c36908	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.287897+08
36	load-3	order.create	36	a1a35a82-f958-4698-ac40-a1083af0c9e6	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.292161+08
37	load-17	order.create	37	a7263972-d0d2-4470-baab-53a4429d870c	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.29572+08
38	load-2	order.create	38	bab89af0-ec0c-47c0-889e-31672c855ce1	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.298986+08
39	load-18	order.create	39	f2564b76-85f9-487f-812c-51762b606107	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.302563+08
40	load-19	order.create	40	d3b480ce-e54f-4a97-abf0-4495095e84a6	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.305937+08
41	load-20	order.create	41	9b37c68f-5333-4909-924c-3b65d033d205	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.309969+08
42	load-1	order.create	42	e498f25d-40d1-4367-809e-020b8aa55876	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.31371+08
43	load-4	order.create	43	e2e64c84-6349-47d2-ba82-a31693dc5521	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.312612+08
44	load-13	order.create	44	023a6186-5b3d-4c42-b6c2-96c362504dd8	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.316833+08
45	load-14	order.create	45	65674d08-12f1-4f68-b3fb-8189d13d4afd	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.320648+08
46	load-15	order.create	46	7bd96860-a24b-46b8-8093-8df18ab3775a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.324905+08
50	load-2	order.create	50	20d8dd2f-26a2-438d-ac73-ab4f0b6e7ca5	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.341445+08
54	load-1	order.create	54	c7f8178c-0f26-4ebc-8549-f7408e2722d3	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.356315+08
59	load-15	order.create	59	40e4ecd8-f8c9-42cc-be6b-ac52eaa576c8	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.369785+08
63	load-18	order.create	63	08020e0b-9517-4063-a78f-4fa79da67557	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.384972+08
67	load-4	order.create	67	63315d92-1175-4b57-bcbe-154b02bfe467	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.397095+08
75	load-15	order.create	75	a6aecd17-2828-4b11-af4e-ab37406634de	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.407986+08
79	load-4	order.create	79	72221b64-70ce-4486-85c2-43e635e01745	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.431369+08
83	load-6	order.create	83	19208c1c-03eb-4ba8-875e-1fea39ef45c3	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.443792+08
85	load-15	order.create	85	5dfc2b65-9561-4863-97d0-67e2336819e3	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.455038+08
89	load-19	order.create	89	6ddf6e1d-fd2b-4ac0-b0aa-bb946b64b78c	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.461187+08
94	load-13	order.create	94	f94c28a3-71fb-4c42-a96a-3f4777a4a347	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.470488+08
98	load-14	order.create	98	df59fe42-5dda-4011-993c-6e654f78582b	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.486013+08
111	load-17	order.create	111	9389ec08-852b-4873-bd23-093b93a26a1f	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.498174+08
127	load-7	order.create	127	50e58d1e-7b3f-45ce-a6e7-0d2635e6bd00	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.53277+08
137	load-6	order.create	137	5042c192-1206-4a0a-bb84-107ec21dfd99	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.58623+08
47	load-3	order.create	47	0e98808b-5f53-4eda-9191-79325fbf1063	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.333979+08
51	load-18	order.create	51	a385c49f-12b6-44f0-b66c-0ce6b00e1641	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.344834+08
55	load-4	order.create	55	c3af7ee9-0ae8-4d08-8acd-acba12dc552d	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.359978+08
60	load-3	order.create	60	7b55d185-0657-4f9a-b54a-91f8984d39fb	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.372749+08
66	load-20	order.create	66	3e1ef033-dac7-4652-a68a-71e4670ad466	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.387765+08
74	load-14	order.create	74	13bc1e74-0679-43db-a68b-2261504db195	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.405512+08
82	load-20	order.create	82	c6d95a0f-2365-4ae0-b3ff-72af244cfb73	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.428802+08
86	load-14	order.create	86	b56e4c63-1d4a-414f-b5a6-b02c3d95c155	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.452659+08
88	load-18	order.create	88	a6f9e5b6-d9b4-458e-84c7-b181ecb036c7	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.463319+08
104	load-16	order.create	104	b381a5e0-5503-4db9-aa70-f6cdbe69f636	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.468269+08
115	load-3	order.create	115	eb745bd3-5011-4597-873d-6a21851ddc5e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.514722+08
119	load-6	order.create	119	1a1d760f-b4e8-4863-9272-a350f56b1f9c	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.546473+08
132	load-17	order.create	132	4a0b4999-3c02-4fa1-8690-9f8dc7afbfdb	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.560233+08
134	load-18	order.create	134	9740e5fd-4edd-4b6a-8071-433bac377e69	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.602127+08
139	load-4	order.create	139	26a75775-6a34-46ec-9d27-115ee81b08bc	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.607904+08
143	load-15	order.create	143	b2c85a68-820f-4f86-8eeb-3a4b1f317d2b	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.62301+08
146	load-8	order.create	146	ff0190ee-7d12-4013-9dc3-8c4dbe26b9f0	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.633431+08
48	load-16	order.create	48	67c1c0d4-fd48-4e97-a60b-41c01d9ba901	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.331123+08
53	load-19	order.create	53	ed10c495-cd50-4386-979d-7d8a891215a0	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.348132+08
58	load-14	order.create	58	65cb2028-43d3-4a1a-b0af-103fc811ea9a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.366848+08
62	load-2	order.create	62	0fec87e2-42de-42de-be6a-90e2bb6adaaf	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.382118+08
70	load-1	order.create	70	763ce2eb-3d75-48f5-9ee1-f976027d0eeb	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.393941+08
73	load-2	order.create	73	fce5608d-a9f5-4a5f-a3bc-f069f194dac6	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.41579+08
77	load-19	order.create	77	a102b3e3-c224-482b-b44b-57ad2c3eb59e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.426281+08
95	load-5	order.create	95	1ca7790d-6b90-4ce1-8cb4-b6e829225983	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.437589+08
99	load-2	order.create	99	690b2c32-e9c9-4480-b39d-378b77109203	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.488826+08
102	load-4	order.create	102	468c84a8-e5c7-4e7f-b174-3762a8ff907b	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.500592+08
106	load-13	order.create	106	e65ba6cf-875b-4162-923c-fb766f7635dd	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.510045+08
110	load-14	order.create	110	8287284c-7539-4ae6-ae4b-63b08648b7b7	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.520109+08
126	load-4	order.create	126	9f6defbf-b0c6-4410-9123-ad1f44d32040	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.53056+08
128	load-13	order.create	128	7877c166-b128-4578-afa5-7a20776f1bbd	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.582747+08
150	load-2	order.create	150	3a4330fe-7402-4a81-918b-40c921a1ab51	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.589034+08
49	load-17	order.create	49	105bfd8c-598a-4692-bfdf-5b8bb74e3998	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.337552+08
52	load-20	order.create	52	50a06c41-7131-4d82-9167-85d27b50142d	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.352903+08
56	load-13	order.create	56	ee6402f5-1a1a-4ef8-aaf9-a07c2d3e2702	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.363847+08
57	load-5	order.create	57	a9cd9973-a62a-4a36-bf79-252824946859	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.362302+08
61	load-17	order.create	61	39114176-a43d-4f56-9d2a-6cef20f4cd9e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.37954+08
64	load-16	order.create	64	b7c72aad-86b9-4a7b-9be0-0100ab525b5a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.375106+08
65	load-19	order.create	65	3a55e02d-9481-4377-8d1f-9aee38dde19b	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.390763+08
68	load-13	order.create	68	4a166159-eccc-464a-953f-793fdd1fd6d4	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.400122+08
69	load-5	order.create	69	26900b43-49d0-4635-957c-9b4e94d800d2	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.402948+08
71	load-6	order.create	71	28ba19da-1d40-4a28-9c67-4249823c4f97	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.399312+08
72	load-3	order.create	72	d05cc9c7-030a-430c-96a6-3bdf5fb72c29	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.410633+08
76	load-17	order.create	76	d1ba5063-0fbd-41b9-925a-0d416b521f3e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.413161+08
78	load-18	order.create	78	f6cd298b-9d7d-48bd-9184-44ed8e921829	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.420243+08
80	load-16	order.create	80	63e996db-a925-40c7-bcdd-fa7cdb1b1834	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.422347+08
81	load-13	order.create	81	6ea13e70-df1c-459b-bf52-b7f571666d0b	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.434153+08
84	load-3	order.create	84	6ecb39d6-d0a4-4265-9be8-37854208f8a8	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.446636+08
87	load-2	order.create	87	698c55df-ffa3-45a4-a8ab-5ea0a2a71694	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.45+08
90	load-17	order.create	90	3e956057-b1c1-401a-8c7e-e7207ba38582	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.457696+08
91	load-4	order.create	91	c1005d6b-766e-47bd-9db3-7150ecc32498	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.466037+08
92	load-7	order.create	92	7ebef26d-d888-4adf-b2a6-5072fdb01ba0	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.454616+08
93	load-1	order.create	93	516f9467-8d19-458c-9152-1f35d4a30039	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.440772+08
96	load-3	order.create	96	80fff29b-754b-4361-9811-d91a1ad868aa	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.480633+08
97	load-15	order.create	97	ef2885cf-cae0-4443-89d5-bdc8e4f2bd29	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.482891+08
100	load-18	order.create	100	aedd6c03-0b28-4df3-a55b-5699f1a2205d	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.491906+08
101	load-19	order.create	101	0a68f915-d117-4c79-9320-2371ae84e512	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.494504+08
103	load-7	order.create	103	aa670f73-5c88-4ce4-b556-bd13730f591d	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.503655+08
105	load-1	order.create	105	2d49c016-71a8-46f4-a29d-fa730ce0cffe	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.506911+08
107	load-6	order.create	107	50dd759c-d758-432b-9f8e-b2079d236c52	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.475478+08
108	load-20	order.create	108	33d1709b-ee10-45ce-aeda-1c0f20cc39a0	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.472858+08
109	load-15	order.create	109	841c977d-5da2-40ff-8c0d-e3c4dd4ca4e1	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.517853+08
112	load-18	order.create	112	235f43cc-7c20-4b32-96e7-163eeccb35db	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.525285+08
113	load-19	order.create	113	00ad8aa6-3499-47c3-8201-a5f68df6745c	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.527956+08
114	load-8	order.create	114	96bffeb6-4ace-4694-bf99-00e7df837a49	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.511712+08
116	load-16	order.create	116	94b03d18-eb9a-44a4-bf47-ef27339e17be	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.535778+08
117	load-1	order.create	117	2f0ff2d3-1239-4683-bc57-a23c51adbcb3	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.538296+08
118	load-13	order.create	118	7ffc7940-6afe-4191-89c7-e7a55b6ca4d1	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.544357+08
120	load-2	order.create	120	91215e74-8aba-42ae-8933-deb891a2a449	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.522472+08
121	load-9	order.create	121	476dc2d6-0ed5-41f3-bd52-935b90018742	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.555636+08
122	load-5	order.create	122	c34bc7cc-4750-4198-93f7-6c71f06640b4	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.512477+08
123	load-14	order.create	123	7b6b4fe7-7883-48f0-9dc1-ba6f4ac7d660	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.556535+08
124	load-18	order.create	124	809ace11-7d65-4066-8018-8404f9a50d2a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.562787+08
125	load-19	order.create	125	18fddf10-da41-45f1-8955-c697bdfe4f7d	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.567533+08
129	load-20	order.create	129	b1a67e2c-1836-4e60-bb5f-bb4d94080447	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.549894+08
130	load-16	order.create	130	39a60add-5378-4715-a1c8-f4f6738f663a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.57746+08
131	load-15	order.create	131	a0f5c9a7-6e2e-4474-bea3-345ad7f8a24c	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.553702+08
133	load-9	order.create	133	3d1b7424-91e3-4a1d-ba28-4de68499ed57	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.591878+08
135	load-8	order.create	135	0fa9b57b-cb55-4da9-834e-69ed409130b4	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.569781+08
136	load-3	order.create	136	920d3810-6a08-4a0e-af8e-2db9d5f14cad	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.572981+08
141	load-13	order.create	141	e384a45d-2d61-47ec-9533-fde348fb0cc0	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.613581+08
145	load-9	order.create	145	b42ed703-bac8-4176-9f61-598a68af353c	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.627977+08
138	load-19	order.create	138	47218ef4-0d2d-4256-addb-943f55bf39e9	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.605159+08
140	load-16	order.create	140	caec0416-2286-4c11-af03-abac3d35ca75	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.619821+08
142	load-1	order.create	142	d4ac6631-c0bc-4912-9cf0-87448e54f9f2	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.580085+08
144	load-10	order.create	144	1f123105-f71c-40a8-a578-9ea08e346e3e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.624574+08
148	load-3	order.create	148	e603167f-cdf8-45f0-b70a-717bc96c854e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.638318+08
147	load-5	order.create	147	c11e680b-2766-434c-b244-83fe3fdde3ae	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.594785+08
149	load-14	order.create	149	e82391fd-418d-4809-9913-51c08176de19	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:21:24.598557+08
151	mq-user	order.create	1	f1a7c963-34a5-4b02-8006-2095d6426cf7	\N	{"qty": 1, "sku": "mq-sku", "amount": 100}	2026-11-09 11:21:25.367141+08
152	provider	payment.callback	1	211a2ad9-edc5-4e0a-b28a-32719e98c527	{"status": "pending_payment"}	{"status": "paid"}	2026-11-09 11:21:25.382761+08
153	mq-runtime	order.create	2	97dead70-badb-4da3-835c-d07f0759b9cd	\N	{"qty": 1, "sku": "mq-runtime-sku", "amount": 100}	2026-11-09 11:21:27.443458+08
154	mq-runtime	order.pay	2	9cd9c62f-39bd-4f96-aad1-3b9dd6fa5cdb	{"status": "pending_payment"}	{"status": "paid", "payment_id": 1}	2026-11-09 11:21:27.459233+08
155	fault-user	order.create	3	ffdb3e6f-e37c-4ea7-af1f-0a29d47fa8fe	\N	{"qty": 1, "sku": "fault-sku", "amount": 100}	2026-11-09 11:21:28.576339+08
156	fault-user	order.create	4	c8f1d7b2-f788-4a44-b9b5-1b9c166984a6	\N	{"qty": 1, "sku": "fault-sku", "amount": 100}	2026-11-09 11:21:29.178537+08
157	fault-user	order.pay	4	e694fd33-9112-4e99-9db1-a0d665a88fcc	{"status": "pending_payment"}	{"status": "paid", "payment_id": 2}	2026-11-09 11:21:29.190916+08
\.


--
-- Data for Name: inbox; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.inbox (consumer, event_id, processed_at) FROM stdin;
notify-worker	pay-2	2026-11-09 11:21:29.534944+08
\.


--
-- Data for Name: inventory; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.inventory (sku, title, unit_price, stock, version) FROM stdin;
mq-sku	MQ 商品	100	9	1
mq-runtime-sku	MQ 运行期商品	100	4	1
fault-sku	故障演练商品	100	3	2
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.notifications (event_id, order_id, message, created_at) FROM stdin;
mq-paid-1	1	订单 1 已支付	2026-11-09 11:21:25.392101+08
bulk-2	1	订单 1 已支付	2026-11-09 11:21:26.218867+08
bulk-1	1	订单 1 已支付	2026-11-09 11:21:26.218773+08
bulk-11	1	订单 1 已支付	2026-11-09 11:21:26.223932+08
bulk-12	1	订单 1 已支付	2026-11-09 11:21:26.224027+08
bulk-13	1	订单 1 已支付	2026-11-09 11:21:26.225398+08
bulk-14	1	订单 1 已支付	2026-11-09 11:21:26.225542+08
bulk-15	1	订单 1 已支付	2026-11-09 11:21:26.226939+08
bulk-16	1	订单 1 已支付	2026-11-09 11:21:26.227146+08
bulk-17	1	订单 1 已支付	2026-11-09 11:21:26.228284+08
bulk-18	1	订单 1 已支付	2026-11-09 11:21:26.22841+08
bulk-19	1	订单 1 已支付	2026-11-09 11:21:26.22947+08
bulk-20	1	订单 1 已支付	2026-11-09 11:21:26.229554+08
bulk-21	1	订单 1 已支付	2026-11-09 11:21:26.230503+08
bulk-22	1	订单 1 已支付	2026-11-09 11:21:26.230831+08
bulk-23	1	订单 1 已支付	2026-11-09 11:21:26.231384+08
bulk-24	1	订单 1 已支付	2026-11-09 11:21:26.232391+08
bulk-25	1	订单 1 已支付	2026-11-09 11:21:26.232862+08
bulk-26	1	订单 1 已支付	2026-11-09 11:21:26.233687+08
bulk-27	1	订单 1 已支付	2026-11-09 11:21:26.233814+08
bulk-28	1	订单 1 已支付	2026-11-09 11:21:26.234778+08
bulk-29	1	订单 1 已支付	2026-11-09 11:21:26.234887+08
bulk-30	1	订单 1 已支付	2026-11-09 11:21:26.235755+08
bulk-3	1	订单 1 已支付	2026-11-09 11:21:26.356451+08
bulk-4	1	订单 1 已支付	2026-11-09 11:21:26.396393+08
bulk-5	1	订单 1 已支付	2026-11-09 11:21:26.427118+08
bulk-6	1	订单 1 已支付	2026-11-09 11:21:26.477291+08
bulk-7	1	订单 1 已支付	2026-11-09 11:21:26.534338+08
bulk-8	1	订单 1 已支付	2026-11-09 11:21:26.589585+08
bulk-9	1	订单 1 已支付	2026-11-09 11:21:26.627977+08
bulk-10	1	订单 1 已支付	2026-11-09 11:21:26.664701+08
pay-1	2	订单 2 已支付	2026-11-09 11:21:27.769635+08
pay-2	4	订单 4 已支付 100 分	2026-11-09 11:21:29.534944+08
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.order_items (order_id, sku, title, unit_price, qty) FROM stdin;
1	mq-sku	MQ 商品	100	1
2	mq-runtime-sku	MQ 运行期商品	100	1
3	fault-sku	故障演练商品	100	1
4	fault-sku	故障演练商品	100	1
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.orders (id, user_id, idem_key, request_hash, sku, qty, unit_price, amount, status, created_at, paid_at, cancelled_at, version, shipped_at, completed_at, refunding_at, refunded_at) FROM stdin;
1	mq-user	mq-order-1	d559ac7ca035b4385a99fc7ba1dfe3f04c6bfa895c66dec470f64d2c52865b95	mq-sku	1	100	100	paid	2026-11-09 11:21:25.367141+08	2026-11-09 11:21:25.382761+08	\N	1	\N	\N	\N	\N
2	mq-runtime	mq-runtime-1794194487343	60c5257fde15f10651185f852305172cc2dd40f076dc99ef0ab6ad1b9d223187	mq-runtime-sku	1	100	100	paid	2026-11-09 11:21:27.443458+08	2026-11-09 11:21:27.459233+08	\N	1	\N	\N	\N	\N
3	fault-user	db-recovered-1794194488575	770533cc18e07deb3d53885bd4e6fd3fa97f322259291a7a5457424b2a9acdc0	fault-sku	1	100	100	pending_payment	2026-11-09 11:21:28.576339+08	\N	\N	0	\N	\N	\N	\N
4	fault-user	mq-down-1794194489172	770533cc18e07deb3d53885bd4e6fd3fa97f322259291a7a5457424b2a9acdc0	fault-sku	1	100	100	paid	2026-11-09 11:21:29.178537+08	2026-11-09 11:21:29.190916+08	\N	1	\N	\N	\N	\N
\.


--
-- Data for Name: outbox; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.outbox (event_id, type, payload, status, attempts, created_at, sent_at, last_error) FROM stdin;
mq-paid-1	order.paid	{"amount": 100, "user_id": "mq-user", "event_id": "mq-paid-1", "order_id": 1}	sent	1	2026-11-09 11:21:25.382761+08	2026-11-09 11:21:25.389813+08	
pay-1	order.paid	{"amount": 100, "user_id": "mq-runtime", "event_id": "pay-1", "order_id": 2}	sent	1	2026-11-09 11:21:27.459233+08	2026-11-09 11:21:27.767451+08	
pay-2	order.paid	{"amount": 100, "user_id": "fault-user", "event_id": "pay-2", "order_id": 4}	sent	0	2026-11-09 11:21:29.190916+08	2026-11-09 11:21:29.534944+08	
\.


--
-- Data for Name: payment_attempts; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.payment_attempts (id, payment_id, attempt_no, result, note, latency_ms, created_at) FROM stdin;
1	1	1	succeeded	gateway_ok	0	2026-11-09 11:21:27.459233+08
2	2	1	succeeded	gateway_ok	0	2026-11-09 11:21:29.190916+08
\.


--
-- Data for Name: payment_events; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.payment_events (event_id, order_id, result, applied, note, received_at, fingerprint) FROM stdin;
mq-paid-1	1	success	t	paid	2026-11-09 11:21:25.382761+08	dcfe98d6f9ca981b465c5f449e37e45d3ab2a5814e4f5cfbd5d6a980f189be18
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.payments (id, order_id, amount, status, provider_ref, attempts, created_at, updated_at) FROM stdin;
1	2	100	succeeded	mock-2-100	1	2026-11-09 11:21:27.459233+08	2026-11-09 11:21:27.459233+08
2	4	100	succeeded	mock-4-100	1	2026-11-09 11:21:29.190916+08	2026-11-09 11:21:29.190916+08
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.products (sku, title, price_cents, active) FROM stdin;
sku-1	机械键盘	299	t
load-sku	压测商品	1000	t
mq-sku	MQ 商品	100	t
mq-runtime-sku	MQ 运行期商品	100	t
fault-sku	故障演练商品	100	t
\.


--
-- Data for Name: refunds; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.refunds (id, order_id, payment_id, amount, status, reason, created_at, settled_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.schema_migrations (filename, applied_at) FROM stdin;
001_init.sql	2026-11-07 21:54:30.616181+08
002_outbox.sql	2026-11-07 22:33:01.843633+08
003_full_model.sql	2026-11-09 08:42:16.204653+08
004_event_fingerprint.sql	2026-11-09 08:43:14.908171+08
\.


--
-- Name: audit_log_id_seq; Type: SEQUENCE SET; Schema: p03; Owner: -
--

SELECT pg_catalog.setval('p03.audit_log_id_seq', 157, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: p03; Owner: -
--

SELECT pg_catalog.setval('p03.orders_id_seq', 4, true);


--
-- Name: payment_attempts_id_seq; Type: SEQUENCE SET; Schema: p03; Owner: -
--

SELECT pg_catalog.setval('p03.payment_attempts_id_seq', 2, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: p03; Owner: -
--

SELECT pg_catalog.setval('p03.payments_id_seq', 2, true);


--
-- Name: refunds_id_seq; Type: SEQUENCE SET; Schema: p03; Owner: -
--

SELECT pg_catalog.setval('p03.refunds_id_seq', 1, false);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: inbox inbox_pkey; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.inbox
    ADD CONSTRAINT inbox_pkey PRIMARY KEY (consumer, event_id);


--
-- Name: inventory inventory_pkey; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (sku);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (event_id);


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
-- Name: outbox outbox_pkey; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.outbox
    ADD CONSTRAINT outbox_pkey PRIMARY KEY (event_id);


--
-- Name: payment_attempts payment_attempts_payment_id_attempt_no_key; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.payment_attempts
    ADD CONSTRAINT payment_attempts_payment_id_attempt_no_key UNIQUE (payment_id, attempt_no);


--
-- Name: payment_attempts payment_attempts_pkey; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.payment_attempts
    ADD CONSTRAINT payment_attempts_pkey PRIMARY KEY (id);


--
-- Name: payment_events payment_events_pkey; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.payment_events
    ADD CONSTRAINT payment_events_pkey PRIMARY KEY (event_id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (sku);


--
-- Name: refunds refunds_pkey; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.refunds
    ADD CONSTRAINT refunds_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (filename);


--
-- Name: audit_order_idx; Type: INDEX; Schema: p03; Owner: -
--

CREATE INDEX audit_order_idx ON p03.audit_log USING btree (order_id, created_at);


--
-- Name: outbox_pending_idx; Type: INDEX; Schema: p03; Owner: -
--

CREATE INDEX outbox_pending_idx ON p03.outbox USING btree (created_at) WHERE (status = 'pending'::text);


--
-- Name: inventory inventory_sku_fkey; Type: FK CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.inventory
    ADD CONSTRAINT inventory_sku_fkey FOREIGN KEY (sku) REFERENCES p03.products(sku);


--
-- Name: notifications notifications_order_id_fkey; Type: FK CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.notifications
    ADD CONSTRAINT notifications_order_id_fkey FOREIGN KEY (order_id) REFERENCES p03.orders(id) ON DELETE CASCADE;


--
-- Name: order_items order_items_order_id_fkey; Type: FK CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.order_items
    ADD CONSTRAINT order_items_order_id_fkey FOREIGN KEY (order_id) REFERENCES p03.orders(id) ON DELETE CASCADE;


--
-- Name: payment_attempts payment_attempts_payment_id_fkey; Type: FK CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.payment_attempts
    ADD CONSTRAINT payment_attempts_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES p03.payments(id) ON DELETE CASCADE;


--
-- Name: payment_events payment_events_order_id_fkey; Type: FK CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.payment_events
    ADD CONSTRAINT payment_events_order_id_fkey FOREIGN KEY (order_id) REFERENCES p03.orders(id) ON DELETE CASCADE;


--
-- Name: payments payments_order_id_fkey; Type: FK CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.payments
    ADD CONSTRAINT payments_order_id_fkey FOREIGN KEY (order_id) REFERENCES p03.orders(id) ON DELETE CASCADE;


--
-- Name: refunds refunds_order_id_fkey; Type: FK CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.refunds
    ADD CONSTRAINT refunds_order_id_fkey FOREIGN KEY (order_id) REFERENCES p03.orders(id) ON DELETE CASCADE;


--
-- Name: refunds refunds_payment_id_fkey; Type: FK CONSTRAINT; Schema: p03; Owner: -
--

ALTER TABLE ONLY p03.refunds
    ADD CONSTRAINT refunds_payment_id_fkey FOREIGN KEY (payment_id) REFERENCES p03.payments(id);


--
-- PostgreSQL database dump complete
--

\unrestrict smMMOYENq2jGDmsQXgpgu6zxtT3HnyXlTHruZj5l1JkuXYIS7OUW6QEZrqK8v2J

