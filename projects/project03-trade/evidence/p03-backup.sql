--
-- PostgreSQL database dump
--

\restrict eZG4NqIfno8c4p2WLLuj4wQ98uKRk5nvLHXF1YO7FiWk3Odastl7mp2DZ7rgxxq

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
1	alice	order.create	1	e2967663-0a85-44c0-9b90-0cf4fa36a915	\N	{"qty": 2, "sku": "sku-1", "amount": 598}	2026-11-09 11:14:55.971937+08
2	alice	order.cancel	1	25b8ea90-c606-4277-8fb8-38d3a5fa6527	{"status": "pending_payment"}	{"status": "cancelled"}	2026-11-09 11:14:55.978755+08
3	load-1	order.create	2	9646367c-19c4-47fa-b1c1-44793efd80bc	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.526331+08
4	load-13	order.create	3	f7fbeb91-b365-4af9-bce2-e0235069efe1	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.545966+08
5	load-14	order.create	4	6df5e92d-849c-4365-8178-c2286c9545ea	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.556225+08
6	load-15	order.create	5	53acfc49-ae8a-4bf1-931f-b3fb54a657d2	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.562379+08
7	load-16	order.create	6	b02f7694-bce2-42e5-81ec-9e9ff7eafbab	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.569381+08
8	load-17	order.create	7	b9f6666a-32c5-4457-b6ec-f36639b9ddc3	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.575364+08
9	load-18	order.create	8	57ac225e-e132-4d3e-8837-94882e6ff367	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.582727+08
10	load-19	order.create	9	2cbe4af4-3299-4f52-a723-5ecff5063da5	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.588364+08
11	load-20	order.create	10	9f3cdfec-7c45-4664-8736-85d561a5821b	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.5949+08
12	load-1	order.create	11	7cfdb2b9-fbc0-4aa5-aa80-17b81b9a5f40	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.600353+08
13	load-13	order.create	12	2f8431d6-52dc-4c88-9baa-19d1736e9ad4	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.605698+08
14	load-14	order.create	13	22eb201e-c850-4c6e-ba8d-c0bf15e79036	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.611168+08
15	load-15	order.create	14	6f46e950-2cec-413e-8685-c51fb9587fac	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.616914+08
16	load-16	order.create	15	edf734b0-fbce-49a2-872b-a1b3d51a839d	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.621805+08
17	load-17	order.create	16	ea64d6ab-aeb4-449e-98c7-3afe1ae8f941	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.626634+08
18	load-18	order.create	17	ac3e9c4b-5f35-4212-8438-a6860aa8b2ac	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.632881+08
19	load-19	order.create	18	75a6758e-181d-4720-af72-0d75dd7afa5b	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.638087+08
20	load-20	order.create	19	4a849df2-4d6d-4409-930f-ecf835c62043	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.643949+08
21	load-1	order.create	20	23c0e19e-1696-49f7-b9dc-c03427ae344d	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.650627+08
22	load-13	order.create	21	e6fc5b45-dcdf-4565-9c9a-f78ae6ea4024	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.656559+08
23	load-2	order.create	22	1184aae0-aeda-425b-a1c5-0f7b99a6ee88	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.65772+08
24	load-14	order.create	23	b6acae13-5a1b-4799-9ce4-084285d465d7	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.661953+08
25	load-15	order.create	24	c86dc746-88bf-4ec4-8563-776749cfc0a6	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.667421+08
26	load-16	order.create	25	a524367b-116b-4f68-a333-38150060e0b3	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.66977+08
27	load-17	order.create	26	2eb7e445-da39-4415-b921-7bcb6640b9c6	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.673795+08
28	load-18	order.create	27	a31b4e8a-3479-4778-93d0-93f1078e7883	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.676329+08
29	load-19	order.create	28	0d6246f0-6270-438e-ab69-a0577a272b3e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.679782+08
30	load-20	order.create	29	b71cee58-d031-4b7e-adf4-4b60450dd039	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.6826+08
31	load-1	order.create	30	26c1ef63-6854-4c4b-96af-2df9299466ef	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.686964+08
32	load-13	order.create	31	03406b97-a73e-4dc1-b4bc-52901c2c69e1	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.690157+08
33	load-2	order.create	32	5638ef51-9007-4e2d-b040-8c359dbd9162	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.693223+08
34	load-14	order.create	33	56ad7f01-c316-4117-be2c-7a7a7395e60f	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.696267+08
35	load-15	order.create	34	00f941f5-f7a9-4292-bed5-32dc3b15c4ff	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.698957+08
36	load-16	order.create	35	bbd902b8-e98b-44fc-8820-8b43eef3a739	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.701981+08
37	load-17	order.create	36	b08803a3-b36d-4312-8cbb-e95a3d173094	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.705455+08
38	load-3	order.create	37	97a59561-b44a-41ea-ab27-56d4d2b7b6a9	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.706664+08
39	load-18	order.create	38	9d1a6d13-64ac-42cc-b5ea-4e41945acdb1	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.707858+08
40	load-19	order.create	39	dbc63c39-f87f-4043-a1b2-923d1b8ab7c9	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.71139+08
41	load-20	order.create	40	dfc9e427-c787-4335-9ae2-5ac42acfbb63	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.715834+08
42	load-1	order.create	41	db19aa9b-bdaf-4b0c-acd9-f8785d404cab	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.717809+08
43	load-13	order.create	42	7541e25a-97cf-43af-9751-aad930ad8888	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.720541+08
44	load-2	order.create	43	72780f96-9639-49f4-8d84-aafee25847c5	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.723144+08
45	load-14	order.create	44	9848e543-862e-4f69-b799-e3207a422d04	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.726572+08
46	load-15	order.create	45	f503b3da-e9fb-4587-92c8-394686e2a0be	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.729412+08
49	load-3	order.create	48	ac9babb1-ace8-4ff6-87d8-83f30e1314eb	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.738649+08
52	load-20	order.create	51	31214b1e-0c99-45c5-a59d-56855c5edac2	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.746797+08
55	load-2	order.create	54	ffe3ea29-a95d-4bb3-834d-45f89184d424	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.75551+08
58	load-16	order.create	57	466f13e0-6a51-40d3-b15e-09202f6c4666	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.763409+08
61	load-18	order.create	60	ec9691ae-d5d2-43f6-8b2c-91e3af834885	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.770261+08
64	load-1	order.create	63	899b8dde-aa8b-416c-8573-0cf00aa3fd8b	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.778013+08
67	load-14	order.create	66	5f96e0da-4e09-4b1c-aa59-0efab5d5ec7f	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.785443+08
70	load-17	order.create	69	73a9b59d-1111-4bff-a32d-11eac704d62b	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.792603+08
73	load-19	order.create	72	2b867857-6e50-4a6f-ac8a-60f8e1fd9819	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.799393+08
79	load-13	order.create	78	8c91ad7b-aa24-462c-af28-3a16c233f5a7	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.806153+08
82	load-3	order.create	81	38f87b62-a818-456a-ade0-bed77a8c15af	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.822675+08
87	load-20	order.create	86	d5bbaca2-49a5-4d21-88d4-c48ef0b2c563	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.830283+08
91	load-13	order.create	90	c618d381-74b1-4a02-8092-ffd30f11b7d4	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.843201+08
94	load-17	order.create	93	635bb67d-66d8-4769-a606-b783e8a63223	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.853431+08
98	load-1	order.create	97	83a4eb20-595e-43ff-9a09-da55fac3bc83	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.861684+08
101	load-2	order.create	100	f6a4cca6-68ed-4683-82fe-205f60b17d9a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.872366+08
106	load-15	order.create	105	895d714e-6362-41bd-95a3-47e83233b331	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.880656+08
111	load-1	order.create	110	39c737db-8157-49e4-afbb-b97cde99d1c1	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.898975+08
115	load-16	order.create	114	660a9ff6-1955-494b-ac1b-0a74284ecbca	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.917643+08
119	load-3	order.create	118	0cc8bfeb-c5ee-45ed-983b-fe2d0240d933	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.930166+08
122	load-1	order.create	121	dd132ba2-19a6-4949-aa7e-84e9676cc565	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.943128+08
129	load-14	order.create	128	222f5622-bde6-4e74-a540-49f063d349f3	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.95514+08
135	load-5	order.create	134	c6974d54-b81f-46a3-9c0d-085bbb9fe304	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.980597+08
139	load-2	order.create	138	88fa504a-4356-4b51-91b0-85c002fab8bb	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:57.000189+08
148	load-3	order.create	147	4f854ac2-c061-49b3-b796-c270a43debc7	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:57.013919+08
152	load-4	order.create	151	075a97dd-2aa3-484f-9032-fe62ead4f632	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:57.04252+08
47	load-16	order.create	46	309f72e6-4862-42a2-8e6f-fa7ac2001198	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.732728+08
50	load-18	order.create	49	9d4483b5-82a8-49d7-8e59-40d73b542484	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.741558+08
53	load-1	order.create	52	9178b503-bef6-46a7-91d9-c19a07a66e5f	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.749098+08
56	load-14	order.create	55	fdbdc0ad-2a27-4a8a-884d-67d14ef4bfe2	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.758274+08
59	load-17	order.create	58	83d982c5-6346-4f2c-a8f4-9318dbfa428f	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.765574+08
62	load-19	order.create	61	355c7c23-c50d-4c55-aca1-51e3fc81a4fc	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.772758+08
65	load-13	order.create	64	99bd567b-f017-4bd4-aff4-b58affbae16e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.780632+08
68	load-15	order.create	67	c685a8aa-9520-4ddf-9481-aaa9199ff4fb	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.78758+08
71	load-3	order.create	70	1dd185b1-affd-4d6e-8864-bf831fcafcd6	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.794891+08
74	load-20	order.create	73	1f9b35dd-4b32-4d06-9f80-618da5972c4a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.802127+08
77	load-2	order.create	76	963ecbeb-f9e7-458f-828c-a72772367914	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.808433+08
80	load-16	order.create	79	1754b29d-4028-45c5-9d12-bdf366ee7054	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.818022+08
84	load-18	order.create	83	bfab30e2-4bf0-43d8-86d1-25ba56481579	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.825204+08
88	load-5	order.create	87	c14bea41-9ced-4293-8e05-9f2140398853	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.836019+08
92	load-16	order.create	91	dcc02603-9e93-4966-b6cd-93b0fc9c8e1e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.845324+08
97	load-18	order.create	96	12a5a186-c111-4313-9c9f-d5015036a06f	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.855722+08
102	load-14	order.create	101	e73d4740-dca3-46dd-b18b-c98f94524829	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.869798+08
109	load-17	order.create	108	b07a0e6d-17a9-4b19-b57f-904403e33792	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.884707+08
113	load-2	order.create	112	3c88a561-db8a-43c6-b76d-de8aac866f43	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.909432+08
117	load-13	order.create	116	3ac82fb8-47f9-42f9-b694-8e96252a2b0f	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.923249+08
123	load-17	order.create	122	27bf6357-4869-421f-9f33-17ec852850f0	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.936276+08
126	load-16	order.create	125	57e55e28-c1f5-42e4-aa53-877280a37fe7	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.958675+08
134	load-15	order.create	133	f6b36dca-d3fc-4640-9434-df972e89ad76	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.967689+08
141	load-16	order.create	140	1c51fc87-ec66-485b-a25f-d225321f401e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.997421+08
150	load-7	order.create	149	8dc0bc39-2b7c-446a-b74d-f2078f68832d	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:57.019752+08
48	load-17	order.create	47	ee4d1424-e0aa-4a04-a693-1fd051871438	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.735451+08
51	load-19	order.create	50	84368aee-c669-4e0d-92f9-a48eaa24bab5	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.744201+08
54	load-13	order.create	53	9de57fd1-ef57-4b11-9640-950b99861e4c	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.751673+08
57	load-15	order.create	56	42f0aaab-e297-4463-aa68-bd9293277272	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.760483+08
60	load-3	order.create	59	e5a6b595-43ad-4c1e-a102-7789c21a2bcb	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.767255+08
63	load-20	order.create	62	dfd6b05a-b806-4d7d-8a9a-8089fe0a8ca4	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.775535+08
66	load-2	order.create	65	0240ad59-5491-4a50-892f-ba51fd153555	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.782985+08
69	load-16	order.create	68	20f7b23d-c92f-40d9-83ee-0e502c2b49b7	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.79015+08
72	load-18	order.create	71	f857df71-2aef-4b49-9c24-150e15b40273	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.79703+08
75	load-1	order.create	74	7d23be10-eec5-4920-a167-1a9dae4ec9ae	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.804211+08
76	load-5	order.create	75	07f5d22e-7762-4d98-8197-a5c0dce6c777	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.804018+08
78	load-14	order.create	77	39739efc-bd0a-4eec-af52-9c2447f4c062	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.810761+08
81	load-15	order.create	80	a18faabe-5c7f-438b-bc2f-3598d1d838cb	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.816456+08
83	load-17	order.create	82	961bf729-0bba-4ed4-8b5b-5edda91bc35d	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.820307+08
85	load-19	order.create	84	6f334279-8fb6-4de5-84a9-39bedaca3a11	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.827802+08
86	load-1	order.create	85	99e671be-8a18-49cf-980f-5352f16ccad3	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.833003+08
89	load-14	order.create	88	14739900-f7f1-4285-b73b-c2d887451c21	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.841072+08
90	load-2	order.create	89	78b59b17-42f2-40e8-8d57-69fddee53687	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.83885+08
93	load-15	order.create	92	f926cddc-b438-413d-ad0c-c2234b0443c7	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.848202+08
95	load-3	order.create	94	459c505a-2c19-440f-9fb9-bebfafe7451a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.851204+08
96	load-19	order.create	95	4b77d327-f660-4cf0-a50e-a061c63c9a7a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.858082+08
99	load-20	order.create	98	25374e29-eb4e-4e9c-b8b8-a1407038b87c	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.86417+08
100	load-5	order.create	99	e96d628a-0c4c-4a39-be97-d74c1b955d58	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.86676+08
103	load-16	order.create	102	c931aeb3-d151-4e6f-bac6-b5ccf24462b9	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.877624+08
104	load-4	order.create	103	d6a7ebaa-ca21-481f-8584-6f543691c5d5	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.866563+08
105	load-13	order.create	104	68f5a15d-ebbf-45d4-a483-34abdea28ace	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.875849+08
107	load-3	order.create	106	f4cf8a75-a52a-45b5-8eb7-41f2f37538e8	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.887494+08
108	load-19	order.create	107	77b66aee-57a8-49aa-869f-b70450938f97	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.892852+08
110	load-18	order.create	109	8c008fba-2162-45c4-b4ea-6d6b13b02700	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.895468+08
112	load-20	order.create	111	51ef1a5e-f9f2-46bd-9283-62f73b7cff3a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.901612+08
114	load-14	order.create	113	e2de8ebd-9bf8-4a74-a4dc-1d894b6572c3	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.913002+08
116	load-4	order.create	115	d3dd0435-da0e-4372-8694-cc01016fc081	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.920884+08
118	load-15	order.create	117	f96f051c-ab96-45e7-9502-e14c9b3016e8	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.926627+08
120	load-7	order.create	119	5aeb5fc5-a160-40c3-9bba-d95f22e80499	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.922784+08
121	load-5	order.create	120	412af44d-bdde-41e7-802b-fbaa5092c3cd	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.905751+08
124	load-20	order.create	123	9850868a-8d59-41b0-9357-9bc53c8f6e44	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.94858+08
125	load-19	order.create	124	ca086141-4b8e-46da-8b08-830d6e67fdd3	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.933269+08
127	load-2	order.create	126	af85a65a-5ba0-4fe7-a0d1-f146136a1b63	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.951182+08
128	load-4	order.create	127	7aa13ca7-0abe-43dd-b9f3-e2d6edd7565d	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.962412+08
130	load-18	order.create	129	c66439b1-86de-4d2d-a9f8-d1d628065314	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.940197+08
131	load-3	order.create	130	6d430be1-3b5f-4079-9f23-61f1804eb171	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.971306+08
132	load-13	order.create	131	f0bcc377-4840-4863-b1a7-2094f82c940c	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.965158+08
133	load-7	order.create	132	1b1fb119-70dc-4bd1-a9f0-431507506d6a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.974897+08
136	load-20	order.create	135	92f78b4d-9b03-412d-b9fe-f065d424d71d	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.990632+08
137	load-1	order.create	136	20991620-a204-4626-b6cf-fb98ce33f0df	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.984551+08
138	load-6	order.create	137	1fa92408-5c40-414d-931e-c24202cbde3e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.983278+08
140	load-4	order.create	139	21d3c580-f800-4424-b875-163d9aa25a6a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:57.003784+08
144	load-13	order.create	143	44fd1116-df57-4890-aa48-59d80a19f294	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:57.016902+08
142	load-14	order.create	141	fab5dc75-5426-4b5d-a02e-d97a6458e3e1	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:57.006713+08
151	load-15	order.create	150	e9f3603f-1745-4b56-a256-b1422a03265f	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:57.022767+08
143	load-18	order.create	142	147af4d7-03ee-49ff-953d-ca4a41d65697	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:57.012225+08
145	load-17	order.create	144	72a8a808-75d0-4ae5-9e4d-fb61f6882fc1	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.987976+08
146	load-19	order.create	145	f2835abc-2573-4808-bcaa-cc7d0695c9e8	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.994118+08
147	load-8	order.create	146	6fbc83b0-3b55-4fc4-bc06-fec97aea34e6	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:56.993034+08
149	load-6	order.create	148	d4b0f6b0-45a3-4d8b-9383-fff5eb37eef2	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:14:57.035096+08
153	mq-user	order.create	1	105ac99f-9666-4916-b177-d5c4ff555a4f	\N	{"qty": 1, "sku": "mq-sku", "amount": 100}	2026-11-09 11:14:57.841839+08
154	provider	payment.callback	1	85ea0573-2b33-410d-8d7a-2562dbbc2c31	{"status": "pending_payment"}	{"status": "paid"}	2026-11-09 11:14:57.854438+08
155	mq-runtime	order.create	2	8296cbab-1395-472f-835d-f7998dee13f6	\N	{"qty": 1, "sku": "mq-runtime-sku", "amount": 100}	2026-11-09 11:14:59.832446+08
156	mq-runtime	order.pay	2	fd897a69-bf03-41b9-a941-a9df1282bc63	{"status": "pending_payment"}	{"status": "paid", "payment_id": 1}	2026-11-09 11:14:59.848823+08
\.


