/*
1. Tots els resultats que arribin a la taula de resultats s'han 
d'evaluar i en el cas que la valoració sigui PATOLÒGIC o PÀNIC s'ha de 
guardar l'idresultat en una taula que tindrà la següent estructura :

CREATE TABLE resultats_patologics( 
idresultat integer NOT NULL, 
stamp timestamp NOT NULL, 
userid text NOT NULL
); 
La funcionalitat d'aquesta nova taula serà doble :
1. Quan hi hagi registres voldrà dir que els metges tenen un resultat urgent per examinar
2. Mentre un resultat estigui en aquesta taula no es donarà una 
analítica per acabada o complerta perquè caldrà que els metges 
verifiquin i validin tots els resultats de pànic.

-- 1 ->  NORMAL 
-- 2 ->  PATOLÒGIC
-- 3 ->  PÀNIC
*/

CREATE OR REPLACE FUNCTION estat_resultat() RETURNS trigger 
AS $resultats_resultat$
DECLARE
  res varchar :='';
BEGIN
  IF NEW.resultats is NULL THEN
    RETURN NEW;
  ELSE
    res := valorar_idresultat(NEW.idresultat);
    IF res = '2' or res = '3' THEN
      INSERT INTO resultats_patologics VALUES(NEW.idresultat, current_timestamp, current_user);
    END IF;
  END IF;
RETURN NEW;
END;
$resultats_resultat$ 
LANGUAGE plpgsql;

CREATE TRIGGER resultats_resultat AFTER INSERT OR UPDATE ON resultats FOR EACH ROW EXECUTE PROCEDURE estat_resultat();
-- #####################################################################
/*
2. No permetre mai esborrar resultats de la taula resultatsa, ni 
analitiques de la taula analitiques.

*/
CREATE FUNCTION no_esborrar() RETURNS trigger 
AS $no_delete$
BEGIN
RETURN NULL;
END;
$no_delete$ 
LANGUAGE plpgsql;

CREATE TRIGGER no_delete BEFORE DELETE ON resultats
  FOR EACH ROW EXECUTE PROCEDURE no_esborrar();

CREATE TRIGGER no_delete BEFORE DELETE ON analitiques
  FOR EACH ROW EXECUTE PROCEDURE no_esborrar();
  
-- #####################################################################  
/*
3. Quan totes les proves d'una analítica tinguin resultat i no 
existeixi cap resultat d'aquesta analítica a la taula de 
resultats_patologics, es donarà l'analítica per acabada i es podrà fer 
l'informe definitiu. Per això guardarem l'id de l'analítica a la taula 
informes:
*/
/*
CREATE TABLE informes( 
idanalitica bigint NOT NULL,
stamp timestamp NOT NULL); 

alter table informes add constraint fk_idanalitica foreign key 
(idanalitica) references analitiques(idanalitica) on update cascade on 
delete restrict;
alter table resultats alter COLUMN resultats drop not null ;
*/
CREATE OR REPLACE FUNCTION analitica_acabada() RETURNS trigger 
AS $analitica_ok$
DECLARE
  sql1 text;
  rec record;
  analitica_a_procesar bigint;
  estat_analitica boolean :=True;
  trobat boolean :=False;
BEGIN
  IF TG_TABLE_NAME = 'resultats' THEN
    analitica_a_procesar := new.idanalitica;
  ELSE
    sql1 := 'select idanalitica from resultats where idresultat = '||old.idresultat||';';
    EXECUTE (sql1) INTO analitica_a_procesar;
  END IF;
  sql1:= 'select * from resultats where idanalitica = '||analitica_a_procesar||' and (resultats IS '||'NULL'||' or resultats = '''');';
  
  FOR rec IN EXECUTE(sql1) LOOP
    estat_analitica := False;
  END LOOP;
  
  IF estat_analitica THEN
    sql1 := 'select * from resultats_patologics join resultats on resultats_patologics.idresultat=resultats.idresultat 
    and resultats.idanalitica = '||analitica_a_procesar||';'; 
    FOR rec IN EXECUTE (sql1) LOOP
      trobat := True;
    END LOOP;
    
    IF NOT trobat THEN
      INSERT INTO informes VALUES(analitica_a_procesar, now());
    ELSE 
      RETURN NULL;
    END IF;
  ELSE
    RETURN NULL;
  END IF;
    
RETURN NEW;
END;
$analitica_ok$ 
LANGUAGE plpgsql;

CREATE TRIGGER analitica_ok AFTER DELETE ON resultats_patologics FOR EACH ROW EXECUTE PROCEDURE analitica_acabada();
	
CREATE TRIGGER b_analitica_ok AFTER UPDATE OR INSERT ON resultats FOR EACH ROW EXECUTE PROCEDURE analitica_acabada();

-- #####################################################################
/*
4. Cal guardar a la taula alarmes les dades necessàries per notificar a 
les autoritats sanitàries dels resultats patològics de les proves 
configurades per donar alarma. Desenvolupar o modificar els triggers i 
les funcions que calgui per guardar les alarmes.
*/
--ALTER TABLE catalegproves ADD COLUMN nivell_alarma int default 0;
--ALTER TABLE catalegproves ADD COLUMN missatge varchar(200);
--ALTER TABLE alarmes ADD COLUMN timestamp_alarma timestamp default current_timestamp;
--insert into catalegproves values(404,'Ebola','Virus del ebola','EBO',3);
--UPDATE catalegproves SET nivell_alarma=2 WHERE acronim = 'VIH';
--UPDATE catalegproves SET nivell_alarma=1 WHERE acronim = 'COAC';
--UPDATE catalegproves SET nivell_alarma=1 WHERE acronim = 'EBO';
--UPDATE catalegproves SET nivell_alarma=0 WHERE acronim != 'EBO' AND acronim != 'VIH' AND acronim != 'COAC'

CREATE OR REPLACE FUNCTION insert_alarmes() RETURNS trigger 
AS $entry_alarma$
DECLARE
  sql1 text;
  rec record;
  trobat boolean := False;
  nivell smallint;
  missatge varchar;
BEGIN
  --select * from resultats join provestecnica on resultats.idresultat=242  join catalegproves on provestecnica.idprova=catalegproves.idprova where resultats.idprovatecnica=provestecnica.idprovatecnica and catalegproves.nivell_alarma>0;
  sql1 := 'select * from resultats join provestecnica on resultats.idprovatecnica=provestecnica.idprovatecnica join catalegproves on provestecnica.idprova=catalegproves.idprova where  catalegproves.nivell_alarma>0 and resultats.idresultat='|| new.idresultat ||';';
  FOR rec IN EXECUTE(sql1) LOOP
    trobat := True;
    nivell := rec.nivell_alarma;
    missatge := rec.missatge;
  END LOOP;
  
  IF trobat THEN
    INSERT INTO alarmes VALUES(default,new.idresultat,nivell,default,missatge);
  ELSE
    RETURN NULL;
  END IF;
  
RETURN NEW;
END;
$entry_alarma$ 
LANGUAGE plpgsql;

CREATE TRIGGER b_entry_alarma AFTER INSERT OR UPDATE ON resultats_patologics
	FOR EACH ROW EXECUTE PROCEDURE insert_alarmes();
