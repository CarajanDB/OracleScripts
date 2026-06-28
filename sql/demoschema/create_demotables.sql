-- Create Tables section

Create table ADRESSEN (
	ADRID Number(10,0) NOT NULL ,
	PERSID Number(10,0) NOT NULL ,
	STRASSE Varchar2 (50 CHAR),
	ORT Varchar2 (50 CHAR),
	BUNDESLAND NUMBER(5),
	PLZ Varchar2 (8 CHAR),
	ADRTYP Number(2,0),
 Constraint PK_ADRESSEN primary key (ADRID) 
) 
/

Create table AUFTRAEGE (
	AUFID Number(10,0) NOT NULL ,
	PERSID Number(10,0) NOT NULL ,
	AUFDATUM Date,
	LIEFERDATUM Date,
	AUFSTATUS Char (1 CHAR) NOT NULL ,
 Constraint PK_AUFTRAEGE primary key (AUFID) 
) 
/

CREATE TABLE BUNDESLAENDER
(
    BLID        NUMBER,
    BUNDESLAND  VARCHAR2(30 CHAR),
 Constraint PK_BUNDESLAENDER primary key (BLID) 
)
/

Create table PERSONEN (
	PERSID Number(10,0) NOT NULL ,
	ANREDE Varchar2 (5 CHAR),
	VORNAME Varchar2 (20 CHAR),
	NACHNAME Varchar2 (20 CHAR),
	GEBURTSTAG Date,
	BILD Blob,
 Constraint PK_PERSONEN primary key (PERSID) 
) 
/

Create table POSITIONEN (
	AUFID Number(10,0) NOT NULL ,
	POSID Number(10,0) NOT NULL ,
	PRODID Number(10,0) NOT NULL ,
	MENGE Number(10,2),
	EINZELPREIS Number(7,2),
 Constraint PK_POSITIONEN primary key (AUFID,POSID) 
) 
/

Create table PRODUKTE (
	PRODID Number(10,0) NOT NULL ,
	PGRID Number(10,0),
	PRODUKTNAME Varchar2 (255 CHAR),
	PREISEK Number(10,2),
	PREISVK Number(10,2),
	PRODUKTBILD Long,
 Constraint PK_PRODUKTE primary key (PRODID) 
) 
/

Create table PRODUKTGRUPPEN (
	PGRID Number(10,0) NOT NULL ,
	WARENWELT Varchar2 (50 CHAR),
	ABTEILUNG Number(10,0),
	GRUPPE Varchar2 (50 CHAR),
 Constraint PK_PRODUKTGRUPPEN primary key (PGRID) 
) 
/

Create table STATUS (
	STATUSID Char (1) NOT NULL ,
	KURZBESCHREIBUNG Varchar2 (10 CHAR),
	BESCHREIBUNG Varchar2 (255 CHAR),
 Constraint PK_STATUS primary key (STATUSID) 
) 
/

Create table TELEFONE (
	PERSID Number(10,0)NOT NULL ,
	LAND Number(5,0) Default 49,
	VORWAHL Number(10,0),
	NUMMER Number(10,0),
	BEMERKUNG Varchar2 (100 CHAR),
	TELTYP Number(2,0) NOT NULL 
) 
/

Create table TYPEN (
	TYPID Number(2,0) NOT NULL ,
	KURZFORM Varchar2 (10),
	BESCHREIBUNG Varchar2 (255 CHAR),
 Constraint PK_TYPEN primary key (TYPID) 
) 
/

CREATE TABLE emailadressen (
   persid NUMBER,
   emailid NUMBER,
   emailadresse VARCHAR2(200),
   bemerkung VARCHAR2(200),
Constraint PK_email primary key (emailid)
)
/

-- Create Foreign keys section

Alter table POSITIONEN add Constraint FK_POSITIONEN_AUFTRAEGE foreign key (AUFID) references AUFTRAEGE (AUFID) 
/

Alter table ADRESSEN add Constraint FK_ADRESSEN_PERSONEN foreign key (PERSID) references PERSONEN (PERSID) 
/

Alter table emailadressen add Constraint FK_EMAILADRESSEN_PERSONEN foreign key (PERSID) references  PERSONEN (PERSID)
/

Alter table ADRESSEN add Constraint FK_ADRESSEN_BUNDESLAND foreign key (BUNDESLAND) references BUNDESLAENDER (BLID) 
/

Alter table AUFTRAEGE add Constraint FK_AUFTRAEGE_PERSONEN foreign key (PERSID) references PERSONEN (PERSID) 
/

Alter table TELEFONE add Constraint FK_TELEFONE_PERSONEN foreign key (PERSID) references PERSONEN (PERSID) 
/

Alter table POSITIONEN add Constraint FK_POSITIONEN_PRODUKTE foreign key (PRODID) references PRODUKTE (PRODID) 
/

Alter table PRODUKTE add Constraint FK_PRODUKTE_PRODUKTGRUPPEN foreign key (PGRID) references PRODUKTGRUPPEN (PGRID) 
/

Alter table AUFTRAEGE add Constraint FK_AUFTRAEGE_STATUS foreign key (AUFSTATUS) references STATUS (STATUSID) 
/

Alter table ADRESSEN add Constraint FK_ADRESSEN_TYPEN foreign key (ADRTYP) references TYPEN (TYPID) 
/

Alter table TELEFONE add Constraint FK_TYPEN foreign key (TELTYP) references TYPEN (TYPID) 
/

-- Create Sequences section

CREATE SEQUENCE SEQ_PERSONEN INCREMENT BY 1 START WITH 100001 MAXVALUE 9.999999999999999e+26 MINVALUE 0 NOCYCLE CACHE 20 NOORDER
/

CREATE SEQUENCE SEQ_ADRESSEN INCREMENT BY 1 START WITH 100001 MAXVALUE 9.999999999999999e+26 MINVALUE 0 NOCYCLE CACHE 20 NOORDER
/

CREATE SEQUENCE SEQ_AUFTRAEGE INCREMENT BY 1 START WITH 100001 MAXVALUE 9.999999999999999e+26 MINVALUE 0 NOCYCLE CACHE 20 NOORDER
/

CREATE SEQUENCE SEQ_EMAILS INCREMENT BY 1 START WITH 100001 MAXVALUE 9.999999999999999e+26 MINVALUE 0 NOCYCLE CACHE 20 NOORDER
/

SET ECHO OFF
PROMPT Datensaetze werden eingefuegt ...
SET TERMOUT OFF
@@insert_bundeslaender
COMMIT;
@@insert_produktgruppen
COMMIT;
@@insert_produkte
COMMIT;
@@insert_status
COMMIT;
@@insert_typen
COMMIT;
@@create_demopkg