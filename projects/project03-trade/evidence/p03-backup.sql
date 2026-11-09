--
-- PostgreSQL database dump
--

\restrict skukuZYQOA2zHCUDxSYokxzJvxWa069fLO0y6g9dcsujx5i4iKhCqPhrq6RdBgY

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
1	load-1	order.create	1	b495985e-cf0d-4e83-a836-1363afae1483	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.094868+08
2	load-13	order.create	2	89a744d3-7c00-4348-b090-f653a8683b55	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.122966+08
3	load-14	order.create	3	c6266335-d8a4-40b1-b5fa-0616bd993041	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.138483+08
4	load-15	order.create	4	f77d8cbe-2624-4909-a8c2-1def6b3c444c	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.145748+08
5	load-16	order.create	5	21d76f60-bba4-4c92-9c29-b7653525a801	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.153685+08
6	load-17	order.create	6	21eddf81-ca8e-41b7-b694-2d91bca1b4a9	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.164237+08
7	load-18	order.create	7	86d99224-7d0f-412c-912a-efa566f77ef4	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.171805+08
8	load-19	order.create	8	59753d89-d1c9-42c6-94fe-7344d399a0a5	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.178393+08
9	load-20	order.create	9	4c715fe6-b3bc-419e-b7a8-38a610d13df9	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.185701+08
10	load-1	order.create	10	fb3c5636-fab5-4dc6-be77-c65adec1beec	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.191618+08
11	load-13	order.create	11	eb87f213-77e7-49a7-8310-f3b61f38267e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.197875+08
12	load-14	order.create	12	887d5400-a0f0-4553-ab85-e2545b836d48	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.203187+08
13	load-15	order.create	13	6df166bd-40b0-4824-8a86-475a3c8735d4	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.208832+08
14	load-16	order.create	14	cb78e7c2-c64a-4325-801a-611d31731aa0	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.214538+08
15	load-17	order.create	15	e7ca4f22-9d34-41a4-9120-d7f127fbbf8a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.219824+08
16	load-18	order.create	16	83c4ed50-d6b4-43ac-98b4-7cf79d72d338	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.225256+08
17	load-19	order.create	17	8b15441f-0de5-4f41-b998-583bfb84ad31	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.231126+08
18	load-2	order.create	18	86edfa86-0ade-4ec2-8569-4dacc0a6c900	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.232965+08
19	load-20	order.create	19	a9176258-6c45-4890-bafe-e8b7e61579c5	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.236478+08
20	load-1	order.create	20	7462181f-2891-45ef-b010-779d389bcca0	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.241996+08
21	load-13	order.create	21	e70ac488-86ab-4803-bd5f-44c0693744bf	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.244481+08
22	load-14	order.create	22	2bd57955-5362-40ab-90c7-6fb950d60594	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.248773+08
23	load-15	order.create	23	f478f8e4-4e81-411c-b6f6-62d5c5a1f44c	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.25211+08
24	load-16	order.create	24	4627bbec-f793-40c6-abec-8371ea51a451	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.256532+08
25	load-17	order.create	25	771aef4c-134a-445a-9d32-b9e027f22a0b	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.260627+08
26	load-18	order.create	26	f66c3018-784c-4451-bf69-a709648580a7	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.265108+08
27	load-19	order.create	27	1b012aa4-4b3a-4807-8e3f-3f99fb34882e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.268328+08
28	load-2	order.create	28	63533324-e5cf-45a1-b6ba-3a08d3a61b5e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.273276+08
29	load-20	order.create	29	ef70bc77-6e43-4212-9c20-9966f3179b61	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.276311+08
30	load-1	order.create	30	30f8683c-4469-4e62-a1f7-23ca744f3439	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.28059+08
31	load-13	order.create	31	a058568b-8cb9-4879-99af-b09adba7e4a5	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.284509+08
32	load-3	order.create	32	9edfbef2-6387-462a-a62f-6db17a2a1ab4	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.285806+08
33	load-14	order.create	33	1f824c49-f9f2-4e9e-ac9e-c418a2507c80	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.288151+08
34	load-15	order.create	34	6ce7252f-534b-4d1f-b91c-623d7677e45b	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.291022+08
35	load-16	order.create	35	1bfe286d-30a1-4a62-a52b-ab0fb48bdd07	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.295591+08
36	load-17	order.create	36	0fa217b9-df0e-460e-a784-65e76635405e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.298185+08
37	load-18	order.create	37	5fd18f7d-6c5e-4915-badc-74d367fb1e30	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.300744+08
38	load-19	order.create	38	cac06132-bb0b-4397-a8b3-514ae9ef2e32	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.30398+08
39	load-2	order.create	39	82922915-3271-4654-bc62-a2ad07723aeb	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.307268+08
40	load-20	order.create	40	a51b2d3d-c8ff-4492-9138-c1909153cbff	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.310344+08
41	load-1	order.create	41	a354224d-360b-4431-9f0b-6e0707b0828f	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.314029+08
42	load-13	order.create	42	1a7872a6-887f-4a42-b499-6e178fba0c53	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.317268+08
43	load-3	order.create	43	939503ff-4d3f-468d-8c60-5d5d20519920	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.320583+08
44	load-14	order.create	44	be5abf47-4386-4604-9433-4ea6d9a61bfb	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.32513+08
45	load-15	order.create	45	179b10e3-cff3-432c-8c0c-2b1516f4ccd2	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.329163+08
46	load-16	order.create	46	ee72d6ab-d298-420f-aceb-a3fa78314aab	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.332868+08
47	load-4	order.create	47	c634bef9-4919-4d8f-b0ba-53126a8819d0	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.330578+08
50	load-19	order.create	50	53b6f9c0-85fd-4c8a-b551-d1db1c00aac8	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.343511+08
51	load-2	order.create	51	d46e4363-75a2-4a34-89d4-b1b913729bb2	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.348842+08
54	load-13	order.create	54	20510da2-2811-420f-88da-7d4935f60628	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.360138+08
55	load-3	order.create	55	8192b1e1-6421-40ee-a783-17623bf26f11	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.363842+08
58	load-16	order.create	58	03d81dbd-1729-49c9-9554-29c5b874a2c9	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.373988+08
59	load-4	order.create	59	1f714c43-05e5-4114-b4ef-08758d465852	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.377176+08
61	load-19	order.create	61	38b94689-4460-4889-9173-867e3aded2b4	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.386302+08
63	load-2	order.create	63	33c625ba-ae9f-4506-9862-e8f006452890	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.388577+08
66	load-1	order.create	66	45e7f9b7-7479-4735-953a-86da965d7cc0	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.393639+08
69	load-3	order.create	69	1a53f78d-a0e7-4371-a865-7e391012f009	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.398538+08
70	load-16	order.create	70	33cc4e7f-8775-4fb3-bc4c-6c9e1c055fa4	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.407678+08
74	load-18	order.create	74	f30bd807-f3af-490b-b999-3f0df7ecfb7a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.420531+08
76	load-19	order.create	76	bd4a6087-d034-467d-ba84-cb3640960b43	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.417575+08
78	load-14	order.create	78	608919a7-4469-4ba4-a7d5-ee2bc3f53a22	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.439574+08
82	load-1	order.create	82	74f1dd8a-ca13-470a-b2f1-77d93c3b4c21	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.434607+08
83	load-16	order.create	83	172eb88f-1beb-4f7f-aac9-d573ea526524	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.445013+08
86	load-18	order.create	86	f9d56bf5-c50b-499e-995f-a2f5f4810864	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.456409+08
87	load-2	order.create	87	31bf076c-f47e-46f6-a0f7-49af415d1b66	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.459168+08
92	load-20	order.create	92	918beaae-b46f-4b1f-ae30-dd892c8d61d9	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.470352+08
94	load-14	order.create	94	1b1e7571-3b42-4265-a792-ff8eecc86565	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.468165+08
98	load-18	order.create	98	d824ed0e-d257-43e1-b086-48c5cb3e41d0	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.489421+08
99	load-15	order.create	99	9b876493-4799-49a1-8d01-862dcde4e48a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.4843+08
103	load-5	order.create	103	74989488-cbd8-4b8a-99af-2fc163b20d8a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.501502+08
115	load-17	order.create	115	5154e0ca-e620-49b0-8c69-e56e07da9413	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.50371+08
119	load-2	order.create	119	81ed5d0c-5413-43a9-a857-e43e0ef96812	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.549131+08
122	load-1	order.create	122	4972f380-e9c6-4488-a224-9263e9a721d6	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.513671+08
125	load-15	order.create	125	e3daba84-3e76-4aa8-97a2-fbe6f695e206	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.560504+08
128	load-20	order.create	128	8a72dc5b-4b73-46f5-8103-06c29d053920	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.581385+08
133	load-8	order.create	133	6cd6b4b4-b9e6-4004-bf24-6ca88dcffbfe	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.570661+08
138	load-15	order.create	138	e901530b-8d12-4f18-934b-c5bb38d7cb51	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.60405+08
146	load-6	order.create	146	1c6e906e-692c-4cb8-a76e-1087019b7403	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.591016+08
150	load-15	order.create	150	bc33b77f-2bde-4868-afd9-764824ca7d62	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.641958+08
48	load-17	order.create	48	bb0d1c0c-5a71-4742-a4a9-dc47b31f8629	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.336597+08
52	load-20	order.create	52	534dc3ce-311d-43ea-9b41-36035bf0856f	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.353048+08
56	load-14	order.create	56	e5b0f2d9-b1d6-4d56-8a6e-7ad5b0cc0179	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.367587+08
60	load-17	order.create	60	ab821eed-ee93-4718-bda7-1ae0978e7bc4	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.380396+08
64	load-20	order.create	64	c655e46c-2bde-48bc-8f73-0e3ce316e933	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.391316+08
68	load-14	order.create	68	3661e209-3ecb-4c50-a72e-a9269c313388	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.40134+08
73	load-17	order.create	73	8207ce42-e9a6-498b-8648-541117e90dfc	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.414146+08
77	load-5	order.create	77	59374dae-6b61-47fb-b6ae-5c869b547805	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.431202+08
89	load-3	order.create	89	c523421d-a79e-481e-9a23-47b29f7af18e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.442289+08
93	load-6	order.create	93	2d260eab-9428-4e2b-a10d-e23664b61285	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.475846+08
97	load-4	order.create	97	7ee1b1f6-dc78-4587-856a-087a13d5afab	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.487044+08
101	load-3	order.create	101	57aa626d-4fbe-4425-a186-892a5a0e22d9	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.499103+08
105	load-6	order.create	105	8b4e819a-ea4f-4703-b53f-f23dde944fd5	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.508686+08
109	load-4	order.create	109	056abece-b862-4979-b387-c5cba61348f9	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.519385+08
124	load-3	order.create	124	0c3fa767-13f2-4dc4-90d0-fddcac22e876	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.531866+08
127	load-13	order.create	127	0944bc45-e396-468f-9230-a4462106b41e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.578502+08
141	load-2	order.create	141	1e7090a9-2dbb-44c3-9918-aee44e57c0f6	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.587859+08
145	load-8	order.create	145	cd7ff415-3580-4f11-ba67-56e6e24ee3ba	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.627428+08
49	load-18	order.create	49	d6622d44-b328-4f4d-b036-caa9d87e9ada	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.339738+08
53	load-1	order.create	53	641be091-4a3c-4b9b-b2f3-a0dfb29a21ad	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.356662+08
57	load-15	order.create	57	2127a340-8b5c-40e5-8662-d3b994b2315d	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.37101+08
62	load-18	order.create	62	ed263562-5009-458c-b3e0-6cfb83420a30	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.383113+08
65	load-5	order.create	65	458dc74f-4a7a-4f59-8e04-e6e0c1605fd2	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.382207+08
67	load-13	order.create	67	06438d63-dbb7-4b98-b216-12de8b92f9b4	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.39622+08
71	load-15	order.create	71	277c18e2-9e59-4520-bde9-b5ade0e99800	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.405745+08
72	load-4	order.create	72	680b0c4f-8154-43f8-83d5-21cd3191d82a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.410775+08
75	load-2	order.create	75	7e8573ac-7acb-4fb3-abaf-acb284f1387a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.423631+08
79	load-20	order.create	79	c33fd4b5-58d4-4ad3-8a38-71334dc3b64f	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.426985+08
80	load-13	order.create	80	f28cafcb-0892-4215-b189-87758307e214	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.437125+08
81	load-6	order.create	81	a7b8093a-69d7-42cf-9a99-556a3ea8993a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.433459+08
84	load-15	order.create	84	3195739f-d8d1-49db-a7e6-9508b9dcf0dc	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.447757+08
85	load-4	order.create	85	4b21bed8-3538-458e-a87b-d3247f49c24a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.450321+08
88	load-19	order.create	88	d1cc784a-bc04-491f-9cc3-0d5ca04b8e7b	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.462464+08
90	load-5	order.create	90	b4492c28-f93d-494b-823c-398e8edb4fbe	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.465647+08
91	load-17	order.create	91	e762a8e9-4c15-44f9-a55b-de7396997a11	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.455223+08
95	load-1	order.create	95	33a4fe27-ccef-43c1-b3a2-e5f1e20e80f1	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.479212+08
96	load-7	order.create	96	6a03169f-745c-4e55-8bc3-0d572635e639	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.484091+08
100	load-19	order.create	100	b6b4e0f6-a5b1-4f83-8fc6-7e076517c96d	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.496226+08
102	load-13	order.create	102	2e921cfc-b3f2-463f-921c-fe9bd850a76c	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.472883+08
104	load-20	order.create	104	bcbd7005-366c-47aa-bb07-83f1b637a073	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.506314+08
106	load-14	order.create	106	78bd3893-fbfe-4da7-9b82-c3fcfde4aba0	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.511377+08
107	load-2	order.create	107	4a6f0476-e071-4546-8b61-2d4a7a9e1809	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.491773+08
108	load-7	order.create	108	28923ed8-688a-4bc2-8d0d-dc22c54017ab	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.517032+08
110	load-16	order.create	110	59da18c6-658b-4986-bd59-d4ea1f7ea560	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.481875+08
111	load-15	order.create	111	66e5e4f4-0606-41f2-83c7-3064aec6f7e2	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.525735+08
112	load-19	order.create	112	4b325aa4-3c8c-4b9e-8937-653d25af495f	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.528755+08
113	load-18	order.create	113	0c0d0651-7dc3-4cf3-b68a-ce2ab62427c1	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.522089+08
114	load-8	order.create	114	09e1ef0b-72d6-4754-8af3-c5f62a689f14	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.530893+08
116	load-13	order.create	116	3b091004-2c14-4090-a702-b078ef2f1987	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.534749+08
117	load-20	order.create	117	8dc42d97-fe83-415d-8768-c0c8f31f3f8b	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.539403+08
118	load-5	order.create	118	8d4eff5b-4cda-47ff-924a-02fc9cbb872a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.537317+08
120	load-6	order.create	120	313d7697-faa8-4241-976b-e2c880275c30	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.54192+08
121	load-7	order.create	121	5b7815d3-16ae-408a-b9ab-5622815248c2	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.551375+08
123	load-16	order.create	123	5cf08395-4bcb-4288-b60d-65eecbff198e	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.557087+08
126	load-19	order.create	126	d977cd3b-54f3-43d2-a6ca-55b307a17f20	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.563594+08
129	load-14	order.create	129	a8e9d21f-bc38-4c22-bb45-0787ce944727	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.547286+08
130	load-5	order.create	130	6b3ea47f-3295-4b6b-878f-c3aa007ef0ff	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.584647+08
131	load-4	order.create	131	2721152f-c20d-4e7c-9a98-1cbb1709113c	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.553958+08
132	load-18	order.create	132	f31ae5c3-e858-4917-8d13-b42776275120	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.567514+08
134	load-9	order.create	134	8dd7b272-d621-459d-8a68-49eaebf925e3	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.593009+08
135	load-16	order.create	135	6a310d1b-df70-4eea-9ad0-d13d851d05bb	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.599275+08
136	load-3	order.create	136	51bcb86d-ba61-4438-a1d4-9eb7dadf5445	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.601559+08
137	load-17	order.create	137	acfdc92d-8892-4fe4-a630-675870523038	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.574057+08
139	load-19	order.create	139	0204bee0-620a-4773-bd7b-75a6d3fc143a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.608467+08
140	load-20	order.create	140	446951e8-dfaa-4333-894b-5e283035b498	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.612916+08
147	load-18	order.create	147	967c2c87-789f-4bee-b8a9-95f72df43391	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.624328+08
142	load-7	order.create	142	2d533d62-8407-4776-a656-e45fbdc5f019	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.593749+08
143	load-4	order.create	143	176e40df-2a10-452f-81f0-41704c8f75fc	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.621637+08
144	load-1	order.create	144	02cd20cc-56e9-48fd-8e57-d4eaeadc283a	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.596502+08
148	load-14	order.create	148	82e0054d-8e7e-4e9a-9146-1252ba9638e5	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.615111+08
149	load-13	order.create	149	0b117bb1-f6ee-4fb2-a177-3117d3cab438	\N	{"qty": 1, "sku": "load-sku", "amount": 10}	2026-11-09 11:24:19.610305+08
151	mq-user	order.create	1	abab2091-61b0-4c5f-9cf7-1ee38f92adc0	\N	{"qty": 1, "sku": "mq-sku", "amount": 100}	2026-11-09 11:24:20.328934+08
152	provider	payment.callback	1	912c045f-1347-4cd5-82c4-1ebe9e69d701	{"status": "pending_payment"}	{"status": "paid"}	2026-11-09 11:24:20.341542+08
153	mq-runtime	order.create	2	2a6f3571-9b96-48b5-9e67-0e65cdfc1422	\N	{"qty": 1, "sku": "mq-runtime-sku", "amount": 100}	2026-11-09 11:24:23.009556+08
154	mq-runtime	order.pay	2	e1eab608-a097-4d88-a5e4-59e04169916b	{"status": "pending_payment"}	{"status": "paid", "payment_id": 1}	2026-11-09 11:24:23.027452+08
155	worker-split	order.create	3	a2af6448-5ae2-4130-81ca-85eda68df726	\N	{"qty": 1, "sku": "worker-sku", "amount": 100}	2026-11-09 11:24:24.690522+08
156	worker-split	order.pay	3	a7bed360-b4b9-48c5-b546-5f1170c94877	{"status": "pending_payment"}	{"status": "paid", "payment_id": 2}	2026-11-09 11:24:24.704166+08
157	fault-user	order.create	4	16ec1d0b-8626-45cc-87c1-3e58cb54be2e	\N	{"qty": 1, "sku": "fault-sku", "amount": 100}	2026-11-09 11:24:26.062061+08
158	fault-user	order.create	5	561c008b-51ce-4a13-ba35-3d5a5a0df40b	\N	{"qty": 1, "sku": "fault-sku", "amount": 100}	2026-11-09 11:24:26.679566+08
159	fault-user	order.pay	5	e84c521e-57b1-4236-9cd9-3a61079d9425	{"status": "pending_payment"}	{"status": "paid", "payment_id": 3}	2026-11-09 11:24:26.696391+08
\.


