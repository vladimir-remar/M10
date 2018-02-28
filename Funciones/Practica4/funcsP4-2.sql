-- #####################################################################
/*
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
language 'plpgsql' volatile;*/
-- =====================================================================
CREATE OR REPLACE FUNCTION historialpacpro(
idpacient bigint, 
idprova bigint,
data_inici timestamp default null)
RETURNS text
AS
$$
DECLARE
  nom varchar;
  cognom varchar;
  ret varchar :='';
  sql1 text;
  sql2 text;
  sql3 text;
  sql4 text;
  rec record;
  rec2 record;
  rec3 record;
  minim bigint;
  maxim bigint;
  data_res date;
  valoracio varchar :='';
  valors_ref varchar:='';
  provatecnica bigint;
  res_char varchar :='';
  selec_valors text;
  minpat varchar :='';
  maxpat varchar :='';
  minpan varchar :='';
  maxpan varchar :='';
BEGIN
  IF data_inici is null Then
    data_inici := current_timestamp;
  END IF;
  -- consulta base
  -- select resultats.idresultat, resultats.resultats  from provestecnica join resultats  on provestecnica.idprova = 101 and resultats.idprovatecnica=provestecnica.idprovatecnica join analitiques on resultats.idanalitica=analitiques.idanalitica and analitiques.idpacient=1 and resultats.dataresultat<=current_timestamp group by resultats.idresultat, resultats.resultats,resultats.idprovatecnica order by resultats.idprovatecnica,resultats.dataresultat desc;
  -- select * from provestecnica join resultats  on provestecnica.idprova = 101 and resultats.idprovatecnica=provestecnica.idprovatecnica join analitiques on resultats.idanalitica=analitiques.idanalitica and analitiques.idpacient=1 and resultats.dataresultat<=current_timestamp order by resultats.idprovatecnica,resultats.dataresultat desc;
  -- select MIN(cast(resultats.resultats as float)),Max(cast(resultats.resultats as float)) from provestecnica join resultats  on provestecnica.idprova = 101 and resultats.idprovatecnica=provestecnica.idprovatecnica join analitiques on resultats.idanalitica=analitiques.idanalitica and analitiques.idpacient=1 and resultats.dataresultat<=current_timestamp;
  -- select Max(cast(resultats.resultats as float)) from provestecnica join resultats  on provestecnica.idprova = 101 and resultats.idprovatecnica=provestecnica.idprovatecnica join analitiques on resultats.idanalitica=analitiques.idanalitica and analitiques.idpacient=1 and resultats.dataresultat<=current_timestamp;
  provatecnica := 0;
  -- Resultats per aquest pacient i aquesta prova, a partit de la data_inici
  sql2 := 'select resultats.idresultat, resultats.resultats, analitiques.dataanalitica, provestecnica.idprovatecnica, provestecnica.resultat_numeric,resultats.idanalitica from provestecnica join resultats  on provestecnica.idprova ='|| idprova ||' and resultats.idprovatecnica=provestecnica.idprovatecnica join analitiques on resultats.idanalitica=analitiques.idanalitica and analitiques.idpacient='||idpacient||' and analitiques.dataanalitica<= '''||data_inici||'''group by resultats.idresultat, resultats.resultats,analitiques.dataanalitica, provestecnica.idprovatecnica, provestecnica.resultat_numeric,resultats.idanalitica,resultats.idprovatecnica order by resultats.idprovatecnica,analitiques.dataanalitica desc;';
  FOR rec2 in execute(sql2) LOOP
    
    data_res  := to_char(rec2.dataanalitica,'YYYY-MM-DD');
    -- Falta modificar las capceleras
    IF provatecnica != rec2.idprovatecnica THEN
      provatecnica := rec2.idprovatecnica;
      sql1 :='select pacients.nom,pacients.cognoms,provestecnica.idprovatecnica,pacients.idpacient,catalegproves.idprova,catalegproves.nom_prova from pacients join catalegproves on pacients.idpacient ='||idpacient ||' and catalegproves.idprova = '||idprova||' join provestecnica on provestecnica.idprova='||idprova||' and provestecnica.idprovatecnica='||provatecnica||' group by provestecnica.idprovatecnica,pacients.nom,pacients.idpacient,pacients.cognoms,provestecnica.idprovatecnica,catalegproves.idprova,catalegproves.nom_prova;';
      FOR rec in execute(sql1) LOOP
        ret := ret|| rec.idpacient ||'+++'||rec.nom||'+++'||rec.cognoms||'+++'||rec.idprovatecnica||'+++'||rec.idprova||'+++'||rec.nom_prova|| e' \n';
      END LOOP; 
    END IF;
    -- SORTIDA
    IF rec2.resultat_numeric THEN
      --MINIM and Maxim
      sql3 := 'select MIN(cast(resultats.resultats as float)),MAX(cast(resultats.resultats as float)) from provestecnica join resultats  on provestecnica.idprova ='|| idprova ||' and resultats.idprovatecnica=provestecnica.idprovatecnica join analitiques on resultats.idanalitica=analitiques.idanalitica and analitiques.idpacient='||idpacient||' and analitiques.dataanalitica<= '''||data_inici||''' and provestecnica.idprovatecnica= '||provatecnica||';';
      FOR rec3 in execute(sql3) LOOP
        minim := rec3.min;
        maxim := rec3.max;
      END LOOP;
      -- VALORACIO
      -- 1 ->  NORMAL 
      -- 2 ->  PATOLÒGIC
      -- 3 ->  PÀNIC
      valoracio := valorar_idresultat(rec2.idresultat);
      
      -- Valors de referencia
      raise notice '%',valoracio;
      selec_valors := valors_referencia(provatecnica,idpacient,data_res);
      IF valoracio = '1' THEN
        valors_ref :='';
        res_char := 'NORMAL';
      ELSEIF valoracio = '2' THEN
        sql4 := 'select split_part('''||selec_valors||''',''-'',1);';
        EXECUTE (sql4) INTO minpat;
        raise notice '%',minpat;
        sql4 := 'select split_part('''||selec_valors||''',''-'',2);';
        EXECUTE (sql4) INTO maxpat;
        valors_ref := '('||minpat||' - '||maxpat||')';
        res_char := 'PATOLOGIC';
      ELSEIF valoracio = '3' THEN
        sql4 := 'select split_part('''||selec_valors||''',''-'',3);';
        EXECUTE (sql4) INTO minpan;
        sql4 := 'select split_part('''||selec_valors||''',''-'',4);';
        EXECUTE (sql4) INTO maxpan;
        valors_ref := '('||minpan||' - '||maxpan||')';
        res_char := 'PANIC';
      END IF;
      
      IF cast(rec2.resultats as int) = maxim THEN
        ret := ret||rec2.idanalitica||'---' ||data_res||' --- '||provatecnica||'---'||rec2.resultats||'-'||'      '||'-'||res_char||' -'||valors_ref||' -MAX'|| e' \n';
      ELSEIF cast(rec2.resultats as int) = minim THEN
        ret := ret||rec2.idanalitica||'---'||data_res||' --- '||provatecnica||'---'||rec2.resultats||'-'||'      '||'-'||res_char||' -'||valors_ref||' -MIN'|| e' \n';
      ELSE
        ret := ret||rec2.idanalitica||'---' ||data_res||' --- '||provatecnica||'---'||rec2.resultats||'-'||'      '||'-'||res_char||' -'||valors_ref|| e' \n';
      END IF;

    ELSE
      --valoracio alfpat
      valoracio := valorar_idresultat(rec2.idresultat);
      IF valoracio = '1' THEN
        res_char := 'NORMAL';
      ELSE
        res_char := 'PATOLOGIC';
      END IF;
      ret := ret||rec2.idanalitica||'---' ||data_res||'-'||provatecnica||'-'||rec2.resultats||'-'||'      '||'-'||res_char|| e' \n';
    END IF;
  END LOOP;
RETURN ret;
EXCEPTION 
  WHEN unique_violation THEN return '-1'; 
  WHEN foreign_key_violation THEN return '-2'; 
  WHEN not_null_violation THEN return '-3';
  --WHEN others THEN return '-4'; 
END;
$$
language 'plpgsql' volatile;
-- =====================================================================
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
  analitica bigint;
  id_resultat bigint;
  ret varchar :='';
  data_analitica timestamp;
  resultat varchar :='';
  valoracio varchar;
  prova int := 0;
  n_prova varchar;
BEGIN
  sql1 := 'SELECT * FROM pacients WHERE idpacient = ' || id_pacient || ';';

  FOR rec IN EXECUTE(sql1) LOOP
    trobat := True;
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
    END LOOP;
    
    IF NOT trobat THEN
      return '-6';
    END IF;
  ELSE
    sql1 := 'SELECT idanalitica,dataanalitica FROM analitiques WHERE idpacient = ' || id_pacient || ' order by dataanalitica desc limit 1;';
    FOR rec IN EXECUTE(sql1) LOOP
      trobat := True;
      analitica := rec.idanalitica;	
      data_analitica := rec.dataanalitica;	
    END LOOP;
    
    IF NOT trobat THEN
      return '-7';
    END IF;
  END IF;

  /* #####################################################################
   # HASTA AQUI, TANTO COMO EL PACIENTE COMO LA ANALITICA EXISTEN
   #####################################################################	
  */
  -- select * from resultats join provestecnica on resultats.idanalitica= 2 and provestecnica.idprovatecnica=resultats.idprovatecnica;
  -- select provestecnica.idprova,resultats.dataresultat from resultats join provestecnica on resultats.idanalitica= 12 and provestecnica.idprovatecnica=resultats.idprovatecnica group by resultats.dataresultat, provestecnica.idprova;
  trobat := False;
  sql1 := 'select provestecnica.idprova from resultats join provestecnica on resultats.idanalitica= ' || analitica || ' and provestecnica.idprovatecnica=resultats.idprovatecnica group by provestecnica.idprova;';
  
  FOR rec IN EXECUTE(sql1) LOOP
    trobat := True;
    IF prova != rec.idprova THEN
      prova := rec.idprova;
      ret := ret||historialpacpro(id_pacient,prova,data_analitica);
    END IF;
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
