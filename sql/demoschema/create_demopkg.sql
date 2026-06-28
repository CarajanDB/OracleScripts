CREATE OR REPLACE PACKAGE DEMOPKG  
 IS
    PROCEDURE PROC_PERSONEN (
       i_anzpers   IN   NUMBER,
       i_seed      IN   BOOLEAN DEFAULT FALSE,
       i_bild      IN   BOOLEAN DEFAULT FALSE,
       i_anzadr    IN   NUMBER DEFAULT 2,
       i_anztel    IN   NUMBER DEFAULT 2,
       i_commit    IN   NUMBER DEFAULT 1000
    );
 
    PROCEDURE PROC_AUFTRAEGE (
       i_anzahl   IN   NUMBER,
       i_seed     IN   BOOLEAN DEFAULT FALSE,
       i_anzpos   IN   NUMBER DEFAULT NULL,
       i_persid   IN   NUMBER DEFAULT NULL,
	   i_datumvon IN   NUMBER DEFAULT 1,
       i_datumbis IN   NUMBER DEFAULT 1460
    );
 
    PROCEDURE proc_positionen (
       i_anzahl   IN   NUMBER,
       i_seed      IN   BOOLEAN DEFAULT FALSE,
       i_aufid    IN   NUMBER DEFAULT NULL
    );
 END;  
/