--
-- Data for Name: inbox; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.inbox (consumer, event_id, processed_at) FROM stdin;
notify-worker	pay-3	2026-11-09 11:24:27.171145+08
\.


--
-- Data for Name: inventory; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.inventory (sku, title, unit_price, stock, version) FROM stdin;
mq-sku	MQ 商品	100	9	1
mq-runtime-sku	MQ 运行期商品	100	4	1
worker-sku	Worker 商品	100	4	1
fault-sku	故障演练商品	100	3	2
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.notifications (event_id, order_id, message, created_at) FROM stdin;
mq-paid-1	1	订单 1 已支付	2026-11-09 11:24:20.349601+08
bulk-2	1	订单 1 已支付	2026-11-09 11:24:21.165343+08
bulk-1	1	订单 1 已支付	2026-11-09 11:24:21.165211+08
bulk-11	1	订单 1 已支付	2026-11-09 11:24:21.173348+08
bulk-12	1	订单 1 已支付	2026-11-09 11:24:21.173472+08
bulk-13	1	订单 1 已支付	2026-11-09 11:24:21.176177+08
bulk-14	1	订单 1 已支付	2026-11-09 11:24:21.176299+08
bulk-15	1	订单 1 已支付	2026-11-09 11:24:21.178146+08
bulk-16	1	订单 1 已支付	2026-11-09 11:24:21.178586+08
bulk-17	1	订单 1 已支付	2026-11-09 11:24:21.179733+08
bulk-18	1	订单 1 已支付	2026-11-09 11:24:21.180203+08
bulk-19	1	订单 1 已支付	2026-11-09 11:24:21.181153+08
bulk-20	1	订单 1 已支付	2026-11-09 11:24:21.181395+08
bulk-21	1	订单 1 已支付	2026-11-09 11:24:21.182738+08
bulk-22	1	订单 1 已支付	2026-11-09 11:24:21.183152+08
bulk-23	1	订单 1 已支付	2026-11-09 11:24:21.184534+08
bulk-24	1	订单 1 已支付	2026-11-09 11:24:21.184797+08
bulk-25	1	订单 1 已支付	2026-11-09 11:24:21.186033+08
bulk-26	1	订单 1 已支付	2026-11-09 11:24:21.186256+08
bulk-27	1	订单 1 已支付	2026-11-09 11:24:21.187455+08
bulk-28	1	订单 1 已支付	2026-11-09 11:24:21.187706+08
bulk-29	1	订单 1 已支付	2026-11-09 11:24:21.188846+08
bulk-30	1	订单 1 已支付	2026-11-09 11:24:21.18907+08
bulk-3	1	订单 1 已支付	2026-11-09 11:24:21.325666+08
bulk-4	1	订单 1 已支付	2026-11-09 11:24:21.383635+08
bulk-5	1	订单 1 已支付	2026-11-09 11:24:21.429679+08
bulk-6	1	订单 1 已支付	2026-11-09 11:24:21.48597+08
bulk-7	1	订单 1 已支付	2026-11-09 11:24:21.540304+08
bulk-8	1	订单 1 已支付	2026-11-09 11:24:21.605879+08
bulk-9	1	订单 1 已支付	2026-11-09 11:24:21.676617+08
bulk-10	1	订单 1 已支付	2026-11-09 11:24:21.737162+08
pay-1	2	订单 2 已支付	2026-11-09 11:24:23.246936+08
pay-2	3	订单 3 已支付	2026-11-09 11:24:25.044804+08
pay-3	5	订单 5 已支付 100 分	2026-11-09 11:24:27.171145+08
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.order_items (order_id, sku, title, unit_price, qty) FROM stdin;
1	mq-sku	MQ 商品	100	1
2	mq-runtime-sku	MQ 运行期商品	100	1
3	worker-sku	Worker 商品	100	1
4	fault-sku	故障演练商品	100	1
5	fault-sku	故障演练商品	100	1
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.orders (id, user_id, idem_key, request_hash, sku, qty, unit_price, amount, status, created_at, paid_at, cancelled_at, version, shipped_at, completed_at, refunding_at, refunded_at) FROM stdin;
1	mq-user	mq-order-1	d559ac7ca035b4385a99fc7ba1dfe3f04c6bfa895c66dec470f64d2c52865b95	mq-sku	1	100	100	paid	2026-11-09 11:24:20.328934+08	2026-11-09 11:24:20.341542+08	\N	1	\N	\N	\N	\N
2	mq-runtime	mq-runtime-1794194662861	60c5257fde15f10651185f852305172cc2dd40f076dc99ef0ab6ad1b9d223187	mq-runtime-sku	1	100	100	paid	2026-11-09 11:24:23.009556+08	2026-11-09 11:24:23.027452+08	\N	1	\N	\N	\N	\N
3	worker-split	worker-split-1794194664481	50539f3828f0d0e81f003be3c97932cb9c6cfbb88a22ac63b3d59070c27464b0	worker-sku	1	100	100	paid	2026-11-09 11:24:24.690522+08	2026-11-09 11:24:24.704166+08	\N	1	\N	\N	\N	\N
4	fault-user	db-recovered-1794194666061	770533cc18e07deb3d53885bd4e6fd3fa97f322259291a7a5457424b2a9acdc0	fault-sku	1	100	100	pending_payment	2026-11-09 11:24:26.062061+08	\N	\N	0	\N	\N	\N	\N
5	fault-user	mq-down-1794194666671	770533cc18e07deb3d53885bd4e6fd3fa97f322259291a7a5457424b2a9acdc0	fault-sku	1	100	100	paid	2026-11-09 11:24:26.679566+08	2026-11-09 11:24:26.696391+08	\N	1	\N	\N	\N	\N
\.


