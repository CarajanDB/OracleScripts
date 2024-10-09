# @(#) ============================================================================================
# @(#) Filename    : CDBlib
# @(#) Author      : Johannes Ahrends, CarajanDB GmbH
# @(#) Version     : 1.00
# @(#) Date        : 2024-09-16
# @(#) Description : Library mit allen Oracle Funktionen
# @(#)               not directly startable
# @(#)
# @@(#)  Change History:
# @@(#)  Version  Date        Author        Description
# @@(#)  ------------------------------------------------------------------------------------------
# @@(#)  1.0      2024-09-16  jahr     Basic Version
# @(#) ============================================================================================
#
#
# Functions
# getORAHome
# GetInstance
# InstUp
# InstDOwn
# Addbash_profile

#############################################################################################
#
# Function Parameter
#
#############################################################################################

function Parameter() {
  logger_debug "--> $FUNCNAME"
  logger_debug "<-- $FUNCNAME $RC"
}

# =================================================================================================
#
# Log Header
#
# =================================================================================================

log_header() {
   WHAT=$BINDIR/what
   local SCRIPTNAME=$(basename $0)
   local SCRIPTPATH=$(dirname $0)
   local SCRIPTVERSION="`$WHAT $SCRIPTDIR/$SCRIPTNAME|grep '# @(#) Version'|awk '{print $3,$4,$5}'`"
   local SCRIPTDATE="`$WHAT $SCRIPTDIR/$SCRIPTNAME|grep '# @(#) Datum'|awk '{print $3,$4,$5}'`"
   logger_info "$SCRIPTNAME gestartet"
   logger_info "$SCRIPTNAME $*"
   logger_info "$SCRIPTVERSION"
   logger_info "$SCRIPTDATE"
   logger_info "$PARAMETER"
   logger_info "$L4SH_DEBUGLOG"
}

#############################################################################################
#
# Function $Logger
#
#############################################################################################

function Logger () {
  local VARIABLE=$1
  local REINIT=${2:-0}    # Set it to 1 if you run Logger() again in same shell
  if [ -n "$COLORLOG" ]
  then
    LOG4SH=$LIBDIR/log4shcolor
  else
    LOG4SH=$LIBDIR/log4sh
  fi
  VARIABLE=''
  if [ $# -gt 0 ]
  then
    VARIABLE=$1
  fi
  if [ -r $LOG4SH ]
  then
    if [ -r log4sh.properties ]
    then
      LOG4SH_CONFIGURATION="log4sh.properties"
    else
      LOG4SH_CONFIGURATION="$SCRIPTDIR/log4sh.properties"
    fi
    if [ "$REINIT" -eq 1 ]; then
     # remove 'readonly variable' error output
      LOG4SH_CONFIGURATION=$LOG4SH_CONFIGURATION . $LOG4SH 2>/dev/null
    else
      LOG4SH_CONFIGURATION=$LOG4SH_CONFIGURATION . $LOG4SH
    fi
  else
    echo "ERROR: could not load (log4sh)" >&2
    exit 1
  fi
  # Get debug log file from LOG4SH_CONFIGURATION
  L4SH_DEBUGLOG=$(grep -i "log4sh.appender.cdbPattern.File" $LOG4SH_CONFIGURATION |
                  grep -v "^[ ]*#" | sed 's/ *log4sh.appender.cdbPattern.File *= *//')
  L4SH_DEBUGLOG=`eval echo $L4SH_DEBUGLOG`
  log_header
}
