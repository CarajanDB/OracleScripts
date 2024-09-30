#!/bin/bash
# @(#) ================================================================================================================
# @(#) File........: ORAcmdbJob.sh
# @(#) Author......: Thorsten Thiel
# @(#) Modified....:
# @(#)
# @(#) Description.: maintain cmdb data
# @(#)               wrapper script for invoking perl script ORAcmdbJob from ctm
# @(#)
# @(#) Version.....: 0.6
# @(#) Datum.......: 09.08.2019
# @(#)
# @(#) Presumption.: This script
# @(#)                1. must be started as user ORACLE
# @(#)
# @@(#)  Change History:
# @@(#)
# @@(#)    0.1  25.05.2018  ThI  Created
# @@(#)    0.2  25.05.2018  THI  changed returncode handling
# @@(#)    0.3  13.12.2018  THI  do not execute in background to receive error messages
# @@(#)    0.4  13.12.2018  THI  changed returncode handling
# @@(#)    0.5  02.01.2019  THI  changed logfile handling
# @@(#)    0.6  09.08.2019  XBVY changed log cleanup pattern to ORAcmdb*
# @(#) ================================================================================================================
RC=0
DATE=`date +'%F'`
/app/oracle/bin/ORAcmdbJob -opt upd >/app/oracle/admin/log/ORAcmdbJob_${DATE}.log 2>&1
RC=$?
if [ $RC -ne 0 ]
then
   echo "RC: $RC"
fi

#cleanup logfiles
find /app/oracle/admin/log -name 'ORAcmdb*' -mtime +7 -exec rm {} \;
exit $RC
