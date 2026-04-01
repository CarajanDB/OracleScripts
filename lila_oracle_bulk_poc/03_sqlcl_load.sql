-- SQLcl helper (run in SQLcl, connected as VICY to the PDB)
-- Adjust the paths if needed.
-- Optional: clear staging
-- Windows SQLcl load script

truncate table stg_station;
truncate table stg_observation;

-- LOAD (semicolon CSV, first row = header)
load stg_station      C:\HVZ\lila_oracle_bulk_poc\out\stations.csv      delimiter ';' skip 1
load stg_observation  C:\HVZ\lila_oracle_bulk_poc\out\observations.csv  delimiter ';' skip 1

@C:\HVZ\lila_oracle_bulk_poc\02_merge_load.sql
