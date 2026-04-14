#!/bin/bash
################################################################################
#
# Beschreibung: Löschen von audit files und alert files
#               Überprüfung Existenz von temp files
#
# Autor:        F. Karabacak CarajanDB GmbH
# Datum:        2026-02-09
# Version:      1.0
#
# Historie:
#
# Version  Datum       Autor           Beschreibung
# -------  ----------- --------------- ----------------------------------------------------------
#   1.0    2026-02-09  F. Karabacak    Initiales Script
#
################################################################################

## Variable

LOG4SH_URL="https://raw.githubusercontent.com/CarajanDB/OracleScripts/refs/heads/main/bin/log4sh"
LOG4SHPROPERTIES_URL="https://raw.githubusercontent.com/CarajanDB/OracleScripts/refs/heads/main/lib/log4sh.properties"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG4SH=log4sh
LOG4SHPROP=log4sh.properties

## Farbcodes
RED="\033[31m"
YELLOW="\033[33m"
GREEN="\033[32m"
FIN="\033[0m"

##################################################
##      Download log4sh falls nicht vorhanden   ##
##################################################

if [[ -f "$SCRIPT_DIR/$LOG4SH" ]]; then
    echo -e "log4sh vorhanden"
else
    echo -e ""$YELLOW" log4sh fehlt – lade herunter $FIN"
    cd $SCRIPT_DIR
    wget "$LOG4SH_URL" || {
        echo -e ""$RED"FEHLER: Download fehlgeschlagen $FIN" >&2
        exit 1
    }

    chmod +x "/$SCRIPT_DIR/$LOG4SH"
    echo -e ""$GREEN"log4sh erfolgreich geladen $FIN"
fi

if [[ -f "$SCRIPT_DIR/$LOG4SHPROP" ]]; then
    echo -e "log4sh.properties vorhanden"
else
    echo "log4sh.properties fehlt – lade herunter"
    cd $SCRIPT_DIR
    wget "$LOG4SHPROPERTIES_URL" || {
        echo -e ""$RED"FEHLER: Download fehlgeschlagen $FIN" >&2
        exit 1
    }

    chmod +x "/$SCRIPT_DIR/$LOG4SHPROP"
    echo -e ""$GREEN"log4sh.properties erfolgreich geladen $FIN"
fi

## log4sh Variable
VARIABLE=$(basename $0)
. log4sh

# =================================================================================================
#
# Funktionen
#
# =================================================================================================


##################################################
##      Function:       Usage                   ##
##################################################

Usage() {
  echo "Usage: $0 -d -a <ACTION>"
  echo "-d | --database      : Name der Datenbank (CDB)"
  echo "-a | --action        : Action (deletealert, deleteaudit)"
  echo "       deletealert   : löscht die Einträge im alert.log älter als 30 Tage"
  echo "       deleteaudit   : löscht alle audit files älter als 30 Tage"
  echo "       delalertall   : dasselbe wie deletealert aber in allen CDB's"
  echo "       delauditall   : dasselbe wie deleteaudit aber in allen CDB's"
  echo "       checktmp      : überprüft die Temp Files"
  exit 1
}
##################################################
##      Function: Delete Audit Files            ##
##################################################
DeleteAudit() {
AUDIT_DIR=$(sqlplus -s / as sysdba <<EOF | xargs
set pagesize 0
set feedback off
set heading off
set verify off
set echo off
set termout off
SELECT value FROM v\$parameter WHERE name = 'audit_file_dest';
exit;
EOF
)

find $AUDIT_DIR -type f -mtime +30 -print -delete

RC=$?

if [ $RC -eq 0  ]; then
        echo -e ""$GREEN"Alle audit files älter als 30 Tage wurden gelöscht in $AUDIT_DIR $FIN"
else
        echo -e ""$RED"Vorgang konnte nicht durchgeführt werden$FIN"
fi
}

##################################################
##      Function: Delete Audit Files            ##
##################################################

