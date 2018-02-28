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
  IF NEW.resultat is NULL THEN
    RETURN NEW;
  ELSE
    res := valorar_idresultat(NEW.idresultat)
    IF res = '2' or res = '3' THEN
      INSERT INTO resultats_patologics VALUES(NEW.id_resultat, current_timestamp, current_user);
    END IF;
  END IF;
RETURN NEW;
END;
$resultats_resultat$ 
LANGUAGE plpgsql;

CREATE TRIGGER resultats_resultat AFTER INSERT OR UPDATE ON resultats
    FOR EACH ROW EXECUTE PROCEDURE estat_resultat();
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

CREATE TABLE informes( 
idanalitica bigint NOT NULL,
stamp timestamp NOT NULL); 

alter table informes add constraint fk_idanalitica foreign key 
(idanalitica) references analitiques(idanalitica) on update cascade on 
delete restrict;
alter table resultats alter COLUMN resultats drop not null ;
*/