--
-- Data for Name: outbox; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.outbox (event_id, type, payload, status, attempts, created_at, sent_at, last_error) FROM stdin;
mq-paid-1	order.paid	{"amount": 100, "user_id": "mq-user", "event_id": "mq-paid-1", "order_id": 1}	sent	1	2026-11-09 11:24:20.341542+08	2026-11-09 11:24:20.34742+08	
pay-1	order.paid	{"amount": 100, "user_id": "mq-runtime", "event_id": "pay-1", "order_id": 2}	sent	1	2026-11-09 11:24:23.027452+08	2026-11-09 11:24:23.243674+08	
pay-2	order.paid	{"amount": 100, "user_id": "worker-split", "event_id": "pay-2", "order_id": 3}	sent	1	2026-11-09 11:24:24.704166+08	2026-11-09 11:24:25.042873+08	
pay-3	order.paid	{"amount": 100, "user_id": "fault-user", "event_id": "pay-3", "order_id": 5}	sent	0	2026-11-09 11:24:26.696391+08	2026-11-09 11:24:27.171145+08	
\.


--
-- Data for Name: payment_attempts; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.payment_attempts (id, payment_id, attempt_no, result, note, latency_ms, created_at) FROM stdin;
1	1	1	succeeded	gateway_ok	1	2026-11-09 11:24:23.027452+08
2	2	1	succeeded	gateway_ok	0	2026-11-09 11:24:24.704166+08
3	3	1	succeeded	gateway_ok	0	2026-11-09 11:24:26.696391+08
\.


