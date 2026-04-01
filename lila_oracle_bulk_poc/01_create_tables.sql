-- Run this in the TARGET PDB as user VICY (or a schema with privileges).
-- Staging tables (loaded from CSV)
create table stg_station (
  station_name        varchar2(200),
  gewaesser           varchar2(200),
  stationsnummer      varchar2(20),
  datenart            varchar2(20),
  dimension           varchar2(20),
  datenbezug          varchar2(50),
  zeitzone            varchar2(20),
  zeitintervall       varchar2(10),
  datentyp            varchar2(10),
  datenursprung       varchar2(50),
  flaeche             number,
  flusskilometer      number,
  vorhersagezeitpunkt varchar2(20),
  kommentar           varchar2(200)
);

create table stg_observation (
  vorhersagezeitpunkt varchar2(20),
  station_name        varchar2(200),
  ts                  varchar2(20),
  value_q             number,
  dimension           varchar2(20)
);

-- Target tables
create table station (
  station_id     number generated always as identity primary key,
  station_name   varchar2(200) not null,
  stationsnummer varchar2(20),
  gewaesser      varchar2(200),
  flaeche        number,
  flusskilometer number,
  constraint station_uk unique (station_name)
);

create table forecast_run (
  run_id              number generated always as identity primary key,
  vorhersagezeitpunkt timestamp not null,
  datenursprung       varchar2(50),
  datenbezug          varchar2(50),
  zeitzone            varchar2(20),
  zeitintervall       varchar2(10),
  datentyp            varchar2(10),
  kommentar           varchar2(200)
);

create table observation (
  run_id     number not null references forecast_run(run_id),
  station_id number not null references station(station_id),
  ts         timestamp not null,
  value_q    number,
  dimension  varchar2(20),
  constraint observation_pk primary key (run_id, station_id, ts)
);

create index observation_ts_ix on observation (ts);
