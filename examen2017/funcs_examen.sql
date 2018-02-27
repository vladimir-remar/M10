CREATE OR REPLACE FUNCTION determina_patlogia_rep(
  id_analitica bigint,
  id_provatecnica  bigint,
  num_repeticio int default NULL
)
RETURNS text
AS
$$
DECLARE
  ret varchar :='';
  sql1 text;
  rec record;
  id_resultat bigint;
  trobat boolean := False;
BEGIN
  sql1 := 'SELECT * FROM  analitiques WHERE idanalitica = ' || id_analitica || ';';
  For rec in EXECUTE (sql1) LOOP
    trobat := True;
  END LOOP;
  IF NOT trobat THEN
    return '-5'
  END IF;
  trobat := False;
  sql1 := 'SELECT * FROM  provestecnica WHERE idprovatecnica = ' || id_provatecnica || ';';
  FOR rec in EXECUTE (sql1) LOOP
    trobat := True;
  END LOOP;
  IF NOT trobat THEN
    return '-6'
  END IF;
  
  trobat:= False;
  slq1 := 'SELECT * FROM  resultats WHERE idanalitica = ' || id_analitica || ' and idprovatecnica = ' ||id_provatecnica||';';
  FOR rec in EXECUTE (sql1) LOOP
    trobat := True;
  END LOOP;
  IF NOT trobat THEN
    return '-7'
  END IF;
  
  IF num_repeticio IS NULL or num_repeticio = '' THEN
    sql1 := 'SELECT * FROM  resultats WHERE idanalitica = ' || id_analitica || ' and idprovatecnica = ' ||id_provatecnica||' order by rep desc limit 1;';
  ELSE
    sql1 := 'SELECT * FROM  resultats WHERE idanalitica = ' || id_analitica || ' and idprovatecnica = ' ||id_provatecnica||' and rep = '||num_repeticio||';'; 
  END IF;
  FOR rec in EXECUTE(sql1) LOOP
    id_resultat := rec.idresultat;
  END LOOP;
  
  ret := valorar_idresultat(id_resultat);
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
CREATE OR REPLACE FUNCTION informehistorial_rep(
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
