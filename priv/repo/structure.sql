--
-- PostgreSQL database dump
--

-- Dumped from database version 10.5
-- Dumped by pg_dump version 10.5

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

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
-- Name: disruption_adjustments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disruption_adjustments (
    id bigint NOT NULL,
    disruption_id bigint,
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
    monday boolean DEFAULT false NOT NULL,
    tuesday boolean DEFAULT false NOT NULL,
    wednesday boolean DEFAULT false NOT NULL,
    thursday boolean DEFAULT false NOT NULL,
    friday boolean DEFAULT false NOT NULL,
    saturday boolean DEFAULT false NOT NULL,
    sunday boolean DEFAULT false NOT NULL,
    start_time time(0) without time zone,
    end_time time(0) without time zone,
    disruption_id bigint,
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
    disruption_id bigint,
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
-- Name: disruption_trip_short_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disruption_trip_short_names (
    id bigint NOT NULL,
    trip_short_name character varying(255) NOT NULL,
    disruption_id bigint,
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
    start_date date,
    end_date date,
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
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

ALTER SEQUENCE public.disruptions_id_seq OWNED BY public.disruptions.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: adjustments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adjustments ALTER COLUMN id SET DEFAULT nextval('public.adjustments_id_seq'::regclass);


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
-- Name: disruption_trip_short_names id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_trip_short_names ALTER COLUMN id SET DEFAULT nextval('public.disruption_trip_short_names_id_seq'::regclass);


--
-- Name: disruptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruptions ALTER COLUMN id SET DEFAULT nextval('public.disruptions_id_seq'::regclass);


--
-- Name: adjustments adjustments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.adjustments
    ADD CONSTRAINT adjustments_pkey PRIMARY KEY (id);


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
-- Name: disruption_trip_short_names disruption_trip_short_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_trip_short_names
    ADD CONSTRAINT disruption_trip_short_names_pkey PRIMARY KEY (id);


--
-- Name: disruptions disruptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruptions
    ADD CONSTRAINT disruptions_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: adjustments_source_label_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX adjustments_source_label_index ON public.adjustments USING btree (source_label);


--
-- Name: disruption_adjustments_adjustment_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX disruption_adjustments_adjustment_id_index ON public.disruption_adjustments USING btree (adjustment_id);


--
-- Name: disruption_adjustments_disruption_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX disruption_adjustments_disruption_id_index ON public.disruption_adjustments USING btree (disruption_id);


--
-- Name: disruption_day_of_weeks_disruption_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX disruption_day_of_weeks_disruption_id_index ON public.disruption_day_of_weeks USING btree (disruption_id);


--
-- Name: disruption_exceptions_disruption_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX disruption_exceptions_disruption_id_index ON public.disruption_exceptions USING btree (disruption_id);


--
-- Name: disruption_trip_short_names_disruption_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX disruption_trip_short_names_disruption_id_index ON public.disruption_trip_short_names USING btree (disruption_id);


--
-- Name: disruption_adjustments disruption_adjustments_adjustment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_adjustments
    ADD CONSTRAINT disruption_adjustments_adjustment_id_fkey FOREIGN KEY (adjustment_id) REFERENCES public.adjustments(id);


--
-- Name: disruption_adjustments disruption_adjustments_disruption_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_adjustments
    ADD CONSTRAINT disruption_adjustments_disruption_id_fkey FOREIGN KEY (disruption_id) REFERENCES public.disruptions(id) ON DELETE CASCADE;


--
-- Name: disruption_day_of_weeks disruption_day_of_weeks_disruption_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_day_of_weeks
    ADD CONSTRAINT disruption_day_of_weeks_disruption_id_fkey FOREIGN KEY (disruption_id) REFERENCES public.disruptions(id) ON DELETE CASCADE;


--
-- Name: disruption_exceptions disruption_exceptions_disruption_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_exceptions
    ADD CONSTRAINT disruption_exceptions_disruption_id_fkey FOREIGN KEY (disruption_id) REFERENCES public.disruptions(id) ON DELETE CASCADE;


--
-- Name: disruption_trip_short_names disruption_trip_short_names_disruption_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruption_trip_short_names
    ADD CONSTRAINT disruption_trip_short_names_disruption_id_fkey FOREIGN KEY (disruption_id) REFERENCES public.disruptions(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

INSERT INTO public."schema_migrations" (version) VALUES (20191223181419), (20191223181443), (20191223181711), (20191223181837), (20191223182116), (20191223182231), (20200129212636);

