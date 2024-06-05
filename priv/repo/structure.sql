--
-- PostgreSQL database dump
--

-- Dumped from database version 14.12 (Homebrew)
-- Dumped by pg_dump version 14.12 (Homebrew)

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

--
-- Name: day_name; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.day_name AS ENUM (
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
);


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: adjustments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.adjustments (
    id bigint NOT NULL,
    source character varying(255),
    source_label character varying(255),
    route_id character varying(255),
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: adjustments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.adjustments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: adjustments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.adjustments_id_seq OWNED BY public.adjustments.id;


--
-- Name: auth_tokens; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_tokens (
    id bigint NOT NULL,
    username text NOT NULL,
    token text NOT NULL
);


--
-- Name: auth_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auth_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auth_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.auth_tokens_id_seq OWNED BY public.auth_tokens.id;


--
-- Name: disruption_adjustments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disruption_adjustments (
    id bigint NOT NULL,
    disruption_revision_id bigint,
    adjustment_id bigint
);


--
-- Name: disruption_adjustments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disruption_adjustments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disruption_adjustments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disruption_adjustments_id_seq OWNED BY public.disruption_adjustments.id;


--
-- Name: disruption_day_of_weeks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disruption_day_of_weeks (
    id bigint NOT NULL,
    day_name public.day_name NOT NULL,
    start_time time(0) without time zone,
    end_time time(0) without time zone,
    disruption_revision_id bigint NOT NULL,
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: disruption_day_of_weeks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disruption_day_of_weeks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disruption_day_of_weeks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disruption_day_of_weeks_id_seq OWNED BY public.disruption_day_of_weeks.id;


--
-- Name: disruption_exceptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disruption_exceptions (
    id bigint NOT NULL,
    excluded_date date NOT NULL,
    disruption_revision_id bigint,
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: disruption_exceptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disruption_exceptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disruption_exceptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disruption_exceptions_id_seq OWNED BY public.disruption_exceptions.id;


--
-- Name: disruption_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disruption_notes (
    id bigint NOT NULL,
    body text NOT NULL,
    author character varying(255) NOT NULL,
    disruption_id bigint NOT NULL,
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: disruption_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disruption_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disruption_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disruption_notes_id_seq OWNED BY public.disruption_notes.id;


--
-- Name: disruption_revisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disruption_revisions (
    id bigint NOT NULL,
    start_date date,
    end_date date,
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    disruption_id bigint NOT NULL,
    author character varying(255),
    is_active boolean DEFAULT true,
    row_approved boolean DEFAULT true NOT NULL,
    description text NOT NULL,
    adjustment_kind character varying(255)
);


--
-- Name: disruption_trip_short_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disruption_trip_short_names (
    id bigint NOT NULL,
    trip_short_name character varying(255) NOT NULL,
    disruption_revision_id bigint,
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: disruption_trip_short_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disruption_trip_short_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disruption_trip_short_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disruption_trip_short_names_id_seq OWNED BY public.disruption_trip_short_names.id;


--
-- Name: disruptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disruptions (
    id bigint NOT NULL,
    published_revision_id bigint,
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    last_published_at timestamp with time zone
);


--
-- Name: disruptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disruptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disruptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disruptions_id_seq OWNED BY public.disruption_revisions.id;


--
-- Name: disruptions_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disruptions_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disruptions_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disruptions_id_seq1 OWNED BY public.disruptions.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: shapes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shapes (
    id bigint NOT NULL,
    name character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: shapes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shapes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shapes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shapes_id_seq OWNED BY public.shapes.id;


--
-- Name: adjustments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adjustments ALTER COLUMN id SET DEFAULT nextval('public.adjustments_id_seq'::regclass);


--
-- Name: auth_tokens id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_tokens ALTER COLUMN id SET DEFAULT nextval('public.auth_tokens_id_seq'::regclass);


--
-- Name: disruption_adjustments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_adjustments ALTER COLUMN id SET DEFAULT nextval('public.disruption_adjustments_id_seq'::regclass);


--
-- Name: disruption_day_of_weeks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_day_of_weeks ALTER COLUMN id SET DEFAULT nextval('public.disruption_day_of_weeks_id_seq'::regclass);


--
-- Name: disruption_exceptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_exceptions ALTER COLUMN id SET DEFAULT nextval('public.disruption_exceptions_id_seq'::regclass);


--
-- Name: disruption_notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_notes ALTER COLUMN id SET DEFAULT nextval('public.disruption_notes_id_seq'::regclass);


--
-- Name: disruption_revisions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_revisions ALTER COLUMN id SET DEFAULT nextval('public.disruptions_id_seq'::regclass);


--
-- Name: disruption_trip_short_names id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_trip_short_names ALTER COLUMN id SET DEFAULT nextval('public.disruption_trip_short_names_id_seq'::regclass);


--
-- Name: disruptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruptions ALTER COLUMN id SET DEFAULT nextval('public.disruptions_id_seq1'::regclass);


--
-- Name: shapes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shapes ALTER COLUMN id SET DEFAULT nextval('public.shapes_id_seq'::regclass);


--
-- Name: adjustments adjustments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adjustments
    ADD CONSTRAINT adjustments_pkey PRIMARY KEY (id);


--
-- Name: auth_tokens auth_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_tokens
    ADD CONSTRAINT auth_tokens_pkey PRIMARY KEY (id);


--
-- Name: disruption_adjustments disruption_adjustments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_adjustments
    ADD CONSTRAINT disruption_adjustments_pkey PRIMARY KEY (id);


--
-- Name: disruption_day_of_weeks disruption_day_of_weeks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_day_of_weeks
    ADD CONSTRAINT disruption_day_of_weeks_pkey PRIMARY KEY (id);


--
-- Name: disruption_exceptions disruption_exceptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_exceptions
    ADD CONSTRAINT disruption_exceptions_pkey PRIMARY KEY (id);


--
-- Name: disruption_notes disruption_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_notes
    ADD CONSTRAINT disruption_notes_pkey PRIMARY KEY (id);


--
-- Name: disruption_trip_short_names disruption_trip_short_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_trip_short_names
    ADD CONSTRAINT disruption_trip_short_names_pkey PRIMARY KEY (id);


--
-- Name: disruption_revisions disruptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_revisions
    ADD CONSTRAINT disruptions_pkey PRIMARY KEY (id);


--
-- Name: disruptions disruptions_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruptions
    ADD CONSTRAINT disruptions_pkey1 PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: shapes shapes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shapes
    ADD CONSTRAINT shapes_pkey PRIMARY KEY (id);


--
-- Name: adjustments_source_label_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX adjustments_source_label_index ON public.adjustments USING btree (source_label);


--
-- Name: auth_tokens_token_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_tokens_token_index ON public.auth_tokens USING btree (token);


--
-- Name: auth_tokens_username_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX auth_tokens_username_index ON public.auth_tokens USING btree (username);


--
-- Name: disruption_adjustments_adjustment_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX disruption_adjustments_adjustment_id_index ON public.disruption_adjustments USING btree (adjustment_id);


--
-- Name: disruption_adjustments_disruption_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX disruption_adjustments_disruption_id_index ON public.disruption_adjustments USING btree (disruption_revision_id);


--
-- Name: disruption_day_of_weeks_disruption_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX disruption_day_of_weeks_disruption_id_index ON public.disruption_day_of_weeks USING btree (disruption_revision_id);


--
-- Name: disruption_exceptions_disruption_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX disruption_exceptions_disruption_id_index ON public.disruption_exceptions USING btree (disruption_revision_id);


--
-- Name: disruption_notes_disruption_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX disruption_notes_disruption_id_index ON public.disruption_notes USING btree (disruption_id);


--
-- Name: disruption_trip_short_names_disruption_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX disruption_trip_short_names_disruption_id_index ON public.disruption_trip_short_names USING btree (disruption_revision_id);


--
-- Name: shapes_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX shapes_name_index ON public.shapes USING btree (name);


--
-- Name: unique_disruption_weekday; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_disruption_weekday ON public.disruption_day_of_weeks USING btree (disruption_revision_id, day_name);


--
-- Name: disruption_adjustments disruption_adjustments_adjustment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_adjustments
    ADD CONSTRAINT disruption_adjustments_adjustment_id_fkey FOREIGN KEY (adjustment_id) REFERENCES public.adjustments(id);


--
-- Name: disruption_adjustments disruption_adjustments_disruption_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_adjustments
    ADD CONSTRAINT disruption_adjustments_disruption_id_fkey FOREIGN KEY (disruption_revision_id) REFERENCES public.disruption_revisions(id) ON DELETE CASCADE;


--
-- Name: disruption_day_of_weeks disruption_day_of_weeks_disruption_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_day_of_weeks
    ADD CONSTRAINT disruption_day_of_weeks_disruption_id_fkey FOREIGN KEY (disruption_revision_id) REFERENCES public.disruption_revisions(id) ON DELETE CASCADE;


--
-- Name: disruption_exceptions disruption_exceptions_disruption_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_exceptions
    ADD CONSTRAINT disruption_exceptions_disruption_id_fkey FOREIGN KEY (disruption_revision_id) REFERENCES public.disruption_revisions(id) ON DELETE CASCADE;


--
-- Name: disruption_notes disruption_notes_disruption_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_notes
    ADD CONSTRAINT disruption_notes_disruption_id_fkey FOREIGN KEY (disruption_id) REFERENCES public.disruptions(id) ON DELETE CASCADE;


--
-- Name: disruption_revisions disruption_revisions_disruption_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_revisions
    ADD CONSTRAINT disruption_revisions_disruption_id_fkey FOREIGN KEY (disruption_id) REFERENCES public.disruptions(id) ON DELETE RESTRICT;


--
-- Name: disruption_trip_short_names disruption_trip_short_names_disruption_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_trip_short_names
    ADD CONSTRAINT disruption_trip_short_names_disruption_id_fkey FOREIGN KEY (disruption_revision_id) REFERENCES public.disruption_revisions(id) ON DELETE CASCADE;


--
-- Name: disruptions disruptions_published_revision_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruptions
    ADD CONSTRAINT disruptions_published_revision_id_fkey FOREIGN KEY (published_revision_id) REFERENCES public.disruption_revisions(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO public."schema_migrations" (version) VALUES (20191223181419);
INSERT INTO public."schema_migrations" (version) VALUES (20191223181443);
INSERT INTO public."schema_migrations" (version) VALUES (20191223181711);
INSERT INTO public."schema_migrations" (version) VALUES (20191223181837);
INSERT INTO public."schema_migrations" (version) VALUES (20191223182116);
INSERT INTO public."schema_migrations" (version) VALUES (20191223182231);
INSERT INTO public."schema_migrations" (version) VALUES (20200129212636);
INSERT INTO public."schema_migrations" (version) VALUES (20200326133115);
INSERT INTO public."schema_migrations" (version) VALUES (20200713155611);
INSERT INTO public."schema_migrations" (version) VALUES (20200812222513);
INSERT INTO public."schema_migrations" (version) VALUES (20200909124316);
INSERT INTO public."schema_migrations" (version) VALUES (20200925153736);
INSERT INTO public."schema_migrations" (version) VALUES (20210816185635);
INSERT INTO public."schema_migrations" (version) VALUES (20210921192435);
INSERT INTO public."schema_migrations" (version) VALUES (20210922191945);
INSERT INTO public."schema_migrations" (version) VALUES (20210924180538);
INSERT INTO public."schema_migrations" (version) VALUES (20211209185029);
INSERT INTO public."schema_migrations" (version) VALUES (20220105203850);
INSERT INTO public."schema_migrations" (version) VALUES (20240207224211);
INSERT INTO public."schema_migrations" (version) VALUES (20240605185923);
