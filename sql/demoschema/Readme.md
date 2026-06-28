## README Demoinstallation

Die Demoinstallation dient dazu, ein Schema mit (fast) beliebig vielen Daten anhand einer Auftragsverwaltung aufzubauen.
Die Anwendung besteht aus zwei Schemata:
1. Basisschema (Name frei wählbar): Hier liegen Tabellen, die nur für die Befüllung der endgültigen Tabellen verwendet werden. Bei späteren Demos wird dieses Schema nicht verwendet.
2. Demoschema (Name frei wählbar): Hier liegt die eigentliche Auftragsverwaltung bestehend aus folgenden Tabellen:
Stammdaten:
- bundesländer (liste der 16 Bundesländer)
- produkte (liste mit ca. 370 produkten)
- produktgruppen (liste mit ca. 150 produktgruppen )
- status (5 Auftragsstati)
- typen (8 Adress bzw. Telefonnumerntypen)

Bewegungsdaten:
- personen (über die Prozedure demopkg.proc_personen mit Daten gefüllt)
- adressen (2 pro Person)
- emailadressen (2 pro Person)
- telefonnummern (2 pro adresse)
- aufträge (über die Prozedur demopkg.proc_auftraege mit Daten gefüllt, zufällig auf vorhandene Personen verteilt)
- positionen (über die Prozedur demopkg.proc_positionen mit Daten gefüllt, max. 5 pro Auftrag)

=======================================================================================================================================================================================

Installation:
VORSICHT: die Schemata werden gelöscht, falls sie schon existieren!!!

Vor der Installation NLS_LANG=AMERICAN_AMERICA.UTF8 setzen

Basisdaten:
Abfrage von TNS-Alias, Schemanamen (Passwort = Schemaname), Default und TEMP-Tablespace

Beispiel 
sqlplus / as sysdba @create_basisschema

TABLESPACE_NAME
------------------------------
SYSTEM
SYSAUX
UNDOTBS1
TEMP
USERS

Bitte Default Tablespace eingeben fuer Benutzer der Basisdaten angeben: USERS
Bitte Temporary Tablespace eingeben: TEMP
Bitte Schemanamen fuer Basisdaten angeben (VORSICHT: das Schema wird gelöscht!): BASIS
...

Demoschema / Anwendung):
Bitte auf jeden Fall neu als SYS anmelden. Ansonsten wie bei Basisschema
Beispiel:
sqlplus / as sysdba @create_demoschema

Bitte Demo-Benutzernamen eingeben (VORSICHT, das Schema wird geloescht!): demo

TABLESPACE_NAME
------------------------------
SYSTEM
SYSAUX
UNDOTBS1
TEMP
USERS

Bitte Default Tablespace eingeben fuer Benutzer demo angeben: USERS
Bitte Temporary Tablespace eingeben: TEMP


=======================================================================================================================================================================================

Jetzt ist das Schema aufgebaut und die Daten können erzeugt werden. Z.B. in dieser Form:

sqlplus demo/demo

execute proc_personen(1000);
execute proc_auftraege(10000);
execute proc_positionen(5);

Damit werden 1000 Personen mit 2000 Adressen und Emailadressen sowie 4000 Telefonnumern erstellt.
Dann werden 10000 Aufträge über einen Zeitraum von 3 Jahren erstellt (verteilt auf die 1000 Personen). Die Aufträge haben unterschiedliche Stati, die meisten haben den Status (G=> Geliefert)
Schlussendlich werden pro Auftrag bis zu 5 Auftragspositionen angelegt.


