CREATE TABLE emailadressen (
   persid NUMBER,
   emailid NUMBER,
   emailadresse VARCHAR2(200),
   bemerkung VARCHAR2(200));

ALTER TABLE emailadressen ADD CONSTRAINT pk_email PRIMARY KEY (emailid);   

create sequence seq_emails start with 10000;