--
-- Data for Name: inbox; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.inbox (consumer, event_id, processed_at) FROM stdin;
\.


--
-- Data for Name: inventory; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.inventory (sku, title, unit_price, stock, version) FROM stdin;
mq-sku	MQ 商品	100	9	1
mq-runtime-sku	MQ 运行期商品	100	4	1
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.notifications (event_id, order_id, message, created_at) FROM stdin;
mq-paid-1	1	订单 1 已支付	2026-11-09 11:14:57.863069+08
bulk-2	1	订单 1 已支付	2026-11-09 11:14:58.690658+08
bulk-1	1	订单 1 已支付	2026-11-09 11:14:58.690602+08
bulk-11	1	订单 1 已支付	2026-11-09 11:14:58.693777+08
bulk-12	1	订单 1 已支付	2026-11-09 11:14:58.693835+08
bulk-13	1	订单 1 已支付	2026-11-09 11:14:58.694694+08
bulk-14	1	订单 1 已支付	2026-11-09 11:14:58.694736+08
bulk-15	1	订单 1 已支付	2026-11-09 11:14:58.695669+08
bulk-16	1	订单 1 已支付	2026-11-09 11:14:58.695767+08
bulk-17	1	订单 1 已支付	2026-11-09 11:14:58.696617+08
bulk-18	1	订单 1 已支付	2026-11-09 11:14:58.696664+08
bulk-19	1	订单 1 已支付	2026-11-09 11:14:58.697464+08
bulk-20	1	订单 1 已支付	2026-11-09 11:14:58.697605+08
bulk-21	1	订单 1 已支付	2026-11-09 11:14:58.698362+08
bulk-22	1	订单 1 已支付	2026-11-09 11:14:58.69846+08
bulk-23	1	订单 1 已支付	2026-11-09 11:14:58.699251+08
bulk-24	1	订单 1 已支付	2026-11-09 11:14:58.699648+08
bulk-25	1	订单 1 已支付	2026-11-09 11:14:58.700294+08
bulk-26	1	订单 1 已支付	2026-11-09 11:14:58.700394+08
bulk-27	1	订单 1 已支付	2026-11-09 11:14:58.701225+08
bulk-28	1	订单 1 已支付	2026-11-09 11:14:58.701278+08
bulk-29	1	订单 1 已支付	2026-11-09 11:14:58.702219+08
bulk-30	1	订单 1 已支付	2026-11-09 11:14:58.702271+08
bulk-3	1	订单 1 已支付	2026-11-09 11:14:58.787822+08
bulk-4	1	订单 1 已支付	2026-11-09 11:14:58.821482+08
bulk-5	1	订单 1 已支付	2026-11-09 11:14:58.873884+08
bulk-6	1	订单 1 已支付	2026-11-09 11:14:58.91564+08
bulk-7	1	订单 1 已支付	2026-11-09 11:14:58.948615+08
bulk-8	1	订单 1 已支付	2026-11-09 11:14:59.003777+08
bulk-9	1	订单 1 已支付	2026-11-09 11:14:59.047863+08
bulk-10	1	订单 1 已支付	2026-11-09 11:14:59.084836+08
pay-1	2	订单 2 已支付	2026-11-09 11:15:00.071506+08
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.order_items (order_id, sku, title, unit_price, qty) FROM stdin;
1	mq-sku	MQ 商品	100	1
2	mq-runtime-sku	MQ 运行期商品	100	1
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.orders (id, user_id, idem_key, request_hash, sku, qty, unit_price, amount, status, created_at, paid_at, cancelled_at, version, shipped_at, completed_at, refunding_at, refunded_at) FROM stdin;
1	mq-user	mq-order-1	d559ac7ca035b4385a99fc7ba1dfe3f04c6bfa895c66dec470f64d2c52865b95	mq-sku	1	100	100	paid	2026-11-09 11:14:57.841839+08	2026-11-09 11:14:57.854438+08	\N	1	\N	\N	\N	\N
2	mq-runtime	mq-runtime-1794194099700	60c5257fde15f10651185f852305172cc2dd40f076dc99ef0ab6ad1b9d223187	mq-runtime-sku	1	100	100	paid	2026-11-09 11:14:59.832446+08	2026-11-09 11:14:59.848823+08	\N	1	\N	\N	\N	\N
\.