CREATE OR REPLACE PACKAGE BODY DEMOPKG
 IS
    TYPE prod_tab_type IS TABLE OF produkte%ROWTYPE
       INDEX BY BINARY_INTEGER;

    l_prod_tab       prod_tab_type;
    l_anz_produkte   NUMBER        := 0;

    -------------------------------------------------------------------------------
 --
 --  1. Prozedur, um die Kundentabelle zu f�llen
 --
 -------------------------------------------------------------------------------
    PROCEDURE proc_personen (
       i_anzpers   IN   NUMBER,
       i_seed      IN   BOOLEAN DEFAULT FALSE,
       i_bild      IN   BOOLEAN DEFAULT FALSE,
       i_anzadr    IN   NUMBER DEFAULT 2,
       i_anztel    IN   NUMBER DEFAULT 2,
       i_commit    IN   NUMBER DEFAULT 1000
    )
    IS
       anz_ort           NUMBER;
       ortenummer        NUMBER;
       anz_strasse       NUMBER;
       strassennummer    NUMBER;
       anz_vorname       NUMBER;
       vornamennummer    NUMBER;
       anz_nachname      NUMBER;
       nachnamennummer   NUMBER;
       anz_bilder        NUMBER;
       bildernummer      NUMBER;
       anz_email         NUMBER;
       emailnummer       NUMBER;
       telefonnummer     NUMBER;
       l_persid          NUMBER             := 0;
       l_emailid         NUMBER             := 0;
       l_adrnr           NUMBER             := 0;
       l_anzauftrag      NUMBER             := 0;
       l_anzemail        NUMBER             := 0;
       l_geburtstag      DATE;
       i                 NUMBER             := 0;
       j                 NUMBER             := 0;
       K                 NUMBER             := 0;
       l_count           NUMBER             := 0;
       l_adrtyp          NUMBER             := 1;
       l_teltyp          NUMBER             := 1;
       l_emailadresse    VARCHAR2(200);

       TYPE orte_tab_type IS TABLE OF orte%ROWTYPE
          INDEX BY BINARY_INTEGER;

       TYPE strassen_tab_type IS TABLE OF strassen%ROWTYPE
          INDEX BY BINARY_INTEGER;

       TYPE vornamen_tab_type IS TABLE OF vornamen%ROWTYPE
          INDEX BY BINARY_INTEGER;

       TYPE nachnamen_tab_type IS TABLE OF nachnamen%ROWTYPE
          INDEX BY BINARY_INTEGER;

       TYPE bilder_tab_type IS TABLE OF personenbilder%ROWTYPE
          INDEX BY BINARY_INTEGER;

       TYPE email_tab_type IS TABLE OF emailprovider%ROWTYPE
          INDEX BY BINARY_INTEGER;

       orte_tab          orte_tab_type;
       strassen_tab      strassen_tab_type;
       vornamen_tab      vornamen_tab_type;
       nachnamen_tab     nachnamen_tab_type;
       bilder_tab        bilder_tab_type;
       email_tab         email_tab_type;
    BEGIN

    	FOR c_rec IN (SELECT *
                       FROM orte)
       LOOP
          orte_tab (orte_tab.COUNT + 1) := c_rec;
       END LOOP;

       FOR c_rec IN (SELECT *
                       FROM strassen)
       LOOP
          strassen_tab (strassen_tab.COUNT + 1) := c_rec;
       END LOOP;

       FOR c_rec IN (SELECT *
                       FROM nachnamen)
       LOOP
          nachnamen_tab (nachnamen_tab.COUNT + 1) := c_rec;
       END LOOP;

       FOR c_rec IN (SELECT *
                       FROM vornamen)
       LOOP
          vornamen_tab (vornamen_tab.COUNT + 1) := c_rec;
       END LOOP;

      FOR c_rec IN (SELECT *
                       FROM personenbilder)
       LOOP
          bilder_tab (bilder_tab.COUNT + 1) := c_rec;
       END LOOP;
       
      FOR c_rec IN (SELECT *
                       FROM emailprovider)
       LOOP
          email_tab (email_tab.COUNT + 1) := c_rec;
       END LOOP;

       SELECT COUNT (*)
         INTO anz_ort
         FROM orte;

       SELECT COUNT (*)
         INTO anz_strasse
         FROM strassen;

       SELECT COUNT (*)
         INTO anz_vorname
         FROM vornamen;

       SELECT COUNT (*)
         INTO anz_nachname
         FROM nachnamen;

       SELECT COUNT (*)
         INTO anz_bilder
         FROM personenbilder;

       SELECT COUNT (*)
         INTO anz_email
         FROM emailprovider;

       FOR i IN 1 .. i_anzpers
       LOOP
          IF (i_seed)
          THEN
             DBMS_RANDOM.SEED (i);
          END IF;

          vornamennummer :=
                      ROUND (DBMS_RANDOM.VALUE (low => 1, HIGH => anz_vorname));

          IF (i_seed)
          THEN
             DBMS_RANDOM.SEED (i);
          END IF;

          nachnamennummer :=
                     ROUND (DBMS_RANDOM.VALUE (low => 1, HIGH => anz_nachname));

          IF (i_seed)
          THEN
             DBMS_RANDOM.SEED (i);
          END IF;

          bildernummer :=
                     ROUND (DBMS_RANDOM.VALUE (low => 1, HIGH => anz_bilder));


 --
 -- Geburtstag: zwischen 20 und 80 Jahre alt
 --
          IF (i_seed)
          THEN
             DBMS_RANDOM.SEED (i);
          END IF;

          l_geburtstag :=
             TRUNC (  SYSDATE
                    - (ROUND (DBMS_RANDOM.VALUE (low => 7300, HIGH => 29200))
                      )
                   );

 --
 -- Sequence muss in Variable gef�llt werden, weil mehrfach benutzt
 --
          SELECT seq_personen.NEXTVAL
            INTO l_persid
            FROM DUAL;

 --
 -- F�llen der Tabelle Personen
 --
          IF (i_bild)
          THEN
             INSERT INTO personen
                      (persid,
                       anrede,
                       vorname,
                       nachname,
                       geburtstag,
                       bild
                      )
               VALUES (l_persid,
                       vornamen_tab (vornamennummer).anrede,
                       vornamen_tab (vornamennummer).vorname,
                       nachnamen_tab (nachnamennummer).nachname,
                       l_geburtstag,
                       bilder_tab(bildernummer).bild
                      );
           ELSE
              INSERT INTO personen
                      (persid,
                       anrede,
                       vorname,
                       nachname,
                       geburtstag,
                       bild
                      )
               VALUES (l_persid,
                       vornamen_tab (vornamennummer).anrede,
                       vornamen_tab (vornamennummer).vorname,
                       nachnamen_tab (nachnamennummer).nachname,
                       l_geburtstag,
                       NULL
                      );
            END IF;

 --
 -- Je Person i_anzadr Adressen (Default 2)
 --
          FOR j IN 1 .. i_anzadr
          LOOP
             IF (i_seed)
             THEN
                DBMS_RANDOM.SEED (j);
             END IF;

             ortenummer :=
                          ROUND (DBMS_RANDOM.VALUE (low => 1, HIGH => anz_ort));

             IF (i_seed)
             THEN
                DBMS_RANDOM.SEED (j);
             END IF;

             strassennummer :=
                      ROUND (DBMS_RANDOM.VALUE (low => 1, HIGH => anz_strasse));
             l_adrtyp := MOD (j, 2) + 11;

             SELECT seq_adressen.NEXTVAL
               INTO l_adrnr
               FROM DUAL;

             INSERT INTO adressen
                         (persid, adrid,
                          strasse,
                          ort,
                          plz,
						  bundesland,
						  adrtyp
                         )
                  VALUES (l_persid, l_adrnr,
                          strassen_tab (strassennummer).strasse,
                          orte_tab (ortenummer).ort,
                          orte_tab (ortenummer).plz,
                          orte_tab (ortenummer).blid,
						  l_adrtyp
                         );
