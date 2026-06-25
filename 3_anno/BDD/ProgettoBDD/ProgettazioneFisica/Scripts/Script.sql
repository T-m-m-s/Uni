DROP SCHEMA IF EXISTS product CASCADE;
DROP SCHEMA IF EXISTS market_data CASCADE;
DROP TYPE IF EXISTS product.subscription_status CASCADE;
DROP TYPE IF EXISTS product.search_status CASCADE;

create extension if not exists "uuid-ossp";
create extension if not exists postgis;

-- SCHEMA Product 

create schema if not exists product;

-- enums

create type product.subscription_status as enum (
	'active',
	'cancelled',
	'past_due',
	'trialing'
);

create type product.search_status as enum (
	'pending',
	'completed',
	'failed'
);

-- TABLES

-- product.users

create table product.users (
	id uuid primary key default uuid_generate_v4(),
	email varchar(255) not null,
	name varchar(255) not null,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	
	constraint uq_users_email unique (email)
);

create or replace function product.set_updated_at() 
returns trigger as $$
begin
	new.updated_at = now();
	return new;
end;
$$ language plpgsql;

create trigger tr_users_updated_at
	before update on product.users
	for each row execute function product.set_updated_at();

-- product.subscription

create table product.subscription (
	id uuid primary key default uuid_generate_v4(),
	user_id uuid not null,
	plan varchar(50) not null,
	status product.subscription_status not null default 'trialing',
	current_period_end timestamptz not null,
	created_at timestamptz not null default now(),
	
	constraint fk_subscriptions_user
		foreign key (user_id) references product.users (id)
		on delete cascade
);

create index idx_subscriptions_user_id on product.subscription (user_id);
create index idx_subscriptions_status on product.subscription (status);

-- product.searches

create table product.searches (
	id uuid primary key default uuid_generate_v4(),
	user_id uuid not null,
	location_name varchar(255) not null,
	country_code char(2) not null default 'IT',
	radius_km integer not null check (radius_km > 0),
	keyword_terms jsonb not null default '[]',
	status product.search_status not null default 'pending',
	created_at timestamptz not null default now(),
	expires_at timestamptz,
	
	constraint fk_searches_user
		foreign key (user_id) references product.users (id)
		on
delete
	cascade
);

create index idx_searches_user_id on product.searches (user_id);
create index idx_searches_status on product.searches (status);
create index idx_searches_expires_at on product.searches (expires_at);

-- FINE Product SCHEMA

-- Data SCHEMA

create schema if not exists market_data;

-- enums

create type market_data.admin_level as enum (
	'city',
	'province',
	'region'
);

create type market_data.competition_level as enum (
	'LOW',
	'MEDIUM',
	'HIGH'
);

create type market_data.business_status as enum (
	'OPERATIONAL',
	'CLOSED_TEMPORARILY',
	'CLOSED_PERMANENTLY'
);

-- TABLES

-- market_data.locations

create table market_data.locations (
	id uuid primary key default uuid_generate_v4(),
	name varchar(255) not null,
	country_code char(2) not null default 'IT',
	admin_level market_data.admin_level not null default 'city',
	lat float not null,
	lng float not null, 
	boundary geometry(Polygon, 4326),
	centroid geometry(Point, 4326),
	dfs_location_code integer,
	created_at timestamptz not null default now(),
	
	constraint uq_locations_name_country_level
		unique (name, country_code, admin_level)
);

create index idx_locations_boundary on market_data.locations using gist (boundary);
create index idx_locations_centroid on market_data.locations using gist (centroid);
create index idx_locations_country on market_data.locations (country_code);

-- market_data.place_types

create table market_data.place_types (
	id uuid primary key default uuid_generate_v4(),
	google_type varchar(100) not null,
	label_it varchar(100) not null,
	category varchar(50),
	
	constraint uq_place_types_google_type unique (google_type)
);

-- market_data.keywords

create table market_data.keywords (
	id uuid primary key default uuid_generate_v4(),
	place_type_id uuid,
	term varchar(255) not null,
	created_at timestamptz not null default now(),
	
	constraint uq_keywords_term unique (term),
	constraint fk_keywords_place_type
		foreign key (place_type_id) references market_data.place_types (id)
		on delete set null
);

