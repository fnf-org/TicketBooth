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
-- Name: addons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addons (
    id bigint NOT NULL,
    category character varying NOT NULL,
    name character varying NOT NULL,
    default_price integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: addons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.addons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: addons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.addons_id_seq OWNED BY public.addons.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: event_addons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_addons (
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    addon_id bigint NOT NULL,
    price integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: event_addons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.event_addons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_addons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.event_addons_id_seq OWNED BY public.event_addons.id;


--
-- Name: event_admins; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.event_admins (
    id bigint NOT NULL,
    event_id bigint,
    user_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: event_admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.event_admins_id_seq
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
    id bigint NOT NULL,
    name character varying,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    adult_ticket_price integer,
    kid_ticket_price integer,
    max_adult_tickets_per_request integer,
    max_kid_tickets_per_request integer,
    photo character varying,
    tickets_require_approval boolean DEFAULT true NOT NULL,
    require_mailing_address boolean DEFAULT false NOT NULL,
    allow_financial_assistance boolean DEFAULT false NOT NULL,
    allow_donations boolean DEFAULT false NOT NULL,
    ticket_sales_start_time timestamp without time zone,
    ticket_sales_end_time timestamp without time zone,
    ticket_requests_end_time timestamp without time zone,
    slug text,
    require_role boolean DEFAULT true NOT NULL
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.events_id_seq
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
    id bigint NOT NULL,
    event_id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description character varying(512) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.jobs_id_seq
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
    id bigint NOT NULL,
    ticket_request_id integer NOT NULL,
    stripe_charge_id character varying(255),
    status character varying(1) DEFAULT 'N'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    explanation character varying,
    stripe_payment_id character varying,
    stripe_refund_id character varying
);


--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.payments_id_seq
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
    id bigint NOT NULL,
    type character varying,
    event_id bigint,
    price numeric(8,2),
    trigger_value integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: price_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.price_rules_id_seq
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
    id bigint NOT NULL,
    time_slot_id bigint NOT NULL,
    user_id bigint NOT NULL,
    name character varying(70),
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: shifts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shifts_id_seq
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
    id bigint NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: site_admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.site_admins_id_seq
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
-- Name: ticket_request_event_addons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_request_event_addons (
    id bigint NOT NULL,
    ticket_request_id bigint NOT NULL,
    event_addon_id bigint NOT NULL,
    quantity integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ticket_request_event_addons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_request_event_addons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ticket_request_event_addons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ticket_request_event_addons_id_seq OWNED BY public.ticket_request_event_addons.id;


--
-- Name: ticket_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ticket_requests (
    id bigint NOT NULL,
    adults integer DEFAULT 1 NOT NULL,
    kids integer DEFAULT 0 NOT NULL,
    cabins integer DEFAULT 0 NOT NULL,
    needs_assistance boolean DEFAULT false NOT NULL,
    notes character varying(500),
    status character varying(1) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id integer NOT NULL,
    special_price numeric(8,2),
    event_id integer NOT NULL,
    donation numeric(8,2) DEFAULT 0.0,
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
    guests text,
    deleted_at timestamp(6) without time zone
);


--
-- Name: ticket_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ticket_requests_id_seq
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
    id bigint NOT NULL,
    job_id bigint NOT NULL,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    slots integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: time_slots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.time_slots_id_seq
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
    id bigint NOT NULL,
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
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    name character varying(70) NOT NULL,
    authentication_token character varying(64),
    first text,
    last text
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
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
-- Name: addons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addons ALTER COLUMN id SET DEFAULT nextval('public.addons_id_seq'::regclass);


--
-- Name: event_addons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_addons ALTER COLUMN id SET DEFAULT nextval('public.event_addons_id_seq'::regclass);


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
-- Name: ticket_request_event_addons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_request_event_addons ALTER COLUMN id SET DEFAULT nextval('public.ticket_request_event_addons_id_seq'::regclass);


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
-- Name: addons addons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addons
    ADD CONSTRAINT addons_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: event_addons event_addons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_addons
    ADD CONSTRAINT event_addons_pkey PRIMARY KEY (id);


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
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


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
-- Name: ticket_request_event_addons ticket_request_event_addons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_request_event_addons
    ADD CONSTRAINT ticket_request_event_addons_pkey PRIMARY KEY (id);


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
-- Name: index_event_addons_on_addon_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_addons_on_addon_id ON public.event_addons USING btree (addon_id);


--
-- Name: index_event_addons_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_addons_on_event_id ON public.event_addons USING btree (event_id);


--
-- Name: index_event_admins_on_event_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_event_admins_on_event_id_and_user_id ON public.event_admins USING btree (event_id, user_id);


--
-- Name: index_event_admins_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_event_admins_on_user_id ON public.event_admins USING btree (user_id);


--
-- Name: index_jobs_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_jobs_on_event_id ON public.jobs USING btree (event_id);


--
-- Name: index_payments_on_stripe_payment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_payments_on_stripe_payment_id ON public.payments USING btree (stripe_payment_id);


--
-- Name: index_price_rules_on_event_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_price_rules_on_event_id ON public.price_rules USING btree (event_id);


--
-- Name: index_shifts_on_time_slot_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shifts_on_time_slot_id ON public.shifts USING btree (time_slot_id);


--
-- Name: index_shifts_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_shifts_on_user_id ON public.shifts USING btree (user_id);


--
-- Name: index_ticket_request_event_addons_on_event_addon_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_request_event_addons_on_event_addon_id ON public.ticket_request_event_addons USING btree (event_addon_id);


--
-- Name: index_ticket_request_event_addons_on_ticket_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_request_event_addons_on_ticket_request_id ON public.ticket_request_event_addons USING btree (ticket_request_id);


--
-- Name: index_ticket_requests_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ticket_requests_on_deleted_at ON public.ticket_requests USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: index_time_slots_on_job_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_time_slots_on_job_id ON public.time_slots USING btree (job_id);


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
-- Name: event_addons fk_rails_06009452ef; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_addons
    ADD CONSTRAINT fk_rails_06009452ef FOREIGN KEY (addon_id) REFERENCES public.addons(id);


--
-- Name: event_addons fk_rails_784eec636d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.event_addons
    ADD CONSTRAINT fk_rails_784eec636d FOREIGN KEY (event_id) REFERENCES public.events(id);


--
-- Name: ticket_request_event_addons fk_rails_847e21fcca; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_request_event_addons
    ADD CONSTRAINT fk_rails_847e21fcca FOREIGN KEY (ticket_request_id) REFERENCES public.ticket_requests(id);


--
-- Name: ticket_request_event_addons fk_rails_b0497bfcb6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ticket_request_event_addons
    ADD CONSTRAINT fk_rails_b0497bfcb6 FOREIGN KEY (event_addon_id) REFERENCES public.event_addons(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20240728223048'),
('20240728211432'),
('20240718224717'),
('20240710231611'),
('20240523173316'),
('20240516225937'),
('20240513035005'),
('20240509025037'),
('20240423054549'),
('20240423054149'),
('20240418004856'),
('20240311182346'),
('20180527021019'),
('20160611234315'),
('20150609064608'),
('20140706232217'),
('20140616030905'),
('20140616024138'),
('20140611051614'),
('20140611044708'),
('20140605060026'),
('20140605053705'),
('20140605052627'),
('20140605045004'),
('20140605034909'),
('20140515054433'),
('20140515053804'),
('20140428045329'),
('20140428041744'),
('20130803212458'),
('20130707222903'),
('20130707204929'),
('20130702041357'),
('20130701054452'),
('20130701045629'),
('20130701042655'),
('20130628050717'),
('20130628042018'),
('20130616002401'),
('20130514035306'),
('20130509021514'),
('20130507051822'),
('20130427054403'),
('20130425052112'),
('20130325051758'),
('20130325024448'),
('20130311213508'),
('20130304022508'),
('20130304021739'),
('20130304020307'),
('20130228052958'),
('20130226221916'),
('20130226010856'),
('20130225033247'),
('20130224204644'),
('20130223204913'),
('20130223202959'),
('20130210233501');