--
-- Je Adresse auch eine E-Mail Adresse
--
             SELECT seq_emails.NEXTVAL
               INTO l_emailid
               FROM dual;
               
             emailnummer :=
                      ROUND (DBMS_RANDOM.VALUE (low => 1, HIGH => anz_email));
             IF ( mod(l_emailid,2) = 0 )
             THEN
                 l_emailadresse := lower(vornamen_tab(vornamennummer).vorname||'.'||nachnamen_tab(nachnamennummer).nachname||'@'||email_tab (emailnummer).provider);                       
             ELSE
                 l_emailadresse := lower(substr(vornamen_tab(vornamennummer).vorname,0,1)||nachnamen_tab(nachnamennummer).nachname||'@'||email_tab (emailnummer).provider);
             END IF;
             l_emailadresse := REPLACE(l_emailadresse,'�','ae');
             l_emailadresse := REPLACE(l_emailadresse,'�','oe');
             l_emailadresse := REPLACE(l_emailadresse,'�','ue');
             l_emailadresse := REPLACE(l_emailadresse,'�','ss');

             INSERT INTO emailadressen
                         (persid, 
                          emailid,
                          emailadresse
                         )
                  VALUES (l_persid, 
                          l_emailid,
                          l_emailadresse                       
                         );
 --
 -- Je Adresse i_anztel Telefonnummern (Default 2)
 --
             FOR K IN 1 .. i_anztel
             LOOP
                l_teltyp := (l_adrtyp * 2) - 1 + MOD (K, 2);

                IF (i_seed)
                THEN
                   DBMS_RANDOM.SEED (K);
                END IF;

                telefonnummer :=
                    ROUND (DBMS_RANDOM.VALUE (low => 123456, HIGH => 99999999));

                INSERT INTO telefone
                            (persid, land, vorwahl,
                             nummer, teltyp
                            )
                     VALUES (l_persid, 49,
					        orte_tab (ortenummer).vorwahl,
                             telefonnummer,
							 l_teltyp
                            );
             END LOOP;
          END LOOP;

 --         IF (i_sleep IS NOT NULL)
 --         THEN
 --            DBMS_LOCK.sleep (i_sleep);
 --         END IF;
          l_count := l_count + 1;

          IF (l_count > i_commit)
          THEN
--             COMMIT;
             l_count := 1;
 --            dbms_output.put_line('COMMIT');
          END IF;
       END LOOP;

