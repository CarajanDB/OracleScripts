-- Load process: truncate staging, load CSVs, then run this merge script.

-- 1) Upsert stations
merge into station s
using (
  select distinct
    station_name, stationsnummer, gewaesser, flaeche, flusskilometer
  from stg_station
) st
on (s.station_name = st.station_name)
when matched then update set
  s.stationsnummer = st.stationsnummer,
  s.gewaesser      = st.gewaesser,
  s.flaeche        = st.flaeche,
  s.flusskilometer = st.flusskilometer
when not matched then insert (
  station_name, stationsnummer, gewaesser, flaeche, flusskilometer
) values (
  st.station_name, st.stationsnummer, st.gewaesser, st.flaeche, st.flusskilometer
);

-- 2) Insert/merge forecast run (one per vorhersagezeitpunkt)
merge into forecast_run fr
using (
  select
    to_timestamp(vorhersagezeitpunkt, 'DD.MM.YYYY HH24:MI') as vorhersagezeitpunkt,
    max(datenursprung) as datenursprung,
    max(datenbezug)    as datenbezug,
    max(zeitzone)      as zeitzone,
    max(zeitintervall) as zeitintervall,
    max(datentyp)      as datentyp,
    max(kommentar)     as kommentar
  from stg_station
  group by to_timestamp(vorhersagezeitpunkt, 'DD.MM.YYYY HH24:MI')
) src
on (fr.vorhersagezeitpunkt = src.vorhersagezeitpunkt)
when not matched then insert (
  vorhersagezeitpunkt, datenursprung, datenbezug, zeitzone, zeitintervall, datentyp, kommentar
) values (
  src.vorhersagezeitpunkt, src.datenursprung, src.datenbezug, src.zeitzone, src.zeitintervall, src.datentyp, src.kommentar
);

-- 3) Insert observations (idempotent via PK / NOT EXISTS)
insert /*+ append */ into observation (run_id, station_id, ts, value_q, dimension)
select
  fr.run_id,
  s.station_id,
  to_timestamp(so.ts, 'DD.MM.YYYY HH24:MI') as ts,
  so.value_q,
  so.dimension
from stg_observation so
join station s
  on s.station_name = so.station_name
join forecast_run fr
  on fr.vorhersagezeitpunkt = to_timestamp(so.vorhersagezeitpunkt, 'DD.MM.YYYY HH24:MI')
where not exists (
  select 1
  from observation o
  where o.run_id = fr.run_id
    and o.station_id = s.station_id
    and o.ts = to_timestamp(so.ts, 'DD.MM.YYYY HH24:MI')
);

commit;

-- Quick sanity checks
-- select count(*) stations from station;
-- select count(*) runs from forecast_run;
-- select count(*) obs from observation;
