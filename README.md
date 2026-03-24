Oracle Database scripts
-----------------------

bin-Verzeichnis

dboracle.service   --> Service fuer Linux systemd 
dbstart            --> Startkript fuer Datenbank und listener
dbstop             --> Stoppskript fuer Datenbank und listener
clonepdb           --> Clone einer PDB fuer ein Testsystem
log4sh             --> Shell Logger

Vorgehensweise bei der Installation fuer den Automatischen Startup der Oracle Datenbank

cp dboracle.service /lib/systemd/system
systemctl daemon-reload
systemctl start dboracle.service
systemctl enable dboracle.service

lib-Verzeichnis
CarajanDB.lib     --> Library mit einfachen Shell Funktionen
log4sh.properties --> Logger Properties fuer Shell Skripte