create index idx_keywords_place_type_id on market_data.keywords (place_type_id);

-- market_data.demand_data

create table market_data.demand_data (
	id uuid primary key default uuid_generate_v4(),
	keyword_id uuid not null,
	location_id uuid not null,
	radius_km integer not null check (radius_km > 0),
	search_volume integer check (search_volume >= 0),
	cpc float check (cpc >= 0),
	competition_index float check (competition_index >= 0 and competition_index <= 100),
	monthly_searches jsonb not null default '[]',
	fetched_at timestamptz not null default now(),
	valid_until timestamptz not null, 
	
	constraint fk_demand_keyword
		foreign key (keyword_id) references market_data.keywords (id)
		on delete cascade,
	constraint fk_demand_location
		foreign key (location_id) references market_data.locations (id)
		on delete cascade
);

create index idx_demand_keyword_id on market_data.demand_data (keyword_id);
create index idx_demand_location_id on market_data.demand_data (location_id);
create index idx_demand_valid_until on market_data.demand_data (valid_until);
create index idx_demand_cache_lookup on market_data.demand_data (keyword_id, location_id, radius_km, valid_until);

-- market_data.supply_data

create table market_data.supply_data (
	id uuid primary key default uuid_generate_v4(),
	place_type_id uuid,
	google_places_id varchar(255) not null,
	name varchar(255) not null,
	location_point geometry(Point, 4326) not null, 
	formatted_address varchar(500),
	rating_value float check (rating_value >= 1 and rating_value <= 5),
	rating_count integer check (rating_count >= 0),
	price_level float,
	business_status market_data.business_status not null default 'OPERATIONAL',
	fetched_at timestamptz not null default now(),
	valid_until timestamptz not null,
	
	constraint uq_supply_google_places_id unique (google_places_id),
	constraint fk_supply_place_type
		foreign key (place_type_id) references market_data.place_types (id)
		on delete set null
);

create index idx_supply_location_point on market_data.supply_data using gist (location_point);
create index idx_supply_place_type_id on market_data.supply_data (place_type_id);
create index idx_supply_business_status on market_data.supply_data (business_status);
create index idx_supply_valid_until on market_data.supply_data (valid_until);

-- market_data.supply_search_area

create table market_data.supply_search_area (
	supply_id uuid not null,
	location_id uuid not null, 
	radius_km integer not null check (radius_km > 0),
	recorded_at timestamptz not null default now(),
	
	constraint pk_supply_search_area
		primary key (supply_id, location_id, radius_km),
	constraint fk_ssa_supply
		foreign key (supply_id) references market_data.supply_data (id)
		on delete cascade,
	constraint fk_ssa_location
		foreign key (location_id) references market_data.locations (id)
		on delete cascade
);

create index idx_ssa_supply_id on market_data.supply_search_area (supply_id);
create index idx_ssa_location_id on market_data.supply_search_area (location_id);

-- market_data.derived_insights

create table market_data.derived_insights (
	id uuid primary key default uuid_generate_v4(),
	location_id uuid not null,
	keyword_id uuid not null,
	radius_km integer not null check (radius_km > 0),
	time_horizon varchar(10) not null,
	demand_supply_ratio float check (demand_supply_ratio >= 0),
	opportunity_index float check (opportunity_index >= 0 and opportunity_index <= 100),
	market_saturation float check (market_saturation >= 0 and opportunity_index <= 1),
	competitive_gap float,
	calculated_at timestamptz not null default now(),
	valid_until timestamptz not null,
	
	constraint uq_derived_insights_key
		unique (location_id, keyword_id, radius_km, time_horizon),
	constraint fk_derived_location
		foreign key (location_id) references market_data.locations (id)
		on delete cascade,
	constraint fk_derived_keyword
		foreign key (keyword_id) references market_data.keywords (id)
		on delete cascade
);

create index idx_derived_location_id on market_data.derived_insights (location_id);
create index idx_derived_keyword_id on market_data.derived_insights (keyword_id);
create index idx_derived_valid_until on market_data.derived_insights (valid_until);