--
-- Data for Name: outbox; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.outbox (event_id, type, payload, status, attempts, created_at, sent_at, last_error) FROM stdin;
mq-paid-1	order.paid	{"amount": 100, "user_id": "mq-user", "event_id": "mq-paid-1", "order_id": 1}	sent	1	2026-11-09 11:14:57.854438+08	2026-11-09 11:14:57.861146+08	
pay-1	order.paid	{"amount": 100, "user_id": "mq-runtime", "event_id": "pay-1", "order_id": 2}	sent	1	2026-11-09 11:14:59.848823+08	2026-11-09 11:15:00.069621+08	
\.


--
-- Data for Name: payment_attempts; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.payment_attempts (id, payment_id, attempt_no, result, note, latency_ms, created_at) FROM stdin;
1	1	1	succeeded	gateway_ok	0	2026-11-09 11:14:59.848823+08
\.


--
-- Data for Name: payment_events; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.payment_events (event_id, order_id, result, applied, note, received_at, fingerprint) FROM stdin;
mq-paid-1	1	success	t	paid	2026-11-09 11:14:57.854438+08	84e980a05df8c4b48cbf78ef23c01beaf36c96cf984ac25379e8877f62ff3aa9
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.payments (id, order_id, amount, status, provider_ref, attempts, created_at, updated_at) FROM stdin;
1	2	100	succeeded	mock-2-100	1	2026-11-09 11:14:59.848823+08	2026-11-09 11:14:59.848823+08
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.products (sku, title, price_cents, active) FROM stdin;
sku-1	机械键盘	299	t
sku-2	显示器	1299	t
load-sku	压测商品	1000	t
mq-sku	MQ 商品	100	t
mq-runtime-sku	MQ 运行期商品	100	t
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

SELECT pg_catalog.setval('p03.audit_log_id_seq', 156, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: p03; Owner: -
--

SELECT pg_catalog.setval('p03.orders_id_seq', 2, true);


--
-- Name: payment_attempts_id_seq; Type: SEQUENCE SET; Schema: p03; Owner: -
--

SELECT pg_catalog.setval('p03.payment_attempts_id_seq', 1, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: p03; Owner: -
--

SELECT pg_catalog.setval('p03.payments_id_seq', 1, true);


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

\unrestrict eZG4NqIfno8c4p2WLLuj4wQ98uKRk5nvLHXF1YO7FiWk3Odastl7mp2DZ7rgxxq

