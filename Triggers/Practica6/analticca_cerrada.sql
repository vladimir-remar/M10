--var analitica_a_processar :='';
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

CREATE TRIGGER analitica_ok AFTER DELETE ON resultats_patologics
	FOR EACH ROW EXECUTE PROCEDURE analitica_acabada();
	
CREATE TRIGGER analitica_ok AFTER UPDATE OR INSERT ON resultats FOR EACH ROW EXECUTE PROCEDURE analitica_acabada();