--       COMMIT;
    END;

 -------------------------------------------------------------------------------
 --
 --  2. Prozedur, um die Auftraege-Tabelle zu f�llen
 --
 -------------------------------------------------------------------------------
    PROCEDURE proc_auftraege (
       i_anzahl   IN   NUMBER,
       i_seed      IN   BOOLEAN DEFAULT FALSE,
       i_anzpos   IN   NUMBER DEFAULT NULL,
       i_persid   IN   NUMBER DEFAULT NULL,
	   i_datumvon IN   NUMBER DEFAULT 1,
       i_datumbis IN   NUMBER DEFAULT 1460 -- 4 Jahre
    )
    IS
       l_min_pers      NUMBER;
       l_max_pers      NUMBER;
       l_aufdatum      DATE;
       l_persid        NUMBER;
       i               NUMBER          := 0;
       l_count         NUMBER          := 0;
       l_anz_status    NUMBER          := 0;
       l_ist_status    NUMBER          := 0;
       l_lieferdatum   DATE;
       l_aufid         NUMBER          := 0;

       TYPE status_tab_type IS TABLE OF status%ROWTYPE
          INDEX BY BINARY_INTEGER;

       l_status_tab    status_tab_type;
    BEGIN
 --
 --  Lesen der gueltigen Stati in eine PL/SQL Tabelle
 --
       FOR c_rec IN (SELECT statusid, kurzbeschreibung, beschreibung
                       FROM status
                     UNION ALL
                     SELECT 'G', kurzbeschreibung, beschreibung
                       FROM status)
       LOOP
          l_status_tab (l_status_tab.COUNT + 1) := c_rec;
          l_anz_status := l_anz_status + 1;
       END LOOP;

 --
 --  Lesen der minimalen und maximalen personennummer, es wird vorausgesetzt
 --  dass alle zwischenliegenden Nummern vergeben sind
 --  Personalnummern < 100 werden nicht benutzt (Intern)
 --
       IF (i_persid IS NULL)
       THEN
          SELECT MIN (persid), MAX (persid)
            INTO l_min_pers, l_max_pers
            FROM personen
           WHERE persid > 100;
 --         l_anz_pers := l_max_pers - l_min_pers;
       END IF;

 --
 -- Wenn die Positionentabelle direkt mit gef�llt wird, macht es mehr Sinn
 -- den Produkterecord hier zu f�llen
 --
       IF (i_anzpos IS NOT NULL)
       THEN
          FOR c_rec IN (SELECT *
                          FROM produkte)
          LOOP
             l_prod_tab (l_prod_tab.COUNT + 1) := c_rec;
             l_anz_produkte := l_anz_produkte + 1;
          END LOOP;
       END IF;

       FOR i IN 1 .. i_anzahl
       LOOP
          BEGIN
 ---
 ---     Zufallszahl fuer die personennummer des Auftrags
 ---
             IF (i_persid IS NULL)
             THEN
                IF (i_seed)
                THEN
                   DBMS_RANDOM.SEED (i);
                END IF;

                l_persid :=
                   ROUND (DBMS_RANDOM.VALUE (low => l_min_pers,
                                              HIGH => l_max_pers
                                            )
                         );

 ---
 ---     Zufallszahl fuer den Auftragsstatus
 ---
                IF (i_seed)
                THEN
                   DBMS_RANDOM.SEED (i);
                END IF;

                l_ist_status :=
                     ROUND (DBMS_RANDOM.VALUE (low => 1, HIGH => l_anz_status));

 ---
 ---     Zufallszahl fuer das Auftragsdatum (letzten 4 Jahre)
 ---
                IF (i_seed)
                THEN
                   DBMS_RANDOM.SEED (i);
                END IF;

                l_aufdatum :=
                   TRUNC (  SYSDATE
                          - (ROUND (DBMS_RANDOM.VALUE (low => i_datumvon, HIGH => i_datumbis))
                            )
                         );

 ---
 ---     Sonntags gibt es keine Auftraege
 ---
                IF (TO_CHAR (l_aufdatum, 'D') = 7)
                THEN
                   l_aufdatum := l_aufdatum - 1;
                END IF;

 ---
 ---     Ermitteln des Lieferdatums ueber Zufallszahl mit 30 Tagen Differenz auf das Auftragsdatum
 ---     Nur f�r Auftraege, die Geliefert oder Zur�ckgeschickt wurden
 ---
                IF (    l_status_tab (l_ist_status).statusid = 'G'
                    OR l_status_tab (l_ist_status).statusid = 'Z'
                   )
                THEN
                   IF (i_seed)
                   THEN
                      DBMS_RANDOM.SEED (i);
                   END IF;

                   l_lieferdatum :=
                        l_aufdatum
                      + (ROUND (DBMS_RANDOM.VALUE (low => 1, HIGH => 31)));
                ELSE
                   l_lieferdatum := NULL;
                END IF;

 ---
 ---     Samstags und Sonntags gibt es keine Lieferungen
 ---
                IF (TO_CHAR (l_lieferdatum, 'D') >= 6)
                THEN
                   l_lieferdatum := l_lieferdatum + 2;
                END IF;

 ---
 ---     Das Lieferdatum darf nicht ueber dem heutigen Datum liegen
 ---
                IF (TRUNC (l_lieferdatum) >= TRUNC (SYSDATE))
                THEN
                   l_ist_status := 1;
                   l_lieferdatum := NULL;
                END IF;
 ---
 ---     Eintragen der Auftraege
 ---
             ELSE
                l_persid := i_persid;
                l_ist_status := 1;
                l_aufdatum := SYSDATE;
             END IF;

             SELECT seq_auftraege.NEXTVAL
               INTO l_aufid
               FROM DUAL;

             INSERT INTO auftraege
                         (aufid, persid, aufdatum, lieferdatum,
                          aufstatus
                         )
                  VALUES (l_aufid, l_persid, l_aufdatum, l_lieferdatum,
                          l_status_tab (l_ist_status).statusid
                         );

             IF (i_anzpos IS NOT NULL)
             THEN
                proc_positionen (i_anzpos, i_seed, l_aufid);
             END IF;
          EXCEPTION
             WHEN OTHERS
             THEN
                DBMS_OUTPUT.put_line ('Fehler in Prozedur proc_auftraege!');
                DBMS_OUTPUT.put_line (SQLERRM);
          END;

 ---
 ---     Commit je 1000 Datensaetze
 ---
          IF (i_persid IS NULL)
          THEN
             l_count := l_count + 1;

--             IF (l_count > 1000)
--             THEN
--                COMMIT;
--                l_count := 1;
--             END IF;
          END IF;
       END LOOP;

