CREATE OR REPLACE FUNCTION determina_resultat(
idprovatecnica bigint,
idpacient bigint,
resultat varchar)

RETURNS text
AS
$$
DECLARE
  sql1 varchar := '';
  existe varchar;
  ret varchar;
  rec record;
  min_pat float;
  max_pat float;
  min_pan float;
  max_pan float;
  res_numeric float;
  trobat boolean := False;
BEGIN
  sql1 := 'SELECT idpacient FROM pacients WHERE idpacient = ' || idpacient || ';';
  execute (sql1) into existe;

  IF existe is NULL THEN
    return '-5';
  END IF;

  trobat := false;
  sql1 := 'SELECT * FROM  provestecnica WHERE idprovatecnica = ' || idprovatecnica || ';';
  FOR rec IN EXECUTE(sql1) LOOP
    trobat := true;
    IF rec.resultat_numeric then
      IF es_Numeric(resultat) THEN
        min_pat     := rec.minpat;
        max_pat     := rec.maxpat;
        min_pan     := rec.minpan;
        max_pan     := rec.maxpan;
        res_numeric := cast(resultat as float);
        
        IF res_numeric > min_pat AND res_numeric < max_pat THEN
            ret := '1';
        ELSE
          IF (res_numeric >= max_pat AND res_numeric < max_pan) 
          OR (res_numeric <= min_pat AND res_numeric > min_pan) THEN
            ret := '2';
          ELSE
            IF res_numeric >= max_pan OR res_numeric <= min_pan THEN
              ret := '3';
            END IF;
          END IF;
        END IF;
      ELSE
        ret:='3';
      END IF;
    ELSE
      IF resultat != rec.alfpat   THEN
        ret := '2';
      ELSE
        ret := '1';
      END IF;
    END IF;  
  END LOOP;

  if not trobat then
    return '-6';
  end if;		

RETURN ret;
EXCEPTION 
  WHEN unique_violation THEN return '-1'; 
  WHEN foreign_key_violation THEN return '-2'; 
  WHEN not_null_violation THEN return '-3';
  WHEN others THEN return '-4'; 
END;
$$
language 'plpgsql' volatile;
-- =====================================================================
CREATE OR REPLACE FUNCTION historialpacpro(
idpacient bigint, 
idprova bigint,
data_inici timestamp)
-- =====================================================================
CREATE OR REPLACE FUNCTION informehistorial(
id_pacient bigint,
id_analitica bigint default NULL)

RETURNS text
AS
$$
DECLARE
  sql1 text;
  sql2 text;
  sql3 text;
  rec record;
  rec2 record;
  trobat boolean := False;
  nom varchar;
  cognom varchar;
  analitica bigint;
  id_resultat bigint;
  ret varchar :='';
  data_res date;
  data_analitica timestamp;
  resultat varchar :='';
  valoracio varchar;
  prova int;
  n_prova varchar;
BEGIN
  sql1 := 'SELECT * FROM pacients WHERE idpacient = ' || id_pacient || ';';

  FOR rec IN EXECUTE(sql1) LOOP
    trobat := True;
    nom    := rec.nom;
    cognom := rec.cognoms;
    
  END LOOP;

  IF NOT trobat THEN
    return '-5';
  END IF;

  trobat := False;

  IF id_analitica is not NULL THEN
    sql1 := 'SELECT idanalitica FROM analitiques WHERE idanalitica = ' || id_analitica || ' and idpacient = ' || id_pacient || ';';
    
    FOR rec IN EXECUTE(sql1) LOOP
      trobat := True;
      analitica := rec.idanalitica;
      data_analitica := rec.dataanalitica;
    END LOOP;
    
    IF NOT trobat THEN
      return '-6';
    END IF;
  ELSE
    sql1 := 'SELECT idanalitica FROM analitiques WHERE idpacient = ' || id_pacient || ' order by dataanalitica desc limit 1;';
    FOR rec IN EXECUTE(sql1) LOOP
      trobat := True;
      analitica := rec.idanalitica;	
    END LOOP;
    
    IF NOT trobat THEN
      return '-7';
    END IF;
  END IF;

  /* #####################################################################
   # HASTA AQUI, TANTO COMO EL PACIENTE COMO LA ANALITICA EXISTEN
   #####################################################################	
  */
  trobat := False;
  sql1 := 'SELECT * FROM  resultats WHERE idanalitica = ' || analitica || ';';

  FOR rec IN EXECUTE(sql1) LOOP
    
    trobat    := True;
    resultat  := rec.resultats;
    data_res  := rec.dataresultat;
    valoracio := valorar_idresultat(rec.idresultat);
    
    
    
    sql2 := 'SELECT * FROM  provestecnica WHERE idprovatecnica = ' || rec.idprovatecnica || ';';
    
    FOR rec2 IN EXECUTE(sql2) LOOP
      prova := rec2.idprova;
    END LOOP;
    
    --sql3 := 'SELECT * FROM  catalegproves WHERE idprova = ' || prova|| ';';
    
    --FOR rec2 IN EXECUTE(sql3) LOOP
    --	n_prova :=rec2.nom_prova ;
    --END LOOP;
    
    --ret := ret || '' || nom || '#' || cognom || '#' || data_res || '#' || prova || '#' || n_prova || '#' || resultat || '#' || valoracio || e' \n';
    

  END LOOP;

  IF NOT trobat THEN
    return '-8';
  END IF;

RETURN ret;
EXCEPTION 
  WHEN unique_violation THEN return '-1'; 
  WHEN foreign_key_violation THEN return '-2'; 
  WHEN not_null_violation THEN return '-3';
  --WHEN others THEN return '-4'; 
END;
$$
language 'plpgsql' volatile;
