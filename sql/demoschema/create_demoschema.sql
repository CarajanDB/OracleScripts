/************************************************************************
**
** CarajanDB GmbH
**
** Autor: Johannes Ahrends
*************************************************************************/

PROMPT Anlegen des Demo-Benutzers!
SET VERIFY OFF
SET ECHO OFF

ACCEPT BENUTZER CHAR PROMPT  'Bitte Demo-Benutzernamen eingeben (VORSICHT, das Schema wird geloescht!): '

SELECT tablespace_name
  FROM dba_tablespaces;
ACCEPT DEFTS CHAR PROMPT  'Bitte Default Tablespace eingeben fuer Benutzer &BENUTZER. angeben: '
DEFINE STAMM = demostamm

DROP USER &benutzer. CASCADE
/
WHENEVER SQLERROR EXIT SQL.SQLCODE
CREATE USER &benutzer.
IDENTIFIED BY &benutzer.
DEFAULT TABLESPACE &defts.
/
GRANT CONNECT, RESOURCE TO &benutzer.
/
GRANT EXECUTE ON DBMS_LOCK TO &benutzer.
/
GRANT EXECUTE ON DBMS_RANDOM TO &benutzer.
/
ALTER USER &benutzer. QUOTA UNLIMITED ON &defts.
/

SET TERMOUT ON

ALTER SESSION SET CURRENT_SCHEMA = &BENUTZER.;
WHENEVER SQLERROR CONTINUE
@@create_demotables.sql