--       IF (i_persid IS NULL)
--       THEN
--          COMMIT;
--       END IF;
    END;

 -------------------------------------------------------------------------------
 --
 --  3. Prozedur, um die Positionen-Tabelle zu f�llen
 --
 -------------------------------------------------------------------------------
    PROCEDURE proc_positionen (
       i_anzahl   IN   NUMBER,
       i_seed     IN   BOOLEAN DEFAULT FALSE,
       i_aufid    IN   NUMBER DEFAULT NULL
    )
    IS
       li_anzahl       NUMBER     := 0;
       l_nachlass      NUMBER     := 0;
       l_einzelpreis   NUMBER     := 0;
       l_menge         NUMBER     := 0;
       l_posid         NUMBER     := 0;
       l_prodid        NUMBER     := 0;
       l_anzpos        NUMBER     := 0;
       i               NUMBER     := 0;
       j               NUMBER     := 0;
       l_count         NUMBER     := 0;
       l_aufid         NUMBER     := 0;

 --      TYPE prod_tab_type IS TABLE OF produkte%ROWTYPE
 --         INDEX BY BINARY_INTEGER;

       --      l_prod_tab       prod_tab_type;
       TYPE c_auf_type IS REF CURSOR;

       c_auf           c_auf_type;
    BEGIN
 --
 -- Produkterecord nur erforderlich, wenn die POSITIONEN-Tabelle
 -- direkt gef�llt wird, ansonsten schon in proc_auftraege gemacht
 --
       IF (i_aufid IS NULL)
       THEN
          FOR c_rec IN (SELECT *
                          FROM produkte)
          LOOP
             l_prod_tab (l_prod_tab.COUNT + 1) := c_rec;
             l_anz_produkte := l_anz_produkte + 1;
          END LOOP;
       END IF;

       IF (i_aufid IS NULL)
       THEN
          OPEN c_auf FOR 'SELECT aufid FROM auftraege';
       ELSE
          OPEN c_auf FOR 'SELECT aufid FROM auftraege WHERE aufid = :aufid '
          USING i_aufid;
       END IF;

 --
 -- Maximale Anzahl Positionen = 5
 --
       IF (i_anzahl > 5)
       THEN
          li_anzahl := 5;
       ELSE
          li_anzahl := i_anzahl;
       END IF;

       LOOP
          FETCH c_auf
           INTO l_aufid;

          EXIT WHEN c_auf%NOTFOUND;
          l_posid := 1;

          IF (i_seed)
          THEN
             l_anzpos := 5;
          ELSE
             l_anzpos := ROUND (DBMS_RANDOM.VALUE (low => 1, HIGH => li_anzahl));
          END IF;

          FOR j IN 1 .. l_anzpos
          LOOP
             BEGIN
                IF (i_seed)
                THEN
                   DBMS_RANDOM.SEED (j);
                END IF;

                l_prodid :=
                   ROUND (DBMS_RANDOM.VALUE (low => 1, HIGH => l_anz_produkte));

                IF (i_seed)
                THEN
                   DBMS_RANDOM.SEED (j);
                END IF;

                l_menge := ROUND (DBMS_RANDOM.VALUE (low => 1, HIGH => 5));

                IF (i_seed)
                THEN
                   DBMS_RANDOM.SEED (j);
                END IF;

                l_nachlass :=
                            ROUND (DBMS_RANDOM.VALUE (low => 1, HIGH => 10), 1);
                l_einzelpreis :=
                   TRUNC (  l_prod_tab (l_prodid).preisvk
                          - (l_prod_tab (l_prodid).preisvk * l_nachlass / 100
                            ),
                          2
                         );

                INSERT INTO positionen
                            (aufid, posid, prodid,
                             menge, einzelpreis
                            )
                     VALUES (l_aufid, l_posid, l_prod_tab (l_prodid).prodid,
                             l_menge, l_einzelpreis
                            );

                l_posid := l_posid + 1;
             EXCEPTION
                WHEN OTHERS
                THEN
                   DBMS_OUTPUT.put_line ('Fehler in Prozedur proc_positionen!');
                   DBMS_OUTPUT.put_line (SQLERRM);
             END;
          END LOOP;

--          COMMIT;

          IF (i_aufid IS NULL)
          THEN
             l_count := l_count + 1;

--             IF (l_count > 1000)
--             THEN
--                COMMIT;
--                l_count := 1;
--             END IF;
          END IF;
       END LOOP;

--       IF (i_aufid IS NULL)
--       THEN
--          COMMIT;
--       END IF;
    END;
 END;
/