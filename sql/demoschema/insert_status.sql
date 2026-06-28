SET DEFINE OFF;
Insert into STATUS
   (STATUSID, KURZBESCHREIBUNG, BESCHREIBUNG)
 Values
   ('E', 'EINGANG', 'Ein neuer Auftrag ist eingegangen');
Insert into STATUS
   (STATUSID, KURZBESCHREIBUNG, BESCHREIBUNG)
 Values
   ('B', 'BESTAETIGT', 'Der Auftrag wurde dem Kunden bestätigt');
Insert into STATUS
   (STATUSID, KURZBESCHREIBUNG, BESCHREIBUNG)
 Values
   ('S', 'STORNO', 'Der Auftrag wurde storniert');
Insert into STATUS
   (STATUSID, KURZBESCHREIBUNG, BESCHREIBUNG)
 Values
   ('G', 'GELIEFERT', 'Auftrag wurde ausgeliefert');
Insert into STATUS
   (STATUSID, KURZBESCHREIBUNG, BESCHREIBUNG)
 Values
   ('Z', 'ZURUECK', 'Lieferung wurde zurückgeschickt');
COMMIT;
