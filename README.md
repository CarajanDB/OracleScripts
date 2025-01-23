Oracle Database scripts
-----------------------

dboracle.service   --> Service fuer Linux systemd 
dbstart            --> Startkript fuer Datenbank und listener
dbstop             --> Stopskript fuer Datenbank und listener
env                --> Variablen, falls die Verzeichnisstruktur vom Default abweicht (z.B. ORACLE_BASE=/u01/app/oracle)

Vorgehensweise bei der Installation:

cp dbstart dbstop /usr/local/bin
chmod 755 /usr/local/bin/dbs*
cp dboracle.service /lib/systemd/system
systemctl daemon-reload
systemctl start dboracle.service
systemctl enable dboracle.service


header             --> keines Tool, um die Header Informationen (version, datum, autor, bemerkung) zu pflegen
what               --> kleines Tool, um die Headerinformationen abzufragen