DelAuditAll() {
for DATABASE in $(ps -ef | grep ora_pmon_ | grep -v grep | awk -F_ '{print $3}')
do
export ORACLE_SID=$DATABASE
ORAENV_ASK=NO
. oraenv -s
unset ORAENV_ASK

AUDIT_DIR=$(sqlplus -s / as sysdba <<EOF | xargs
set pagesize 0
set feedback off
set heading off
set verify off
set echo off
set termout off
SELECT value FROM v\$parameter WHERE name = 'audit_file_dest';
exit;
EOF
)

find $AUDIT_DIR -type f -mtime +30 -print -delete

RC=$?

if [ $RC -eq 0  ]; then
        echo -e ""$GREEN"Alle audit files älter als 30 Tage wurden gelöscht in $AUDIT_DIR $FIN"
else
        echo -e ""$RED"Vorgang konnte nicht durchgeführt werden $FIN"
fi
done
}
##################################################
##      Function: Delete Alert Log              ##
##################################################
DeleteAlert() {
ALERT_DIR=$(sqlplus -s / as sysdba <<EOF | xargs
set pagesize 0
set feedback off
set heading off
set verify off
set echo off
set termout off
SELECT value FROM v\$diag_info WHERE name = 'Diag Trace';
exit;
EOF
)
ALERT_LOG="$ALERT_DIR/alert_${DATABASE}.log"

i=30
FOUND_DATE=""
FOUND_LINE=""

while true; do
    DATE_X=$(date -d "$i days ago" +%Y-%m-%d)

    LINE=$(grep -n "^$DATE_X" "$ALERT_LOG" | tail -1 | cut -d: -f1)

    if [ -n "$LINE" ]; then
        FOUND_DATE="$DATE_X"
        FOUND_LINE="$LINE"
        break
    fi

    ((i++))
done

if [ -n "$FOUND_LINE" ]; then
    echo -e ""$YELLOW"Gefunden: $FOUND_DATE in Zeile $FOUND_LINE $FIN"
else
    echo -e ""$GREEN"Kein Eintrag älter als 30 Tage gefunden $FIN"
fi

if [ -n "$FOUND_LINE" ] && [ "$FOUND_LINE" -gt 1 ]; then
    ex -s "$ALERT_LOG" <<EOF
1,$((FOUND_LINE-1))d
w
q
EOF

RC=$?

if [ $RC -eq 0  ]; then
        echo -e ""$GREEN"alle Einträge älter als $DATE_X wurden gelöscht (bis Zeile $((FOUND_LINE-1))) $FIN"
fi
else
        echo -e ""$YELLOW"Keine alten Logeinträge zu löschen $FIN"
fi
}


##################################################
##      Function: Delete All CDB Alert Logs     ##
##################################################
DelAlertAll() {
for DATABASE in $(ps -ef | grep ora_pmon_ | grep -v grep | awk -F_ '{print $3}')
do
export ORACLE_SID=$DATABASE
ORAENV_ASK=NO
. oraenv -s
unset ORAENV_ASK

ALERT_DIR=$(sqlplus -s / as sysdba <<EOF
set pagesize 0 feedback off heading off
select value from v\$diag_info where name='Diag Trace';
exit;
EOF
)
        ALERT_DIR=$(echo "$ALERT_DIR" | xargs)

        ALERT_LOG="$ALERT_DIR/alert_${DATABASE}.log"

i=30
FOUND_DATE=""
FOUND_LINE=""

while true; do
    DATE_X=$(date -d "$i days ago" +%Y-%m-%d)

    LINE=$(grep -n "^$DATE_X" "$ALERT_LOG" | tail -1 | cut -d: -f1)

    if [ -n "$LINE" ]; then
        FOUND_DATE="$DATE_X"
        FOUND_LINE="$LINE"
        break
    fi

    ((i++))
done

SIZE_MB=$(( $(stat -c %s "$ALERT_LOG") / 1024 / 1024 ))
if [ "$SIZE_MB" -gt 80 ]; then
    echo -e ""$YELLOW"$ALERT_LOG ist $SIZE_MB MB $FIN"

if [ -n "$FOUND_LINE" ]; then
    echo -e ""$YELLOW"Gefunden: $FOUND_DATE in Zeile $FOUND_LINE $FIN"
else
    echo -e ""$GREEN"Kein Eintrag älter als 30 Tage gefunden $FIN"
fi

if [ -n "$FOUND_LINE" ] && [ "$FOUND_LINE" -gt 1 ]; then
    ex -s "$ALERT_LOG" <<EOF
1,$((FOUND_LINE-1))d
w
q
EOF

RC=$?

if [ $RC -eq 0  ]; then

        echo -e ""$YELLOW"alle Einträge in $ALERT_LOG älter als $DATE_X wurden gelöscht (bis Zeile $((FOUND_LINE-1))). $FIN"
fi
else
        echo -e ""$GREEN"Keine alten Logeinträge zu löschen $FIN"
fi
fi
done
}