--
-- Data for Name: payment_events; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.payment_events (event_id, order_id, result, applied, note, received_at, fingerprint) FROM stdin;
mq-paid-1	1	success	t	paid	2026-11-09 11:24:20.341542+08	86e23d4c68f41d85fe9206b9d541dcef93e8b50fad533552577be101d12044bf
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.payments (id, order_id, amount, status, provider_ref, attempts, created_at, updated_at) FROM stdin;
1	2	100	succeeded	mock-2-100	1	2026-11-09 11:24:23.027452+08	2026-11-09 11:24:23.027452+08
2	3	100	succeeded	mock-3-100	1	2026-11-09 11:24:24.704166+08	2026-11-09 11:24:24.704166+08
3	5	100	succeeded	mock-5-100	1	2026-11-09 11:24:26.696391+08	2026-11-09 11:24:26.696391+08
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: p03; Owner: -
--

COPY p03.products (sku, title, price_cents, active) FROM stdin;
sku-1	机械键盘	299	t
load-sku	压测商品	1000	t
mq-sku	MQ 商品	100	t
mq-runtime-sku	MQ 运行期商品	100	t
worker-sku	Worker 商品	100	t
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

SELECT pg_catalog.setval('p03.audit_log_id_seq', 159, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: p03; Owner: -
--

SELECT pg_catalog.setval('p03.orders_id_seq', 5, true);


--
-- Name: payment_attempts_id_seq; Type: SEQUENCE SET; Schema: p03; Owner: -
--

SELECT pg_catalog.setval('p03.payment_attempts_id_seq', 3, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: p03; Owner: -
--

SELECT pg_catalog.setval('p03.payments_id_seq', 3, true);


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

\unrestrict skukuZYQOA2zHCUDxSYokxzJvxWa069fLO0y6g9dcsujx5i4iKhCqPhrq6RdBgY

