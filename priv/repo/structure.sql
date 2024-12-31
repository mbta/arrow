--
-- PostgreSQL database dump
--

-- Dumped from database version 15.10 (Debian 15.10-1.pgdg120+1)
-- Dumped by pg_dump version 15.10 (Homebrew)

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


--
-- Name: direction_desc; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.direction_desc AS ENUM (
    'North',
    'South',
    'East',
    'West',
    'Northeast',
    'Northwest',
    'Southeast',
    'Southwest',
    'Clockwise',
    'Counterclockwise',
    'Inbound',
    'Outbound',
    'Loop A',
    'Loop B',
    'Loop'
);


--
-- Name: fare_class; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.fare_class AS ENUM (
    'Local Bus',
    'Inner Express',
    'Outer Express',
    'Rapid Transit',
    'Commuter Rail',
    'Ferry',
    'Free',
    'Special'
);


--
-- Name: oban_job_state; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.oban_job_state AS ENUM (
    'available',
    'scheduled',
    'executing',
    'retryable',
    'completed',
    'discarded',
    'cancelled'
);


--
-- Name: route_desc; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.route_desc AS ENUM (
    'Commuter Rail',
    'Rapid Transit',
    'Local Bus',
    'Key Bus',
    'Supplemental Bus',
    'Community Bus',
    'Commuter Bus',
    'Ferry',
    'Rail Replacement Bus',
    'Regional Rail',
    'Coverage Bus',
    'Frequent Bus'
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
    adjustment_kind character varying(255),
    title character varying(40) NOT NULL
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
-- Name: disruptionsv2; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disruptionsv2 (
    id bigint NOT NULL,
    name character varying(255),
    inserted_at timestamp(0) without time zone NOT NULL,
    updated_at timestamp(0) without time zone NOT NULL
);


--
-- Name: disruptionsv2_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disruptionsv2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disruptionsv2_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disruptionsv2_id_seq OWNED BY public.disruptionsv2.id;


--
-- Name: foreign_key_constraints; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.foreign_key_constraints AS
 SELECT pgc.conname AS name,
    ((pgc.conrelid)::regclass)::text AS origin_table,
    ((pgc.confrelid)::regclass)::text AS referenced_table,
    pg_get_constraintdef(pgc.oid, true) AS definition
   FROM pg_constraint pgc
  WHERE (pgc.contype = 'f'::"char");


--
-- Name: gtfs_agencies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gtfs_agencies (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    url character varying(255) NOT NULL,
    timezone character varying(255) NOT NULL,
    lang character varying(255),
    phone character varying(255)
);


--
-- Name: gtfs_calendar_dates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gtfs_calendar_dates (
    service_id character varying(255) NOT NULL,
    date date NOT NULL,
    exception_type integer NOT NULL,
    holiday_name character varying(255),
    CONSTRAINT exception_type_must_be_in_range CHECK ((exception_type <@ int4range(1, 2, '[]'::text)))
);


--
-- Name: gtfs_calendars; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gtfs_calendars (
    service_id character varying(255) NOT NULL,
    monday boolean NOT NULL,
    tuesday boolean NOT NULL,
    wednesday boolean NOT NULL,
    thursday boolean NOT NULL,
    friday boolean NOT NULL,
    saturday boolean NOT NULL,
    sunday boolean NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL
);


--
-- Name: gtfs_checkpoints; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gtfs_checkpoints (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL
);


--
-- Name: gtfs_directions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gtfs_directions (
    route_id character varying(255) NOT NULL,
    direction_id integer NOT NULL,
    "desc" public.direction_desc NOT NULL,
    destination character varying(255) NOT NULL
);


--
-- Name: gtfs_feed_info; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gtfs_feed_info (
    id character varying(255) NOT NULL,
    publisher_name character varying(255) NOT NULL,
    publisher_url character varying(255) NOT NULL,
    lang character varying(255) NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    version character varying(255) NOT NULL,
    contact_email character varying(255) NOT NULL
);


--
-- Name: gtfs_levels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gtfs_levels (
    id character varying(255) NOT NULL,
    index double precision NOT NULL,
    name character varying(255)
);


--
-- Name: gtfs_lines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gtfs_lines (
    id character varying(255) NOT NULL,
    short_name character varying(255),
    long_name character varying(255) NOT NULL,
    "desc" character varying(255),
    url character varying(255),
    color character varying(255) NOT NULL,
    text_color character varying(255) NOT NULL,
    sort_order integer NOT NULL
);


--
-- Name: gtfs_route_patterns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gtfs_route_patterns (
    id character varying(255) NOT NULL,
    route_id character varying(255) NOT NULL,
    direction_id integer NOT NULL,
    name character varying(255) NOT NULL,
    time_desc character varying(255),
    typicality integer NOT NULL,
    sort_order integer NOT NULL,
    representative_trip_id character varying(255) NOT NULL,
    canonical integer NOT NULL,
    CONSTRAINT canonical_must_be_in_range CHECK ((canonical <@ int4range(0, 2, '[]'::text))),
    CONSTRAINT typicality_must_be_in_range CHECK ((typicality <@ int4range(0, 5, '[]'::text)))
);


--
-- Name: gtfs_routes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gtfs_routes (
    id character varying(255) NOT NULL,
    agency_id character varying(255) NOT NULL,
    short_name character varying(255),
    long_name character varying(255),
    "desc" public.route_desc NOT NULL,
    type integer NOT NULL,
    url character varying(255),
    color character varying(255),
    text_color character varying(255),
    sort_order integer NOT NULL,
    fare_class public.fare_class NOT NULL,
    line_id character varying(255),
    listed_route integer,
    network_id character varying(255) NOT NULL,
    CONSTRAINT listed_route_must_be_in_range CHECK ((listed_route <@ int4range(0, 1, '[]'::text))),
    CONSTRAINT type_must_be_in_range CHECK ((type <@ int4range(0, 4, '[]'::text)))
);


--
-- Name: gtfs_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gtfs_services (
    id character varying(255) NOT NULL
);


--
-- Name: gtfs_shape_points; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gtfs_shape_points (
    shape_id character varying(255) NOT NULL,
    lat double precision NOT NULL,
    lon double precision NOT NULL,
    sequence integer NOT NULL,
    dist_traveled double precision
);


--
-- Name: gtfs_shapes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gtfs_shapes (
    id character varying(255) NOT NULL
);


--
-- Name: gtfs_stop_times; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gtfs_stop_times (
    trip_id character varying(255) NOT NULL,
    arrival_time character varying(255) NOT NULL,
    departure_time character varying(255) NOT NULL,
    stop_id character varying(255) NOT NULL,
    stop_sequence integer NOT NULL,
    stop_headsign character varying(255),
    pickup_type integer NOT NULL,
    drop_off_type integer NOT NULL,
    timepoint integer,
    checkpoint_id character varying(255),
    continuous_pickup integer,
    continuous_drop_off integer,
    CONSTRAINT continuous_drop_off_must_be_in_range CHECK ((continuous_drop_off <@ int4range(0, 3, '[]'::text))),
    CONSTRAINT continuous_pickup_must_be_in_range CHECK ((continuous_pickup <@ int4range(0, 3, '[]'::text))),
    CONSTRAINT drop_off_type_must_be_in_range CHECK ((drop_off_type <@ int4range(0, 3, '[]'::text))),
    CONSTRAINT pickup_type_must_be_in_range CHECK ((pickup_type <@ int4range(0, 3, '[]'::text))),
    CONSTRAINT timepoint_must_be_in_range CHECK ((timepoint <@ int4range(0, 1, '[]'::text)))
);


--
-- Name: gtfs_stops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gtfs_stops (
    id character varying(255) NOT NULL,
    code character varying(255),
    name character varying(255) NOT NULL,
    "desc" character varying(255),
    platform_code character varying(255),
    platform_name character varying(255),
    lat double precision,
    lon double precision,
    zone_id character varying(255),
    address character varying(255),
    url character varying(255),
    level_id character varying(255),
    location_type integer NOT NULL,
    parent_station_id character varying(255),
    wheelchair_boarding integer NOT NULL,
    municipality character varying(255),
    on_street character varying(255),
    at_street character varying(255),
    vehicle_type integer,
    CONSTRAINT location_type_must_be_in_range CHECK ((location_type <@ int4range(0, 4, '[]'::text))),
    CONSTRAINT vehicle_type_must_be_in_range CHECK ((vehicle_type <@ int4range(0, 4, '[]'::text))),
    CONSTRAINT wheelchair_boarding_must_be_in_range CHECK ((wheelchair_boarding <@ int4range(0, 2, '[]'::text)))
);


--
-- Name: gtfs_trips; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gtfs_trips (
    id character varying(255) NOT NULL,
    route_id character varying(255) NOT NULL,
    service_id character varying(255) NOT NULL,
    headsign character varying(255) NOT NULL,
    short_name character varying(255),
    direction_id integer NOT NULL,
    block_id character varying(255),
    shape_id character varying(255),
    wheelchair_accessible integer NOT NULL,
    route_type integer,
    route_pattern_id character varying(255) NOT NULL,
    bikes_allowed integer NOT NULL,
    CONSTRAINT bikes_allowed_must_be_in_range CHECK ((bikes_allowed <@ int4range(0, 2, '[]'::text))),
    CONSTRAINT route_type_must_be_in_range CHECK ((route_type <@ int4range(0, 4, '[]'::text))),
    CONSTRAINT wheelchair_accessible_must_be_in_range CHECK ((wheelchair_accessible <@ int4range(0, 2, '[]'::text)))
);


--
-- Name: oban_jobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oban_jobs (
    id bigint NOT NULL,
    state public.oban_job_state DEFAULT 'available'::public.oban_job_state NOT NULL,
    queue text DEFAULT 'default'::text NOT NULL,
    worker text NOT NULL,
    args jsonb DEFAULT '{}'::jsonb NOT NULL,
    errors jsonb[] DEFAULT ARRAY[]::jsonb[] NOT NULL,
    attempt integer DEFAULT 0 NOT NULL,
    max_attempts integer DEFAULT 20 NOT NULL,
    inserted_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    scheduled_at timestamp without time zone DEFAULT timezone('UTC'::text, now()) NOT NULL,
    attempted_at timestamp without time zone,
    completed_at timestamp without time zone,
    attempted_by text[],
    discarded_at timestamp without time zone,
    priority integer DEFAULT 0 NOT NULL,
    tags text[] DEFAULT ARRAY[]::text[],
    meta jsonb DEFAULT '{}'::jsonb,
    cancelled_at timestamp without time zone,
    CONSTRAINT attempt_range CHECK (((attempt >= 0) AND (attempt <= max_attempts))),
    CONSTRAINT positive_max_attempts CHECK ((max_attempts > 0)),
    CONSTRAINT queue_length CHECK (((char_length(queue) > 0) AND (char_length(queue) < 128))),
    CONSTRAINT worker_length CHECK (((char_length(worker) > 0) AND (char_length(worker) < 128)))
);


--
-- Name: TABLE oban_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.oban_jobs IS '12';


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.oban_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: oban_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.oban_jobs_id_seq OWNED BY public.oban_jobs.id;


--
-- Name: oban_peers; Type: TABLE; Schema: public; Owner: -
--

CREATE UNLOGGED TABLE public.oban_peers (
    name text NOT NULL,
    node text NOT NULL,
    started_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL
);


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
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    bucket text,
    path text,
    prefix text
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
-- Name: shuttle_route_stops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shuttle_route_stops (
    id bigint NOT NULL,
    direction_id character varying(255),
    stop_sequence integer,
    time_to_next_stop numeric,
    shuttle_route_id bigint,
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    stop_id bigint,
    gtfs_stop_id character varying(255)
);


--
-- Name: shuttle_route_stops_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shuttle_route_stops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shuttle_route_stops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shuttle_route_stops_id_seq OWNED BY public.shuttle_route_stops.id;


--
-- Name: shuttle_routes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shuttle_routes (
    id bigint NOT NULL,
    direction_id character varying(255),
    direction_desc character varying(255),
    destination character varying(255),
    waypoint character varying(255),
    suffix character varying(255),
    shuttle_id bigint,
    shape_id bigint,
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: shuttle_routes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shuttle_routes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shuttle_routes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shuttle_routes_id_seq OWNED BY public.shuttle_routes.id;


--
-- Name: shuttles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.shuttles (
    id bigint NOT NULL,
    shuttle_name character varying(255),
    disrupted_route_id character varying,
    status character varying(255),
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: shuttles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.shuttles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shuttles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.shuttles_id_seq OWNED BY public.shuttles.id;


--
-- Name: stops; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.stops (
    id bigint NOT NULL,
    stop_id character varying(255) NOT NULL,
    stop_name character varying(255) NOT NULL,
    stop_desc character varying(255) NOT NULL,
    platform_code character varying(255),
    platform_name character varying(255),
    stop_lat double precision NOT NULL,
    stop_lon double precision NOT NULL,
    stop_address character varying(255),
    zone_id character varying(255),
    level_id character varying(255),
    parent_station character varying(255),
    municipality character varying(255) NOT NULL,
    on_street character varying(255),
    at_street character varying(255),
    inserted_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


--
-- Name: stops_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.stops_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stops_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.stops_id_seq OWNED BY public.stops.id;


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
-- Name: disruptionsv2 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruptionsv2 ALTER COLUMN id SET DEFAULT nextval('public.disruptionsv2_id_seq'::regclass);


--
-- Name: oban_jobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_jobs ALTER COLUMN id SET DEFAULT nextval('public.oban_jobs_id_seq'::regclass);


--
-- Name: shapes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shapes ALTER COLUMN id SET DEFAULT nextval('public.shapes_id_seq'::regclass);


--
-- Name: shuttle_route_stops id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shuttle_route_stops ALTER COLUMN id SET DEFAULT nextval('public.shuttle_route_stops_id_seq'::regclass);


--
-- Name: shuttle_routes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shuttle_routes ALTER COLUMN id SET DEFAULT nextval('public.shuttle_routes_id_seq'::regclass);


--
-- Name: shuttles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shuttles ALTER COLUMN id SET DEFAULT nextval('public.shuttles_id_seq'::regclass);


--
-- Name: stops id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stops ALTER COLUMN id SET DEFAULT nextval('public.stops_id_seq'::regclass);


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
-- Name: disruptionsv2 disruptionsv2_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disruptionsv2
    ADD CONSTRAINT disruptionsv2_pkey PRIMARY KEY (id);


--
-- Name: gtfs_agencies gtfs_agencies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_agencies
    ADD CONSTRAINT gtfs_agencies_pkey PRIMARY KEY (id);


--
-- Name: gtfs_calendar_dates gtfs_calendar_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_calendar_dates
    ADD CONSTRAINT gtfs_calendar_dates_pkey PRIMARY KEY (service_id, date);


--
-- Name: gtfs_calendars gtfs_calendars_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_calendars
    ADD CONSTRAINT gtfs_calendars_pkey PRIMARY KEY (service_id);


--
-- Name: gtfs_checkpoints gtfs_checkpoints_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_checkpoints
    ADD CONSTRAINT gtfs_checkpoints_pkey PRIMARY KEY (id);


--
-- Name: gtfs_directions gtfs_directions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_directions
    ADD CONSTRAINT gtfs_directions_pkey PRIMARY KEY (route_id, direction_id);


--
-- Name: gtfs_feed_info gtfs_feed_info_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_feed_info
    ADD CONSTRAINT gtfs_feed_info_pkey PRIMARY KEY (id);


--
-- Name: gtfs_levels gtfs_levels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_levels
    ADD CONSTRAINT gtfs_levels_pkey PRIMARY KEY (id);


--
-- Name: gtfs_lines gtfs_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_lines
    ADD CONSTRAINT gtfs_lines_pkey PRIMARY KEY (id);


--
-- Name: gtfs_route_patterns gtfs_route_patterns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_route_patterns
    ADD CONSTRAINT gtfs_route_patterns_pkey PRIMARY KEY (id);


--
-- Name: gtfs_routes gtfs_routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_routes
    ADD CONSTRAINT gtfs_routes_pkey PRIMARY KEY (id);


--
-- Name: gtfs_services gtfs_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_services
    ADD CONSTRAINT gtfs_services_pkey PRIMARY KEY (id);


--
-- Name: gtfs_shape_points gtfs_shape_points_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_shape_points
    ADD CONSTRAINT gtfs_shape_points_pkey PRIMARY KEY (shape_id, sequence);


--
-- Name: gtfs_shapes gtfs_shapes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_shapes
    ADD CONSTRAINT gtfs_shapes_pkey PRIMARY KEY (id);


--
-- Name: gtfs_stop_times gtfs_stop_times_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_stop_times
    ADD CONSTRAINT gtfs_stop_times_pkey PRIMARY KEY (trip_id, stop_sequence);


--
-- Name: gtfs_stops gtfs_stops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_stops
    ADD CONSTRAINT gtfs_stops_pkey PRIMARY KEY (id);


--
-- Name: gtfs_trips gtfs_trips_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_trips
    ADD CONSTRAINT gtfs_trips_pkey PRIMARY KEY (id);


--
-- Name: oban_jobs non_negative_priority; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.oban_jobs
    ADD CONSTRAINT non_negative_priority CHECK ((priority >= 0)) NOT VALID;


--
-- Name: oban_jobs oban_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_jobs
    ADD CONSTRAINT oban_jobs_pkey PRIMARY KEY (id);


--
-- Name: oban_peers oban_peers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oban_peers
    ADD CONSTRAINT oban_peers_pkey PRIMARY KEY (name);


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
-- Name: shuttle_route_stops shuttle_route_stops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shuttle_route_stops
    ADD CONSTRAINT shuttle_route_stops_pkey PRIMARY KEY (id);


--
-- Name: shuttle_routes shuttle_routes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shuttle_routes
    ADD CONSTRAINT shuttle_routes_pkey PRIMARY KEY (id);


--
-- Name: shuttles shuttles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shuttles
    ADD CONSTRAINT shuttles_pkey PRIMARY KEY (id);


--
-- Name: stops stops_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.stops
    ADD CONSTRAINT stops_pkey PRIMARY KEY (id);


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
-- Name: gtfs_stops_lat_lon_vehicle_type_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX gtfs_stops_lat_lon_vehicle_type_id_index ON public.gtfs_stops USING btree (lat, lon, vehicle_type, id);


--
-- Name: gtfs_stops_lat_lon_vehicle_type_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX gtfs_stops_lat_lon_vehicle_type_index ON public.gtfs_stops USING btree (lat, lon, vehicle_type);


--
-- Name: oban_jobs_args_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_args_index ON public.oban_jobs USING gin (args);


--
-- Name: oban_jobs_meta_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_meta_index ON public.oban_jobs USING gin (meta);


--
-- Name: oban_jobs_state_queue_priority_scheduled_at_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX oban_jobs_state_queue_priority_scheduled_at_id_index ON public.oban_jobs USING btree (state, queue, priority, scheduled_at, id);


--
-- Name: shapes_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX shapes_name_index ON public.shapes USING btree (name);


--
-- Name: shuttle_route_stops_shuttle_route_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX shuttle_route_stops_shuttle_route_id_index ON public.shuttle_route_stops USING btree (shuttle_route_id);


--
-- Name: shuttle_routes_shape_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX shuttle_routes_shape_id_index ON public.shuttle_routes USING btree (shape_id);


--
-- Name: shuttle_routes_shuttle_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX shuttle_routes_shuttle_id_index ON public.shuttle_routes USING btree (shuttle_id);


--
-- Name: shuttles_shuttle_name_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX shuttles_shuttle_name_index ON public.shuttles USING btree (shuttle_name);


--
-- Name: stops_stop_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX stops_stop_id_index ON public.stops USING btree (stop_id);


--
-- Name: stops_stop_lat_stop_lon_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stops_stop_lat_stop_lon_index ON public.stops USING btree (stop_lat, stop_lon);


--
-- Name: stops_stop_lat_stop_lon_stop_id_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX stops_stop_lat_stop_lon_stop_id_index ON public.stops USING btree (stop_lat, stop_lon, stop_id);


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
-- Name: gtfs_calendar_dates gtfs_calendar_dates_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_calendar_dates
    ADD CONSTRAINT gtfs_calendar_dates_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.gtfs_services(id);


--
-- Name: gtfs_calendars gtfs_calendars_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_calendars
    ADD CONSTRAINT gtfs_calendars_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.gtfs_services(id);


--
-- Name: gtfs_directions gtfs_directions_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_directions
    ADD CONSTRAINT gtfs_directions_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.gtfs_routes(id);


--
-- Name: gtfs_route_patterns gtfs_route_patterns_direction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_route_patterns
    ADD CONSTRAINT gtfs_route_patterns_direction_id_fkey FOREIGN KEY (direction_id, route_id) REFERENCES public.gtfs_directions(direction_id, route_id);


--
-- Name: gtfs_route_patterns gtfs_route_patterns_representative_trip_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_route_patterns
    ADD CONSTRAINT gtfs_route_patterns_representative_trip_id_fkey FOREIGN KEY (representative_trip_id) REFERENCES public.gtfs_trips(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: gtfs_route_patterns gtfs_route_patterns_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_route_patterns
    ADD CONSTRAINT gtfs_route_patterns_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.gtfs_routes(id);


--
-- Name: gtfs_routes gtfs_routes_agency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_routes
    ADD CONSTRAINT gtfs_routes_agency_id_fkey FOREIGN KEY (agency_id) REFERENCES public.gtfs_agencies(id);


--
-- Name: gtfs_routes gtfs_routes_line_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_routes
    ADD CONSTRAINT gtfs_routes_line_id_fkey FOREIGN KEY (line_id) REFERENCES public.gtfs_lines(id);


--
-- Name: gtfs_shape_points gtfs_shape_points_shape_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_shape_points
    ADD CONSTRAINT gtfs_shape_points_shape_id_fkey FOREIGN KEY (shape_id) REFERENCES public.gtfs_shapes(id);


--
-- Name: gtfs_stop_times gtfs_stop_times_checkpoint_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_stop_times
    ADD CONSTRAINT gtfs_stop_times_checkpoint_id_fkey FOREIGN KEY (checkpoint_id) REFERENCES public.gtfs_checkpoints(id);


--
-- Name: gtfs_stop_times gtfs_stop_times_stop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_stop_times
    ADD CONSTRAINT gtfs_stop_times_stop_id_fkey FOREIGN KEY (stop_id) REFERENCES public.gtfs_stops(id);


--
-- Name: gtfs_stop_times gtfs_stop_times_trip_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_stop_times
    ADD CONSTRAINT gtfs_stop_times_trip_id_fkey FOREIGN KEY (trip_id) REFERENCES public.gtfs_trips(id);


--
-- Name: gtfs_stops gtfs_stops_level_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_stops
    ADD CONSTRAINT gtfs_stops_level_id_fkey FOREIGN KEY (level_id) REFERENCES public.gtfs_levels(id);


--
-- Name: gtfs_stops gtfs_stops_parent_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_stops
    ADD CONSTRAINT gtfs_stops_parent_station_id_fkey FOREIGN KEY (parent_station_id) REFERENCES public.gtfs_stops(id);


--
-- Name: gtfs_trips gtfs_trips_direction_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_trips
    ADD CONSTRAINT gtfs_trips_direction_id_fkey FOREIGN KEY (direction_id, route_id) REFERENCES public.gtfs_directions(direction_id, route_id);


--
-- Name: gtfs_trips gtfs_trips_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_trips
    ADD CONSTRAINT gtfs_trips_route_id_fkey FOREIGN KEY (route_id) REFERENCES public.gtfs_routes(id);


--
-- Name: gtfs_trips gtfs_trips_route_pattern_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_trips
    ADD CONSTRAINT gtfs_trips_route_pattern_id_fkey FOREIGN KEY (route_pattern_id) REFERENCES public.gtfs_route_patterns(id);


--
-- Name: gtfs_trips gtfs_trips_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_trips
    ADD CONSTRAINT gtfs_trips_service_id_fkey FOREIGN KEY (service_id) REFERENCES public.gtfs_services(id);


--
-- Name: gtfs_trips gtfs_trips_shape_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gtfs_trips
    ADD CONSTRAINT gtfs_trips_shape_id_fkey FOREIGN KEY (shape_id) REFERENCES public.gtfs_shapes(id);


--
-- Name: shuttle_route_stops shuttle_route_stops_gtfs_stop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shuttle_route_stops
    ADD CONSTRAINT shuttle_route_stops_gtfs_stop_id_fkey FOREIGN KEY (gtfs_stop_id) REFERENCES public.gtfs_stops(id);


--
-- Name: shuttle_route_stops shuttle_route_stops_shuttle_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shuttle_route_stops
    ADD CONSTRAINT shuttle_route_stops_shuttle_route_id_fkey FOREIGN KEY (shuttle_route_id) REFERENCES public.shuttle_routes(id);


--
-- Name: shuttle_route_stops shuttle_route_stops_stop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shuttle_route_stops
    ADD CONSTRAINT shuttle_route_stops_stop_id_fkey FOREIGN KEY (stop_id) REFERENCES public.stops(id);


--
-- Name: shuttle_routes shuttle_routes_shape_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shuttle_routes
    ADD CONSTRAINT shuttle_routes_shape_id_fkey FOREIGN KEY (shape_id) REFERENCES public.shapes(id);


--
-- Name: shuttle_routes shuttle_routes_shuttle_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shuttle_routes
    ADD CONSTRAINT shuttle_routes_shuttle_id_fkey FOREIGN KEY (shuttle_id) REFERENCES public.shuttles(id);


--
-- Name: shuttles shuttles_disrupted_route_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.shuttles
    ADD CONSTRAINT shuttles_disrupted_route_id_fkey FOREIGN KEY (disrupted_route_id) REFERENCES public.gtfs_routes(id);


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
INSERT INTO public."schema_migrations" (version) VALUES (20240606171008);
INSERT INTO public."schema_migrations" (version) VALUES (20240610185146);
INSERT INTO public."schema_migrations" (version) VALUES (20240611001158);
INSERT INTO public."schema_migrations" (version) VALUES (20240611173539);
INSERT INTO public."schema_migrations" (version) VALUES (20240628203237);
INSERT INTO public."schema_migrations" (version) VALUES (20240701173124);
INSERT INTO public."schema_migrations" (version) VALUES (20240718181932);
INSERT INTO public."schema_migrations" (version) VALUES (20240826153959);
INSERT INTO public."schema_migrations" (version) VALUES (20240826154124);
INSERT INTO public."schema_migrations" (version) VALUES (20240826154204);
INSERT INTO public."schema_migrations" (version) VALUES (20240826154208);
INSERT INTO public."schema_migrations" (version) VALUES (20240826154213);
INSERT INTO public."schema_migrations" (version) VALUES (20240826154218);
INSERT INTO public."schema_migrations" (version) VALUES (20241003182524);
INSERT INTO public."schema_migrations" (version) VALUES (20241010164333);
INSERT INTO public."schema_migrations" (version) VALUES (20241010164455);
INSERT INTO public."schema_migrations" (version) VALUES (20241010164555);
INSERT INTO public."schema_migrations" (version) VALUES (20241018202407);
INSERT INTO public."schema_migrations" (version) VALUES (20241029192033);
INSERT INTO public."schema_migrations" (version) VALUES (20241030181351);
INSERT INTO public."schema_migrations" (version) VALUES (20241209204043);
INSERT INTO public."schema_migrations" (version) VALUES (20241210155455);
INSERT INTO public."schema_migrations" (version) VALUES (20241219160941);
INSERT INTO public."schema_migrations" (version) VALUES (20241231110033);
