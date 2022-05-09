--
-- PostgreSQL database dump
--

-- Dumped from database version 12.10
-- Dumped by pg_dump version 12.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: eald_payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eald_payments (
    id integer NOT NULL,
    event_id integer,
    stripe_charge_id character varying NOT NULL,
    amount_charged_cents integer NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    early_arrival_passes integer DEFAULT 0 NOT NULL,
    late_departure_passes integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: eald_payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.eald_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eald_payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.eald_payments_id_seq OWNED BY public.eald_payments.id;


--
-- Name: event_admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_admins (
    id integer NOT NULL,
    event_id integer,
    user_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: event_admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.event_admins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.event_admins_id_seq OWNED BY public.event_admins.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id integer NOT NULL,
    name character varying,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    adult_ticket_price numeric(8,2),
    kid_ticket_price numeric(8,2),
    cabin_price numeric(8,2),
    max_adult_tickets_per_request integer,
    max_kid_tickets_per_request integer,
    max_cabins_per_request integer,
    max_cabin_requests integer,
    photo character varying,
    tickets_require_approval boolean DEFAULT true NOT NULL,
    require_mailing_address boolean DEFAULT false NOT NULL,
    allow_financial_assistance boolean DEFAULT false NOT NULL,
    allow_donations boolean DEFAULT false NOT NULL,
    ticket_sales_start_time timestamp without time zone,
    ticket_sales_end_time timestamp without time zone,
    ticket_requests_end_time timestamp without time zone,
    early_arrival_price numeric(8,2) DEFAULT 0,
    late_departure_price numeric(8,2) DEFAULT 0
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.jobs (
    id integer NOT NULL,
    event_id integer NOT NULL,
    name character varying(100) NOT NULL,
    description character varying(512) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.payments (
    id integer NOT NULL,
    ticket_request_id integer NOT NULL,
    stripe_charge_id character varying(255),
    status character varying(1) DEFAULT 'P'::character varying NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    explanation character varying
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: price_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.price_rules (
    id integer NOT NULL,
    type character varying,
    event_id integer,
    price numeric(8,2),
    trigger_value integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: price_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.price_rules_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: price_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.price_rules_id_seq OWNED BY public.price_rules.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: shifts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shifts (
    id integer NOT NULL,
    time_slot_id integer NOT NULL,
    user_id integer NOT NULL,
    name character varying(70),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: shifts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shifts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shifts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shifts_id_seq OWNED BY public.shifts.id;


--
-- Name: site_admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.site_admins (
    id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: site_admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_admins_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: site_admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.site_admins_id_seq OWNED BY public.site_admins.id;


--
-- Name: ticket_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_requests (
    id integer NOT NULL,
    adults integer DEFAULT 1 NOT NULL,
    kids integer DEFAULT 0 NOT NULL,
    cabins integer DEFAULT 0 NOT NULL,
    needs_assistance boolean DEFAULT false NOT NULL,
    notes character varying(500),
    status character varying(1) NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    user_id integer NOT NULL,
    special_price numeric(8,2),
    event_id integer NOT NULL,
    donation numeric(8,2) DEFAULT 0,
    role character varying DEFAULT 'volunteer'::character varying NOT NULL,
    role_explanation character varying(200),
    previous_contribution character varying(250),
    address_line1 character varying(200),
    address_line2 character varying(200),
    city character varying(50),
    state character varying(50),
    zip_code character varying(32),
    country_code character varying(4),
    admin_notes character varying(512),
    car_camping boolean,
    car_camping_explanation character varying(200),
    agrees_to_terms boolean,
    early_arrival_passes integer DEFAULT 0 NOT NULL,
    late_departure_passes integer DEFAULT 0 NOT NULL,
    guests text
);


--
-- Name: ticket_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_requests_id_seq OWNED BY public.ticket_requests.id;


--
-- Name: time_slots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.time_slots (
    id integer NOT NULL,
    job_id integer NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    slots integer NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: time_slots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.time_slots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: time_slots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.time_slots_id_seq OWNED BY public.time_slots.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    email character varying NOT NULL,
    encrypted_password character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying,
    last_sign_in_ip character varying,
    confirmation_token character varying,
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying,
    failed_attempts integer DEFAULT 0,
    unlock_token character varying,
    locked_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    name character varying(70) NOT NULL,
    authentication_token character varying(64)
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: eald_payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eald_payments ALTER COLUMN id SET DEFAULT nextval('public.eald_payments_id_seq'::regclass);


--
-- Name: event_admins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_admins ALTER COLUMN id SET DEFAULT nextval('public.event_admins_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: price_rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_rules ALTER COLUMN id SET DEFAULT nextval('public.price_rules_id_seq'::regclass);


--
-- Name: shifts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shifts ALTER COLUMN id SET DEFAULT nextval('public.shifts_id_seq'::regclass);


--
-- Name: site_admins id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_admins ALTER COLUMN id SET DEFAULT nextval('public.site_admins_id_seq'::regclass);


--
-- Name: ticket_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_requests ALTER COLUMN id SET DEFAULT nextval('public.ticket_requests_id_seq'::regclass);


--
-- Name: time_slots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_slots ALTER COLUMN id SET DEFAULT nextval('public.time_slots_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: eald_payments eald_payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eald_payments
    ADD CONSTRAINT eald_payments_pkey PRIMARY KEY (id);


--
-- Name: event_admins event_admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_admins
    ADD CONSTRAINT event_admins_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: price_rules price_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_rules
    ADD CONSTRAINT price_rules_pkey PRIMARY KEY (id);


--
-- Name: shifts shifts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shifts
    ADD CONSTRAINT shifts_pkey PRIMARY KEY (id);


--
-- Name: site_admins site_admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.site_admins
    ADD CONSTRAINT site_admins_pkey PRIMARY KEY (id);


--
-- Name: ticket_requests ticket_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_requests
    ADD CONSTRAINT ticket_requests_pkey PRIMARY KEY (id);


--
-- Name: time_slots time_slots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.time_slots
    ADD CONSTRAINT time_slots_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_event_admins_on_event_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_event_admins_on_event_id_and_user_id ON public.event_admins USING btree (event_id, user_id);


--
-- Name: index_event_admins_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_admins_on_user_id ON public.event_admins USING btree (user_id);


--
-- Name: index_price_rules_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_price_rules_on_event_id ON public.price_rules USING btree (event_id);


--
-- Name: index_users_on_confirmation_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_confirmation_token ON public.users USING btree (confirmation_token);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_unlock_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_unlock_token ON public.users USING btree (unlock_token);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20130210233501');

INSERT INTO schema_migrations (version) VALUES ('20130223202959');

INSERT INTO schema_migrations (version) VALUES ('20130223204913');

INSERT INTO schema_migrations (version) VALUES ('20130224204644');

INSERT INTO schema_migrations (version) VALUES ('20130225033247');

INSERT INTO schema_migrations (version) VALUES ('20130226010856');

INSERT INTO schema_migrations (version) VALUES ('20130226221916');

INSERT INTO schema_migrations (version) VALUES ('20130228052958');

INSERT INTO schema_migrations (version) VALUES ('20130304020307');

INSERT INTO schema_migrations (version) VALUES ('20130304021739');

INSERT INTO schema_migrations (version) VALUES ('20130304022508');

INSERT INTO schema_migrations (version) VALUES ('20130311213508');

INSERT INTO schema_migrations (version) VALUES ('20130325024448');

INSERT INTO schema_migrations (version) VALUES ('20130325051758');

INSERT INTO schema_migrations (version) VALUES ('20130425052112');

INSERT INTO schema_migrations (version) VALUES ('20130427054403');

INSERT INTO schema_migrations (version) VALUES ('20130507051822');

INSERT INTO schema_migrations (version) VALUES ('20130509021514');

INSERT INTO schema_migrations (version) VALUES ('20130514035306');

INSERT INTO schema_migrations (version) VALUES ('20130616002401');

INSERT INTO schema_migrations (version) VALUES ('20130628042018');

INSERT INTO schema_migrations (version) VALUES ('20130628050717');

INSERT INTO schema_migrations (version) VALUES ('20130701042655');

INSERT INTO schema_migrations (version) VALUES ('20130701045629');

INSERT INTO schema_migrations (version) VALUES ('20130701054452');

INSERT INTO schema_migrations (version) VALUES ('20130702041357');

INSERT INTO schema_migrations (version) VALUES ('20130707204929');

INSERT INTO schema_migrations (version) VALUES ('20130707222903');

INSERT INTO schema_migrations (version) VALUES ('20130803212458');

INSERT INTO schema_migrations (version) VALUES ('20140428041744');

INSERT INTO schema_migrations (version) VALUES ('20140428045329');

INSERT INTO schema_migrations (version) VALUES ('20140515053804');

INSERT INTO schema_migrations (version) VALUES ('20140515054433');

INSERT INTO schema_migrations (version) VALUES ('20140605034909');

INSERT INTO schema_migrations (version) VALUES ('20140605045004');

INSERT INTO schema_migrations (version) VALUES ('20140605052627');

INSERT INTO schema_migrations (version) VALUES ('20140605053705');

INSERT INTO schema_migrations (version) VALUES ('20140605060026');

INSERT INTO schema_migrations (version) VALUES ('20140611044708');

INSERT INTO schema_migrations (version) VALUES ('20140611051614');

INSERT INTO schema_migrations (version) VALUES ('20140616024138');

INSERT INTO schema_migrations (version) VALUES ('20140616030905');

INSERT INTO schema_migrations (version) VALUES ('20140706232217');

INSERT INTO schema_migrations (version) VALUES ('20150609064608');

INSERT INTO schema_migrations (version) VALUES ('20160611234315');

INSERT INTO schema_migrations (version) VALUES ('20180527021019');

INSERT INTO schema_migrations (version) VALUES ('20220506000947');