##################################################
##      Function:  Locate Temp Files            ##
##################################################
CheckTmpFile() {

for DATABASE in $(ps -ef | grep ora_pmon_ | grep -v grep | awk -F_ '{print $3}')
do
export ORACLE_SID=$DATABASE
ORAENV_ASK=NO
. oraenv -s
unset ORAENV_ASK

TEMP_FILE=$(sqlplus -s / as sysdba <<EOF
set pagesize 0 lines 100 feedback off heading off
SELECT t.file_name FROM cdb_temp_files t JOIN v\$pdbs p ON t.con_id = p.con_id WHERE p.name NOT IN ('CDB$ROOT','PDB$SEED');
exit;
EOF
)

for FILE in $TEMP_FILE; do
    if [ -f "$FILE" ]; then
        echo -e ""$GREEN"Tempfile vorhanden: $FILE $FIN"
    else
        echo -e "WARNUNG: "$YELLOW"Tempfile fehlt: $FILE $FIN"
    fi
done
done
}
##################################################
##      Function:       Read Options            ##
##################################################

ReadOptions() {
  logger_debug "--> Function $FUNCNAME"
  if [ $# -eq 0 ]
  then
    logger_fatal "Arguments required"
    return 10
  fi
  SHORT="d:a:i:v:s:hf"
  LONG="database:,action:,install:,version:,stage:,help,force"
  logger_debug "LONG=$LONG"
  logger_debug "Arguments=$*"
  OPTIONS=$(getopt --options $SHORT --long $LONG --name "$0" -- "$@" 2>/dev/null)
  RC=$?
  logger_debug "OPTIONS=$OPTIONS"
  if [ "$RC" -ne 0 ]
  then
    logger_fatal "Invalid Arguments"
    return 11
  fi

  eval set -- $OPTIONS
  while true
  do
    case $1 in
      -d|--database)   DATABASE=$2
                       logger_debug "DATABASE=$DATABASE"
                       shift 2 ;;
      -a|--action)     ACTION=$2
                       logger_debug "ACTION=$ACTION"
                       shift 2 ;;
      -h|--help)       Usage
                       shift;;
      --)              shift;break;;

    esac
  done

#  if [ -z "$DATABASE" ]; then
#    logger_error "DATABASE-Parameter fehlt (-d|--database)"
#    Usage
#    exit 1
#  fi
  if [ -z "$ACTION" ]
  then
    logger_error "Aktion muss angegeben werden"
    exit 1
  fi
  logger_debug "<-- Function $FUNCNAME"
  return 0
}

# =================================================================================================
#
# Main
#
# =================================================================================================
#

#Logger
FORCE=0
unset STAGE
unset VERSION
ReadOptions $*
RC=$?
if [ $RC -ne 0 ]
then
  Usage $RC
fi

ACTION=$(echo $ACTION | tr '[:lower:]' '[:upper:]')

logger_debug ACTION=$ACTION



# =================================================================================================
#
# Übergabe Parameter
#
# =================================================================================================

##################################################
##             Database+. oraenv                ##
##################################################
#export ORACLE_SID=$DATABASE
#ORAENV_ASK=NO
#. oraenv -s
#unset ORAENV_ASK

##################################################
##              Delete Alert Log                ##
##################################################
if [ "$ACTION" == "DELETEALERT" ]
then
DeleteAlert
fi

##################################################
##              Delete Audit Files              ##
##################################################

if [ "$ACTION" == "DELETEAUDIT" ]
then
DeleteAudit
fi

##################################################
##          Delete All CDB Alert Logs           ##
##################################################

if [ "$ACTION" == "DELALERTALL" ]
then
DelAlertAll
fi

##################################################
##          Delete Audit Files All CDB          ##
##################################################

if [ "$ACTION" == "DELAUDITALL" ]
then
DelAuditAll
fi

##################################################
##               Check Temp File                ##
##################################################


if [ "$ACTION" == "CHECKTMP" ]
then
CheckTmpFile
fi
logger_info "Done"
