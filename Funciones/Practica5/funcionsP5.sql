/*

Modificar el procediment emmagatzemat que retorna la patologia d’un 
resultat per tal que busqui els valors de referència corresponents al 
sexe i a l’edat del pacient. 

Si la funció no rep pacient o si i el pacient no té registrada la data 
de naixement o si el pacient no té registrat el sexe 
es retornarà resultat patològic.


-- 1 ->  NORMAL 
-- 2 ->  PATOLÒGIC
-- 3 ->  PÀNIC

SEXE
M=1
F=2
*/
CREATE OR REPLACE FUNCTION determina_resultat(
idprovatecnica bigint,
idpacient bigint,
resultat varchar,
fecha_analitica timestamp default current_timestamp)

RETURNS text
AS
$$
DECLARE
  sql1 varchar := '';
  sql2 varchar := '';
  ret varchar :='';
  rec record;
  trobat boolean := False;
  edat int;
  sexe int;
  min_pat float;
  max_pat float;
  min_pan float;
  max_pan float;
  res_numeric float;
BEGIN
  sql1 := 'SELECT * FROM pacients WHERE idpacient = ' || idpacient || ';';
  FOR rec IN EXECUTE(sql1) LOOP
    trobat:= True;
    IF rec.data_naix is NULL OR rec.sexe is NULL THEN
      return '2';
    ELSE
      sql2 := 'select to_char(age('''||fecha_analitica||''','''||rec.data_naix||'''), '''||'YY'||''');';
      --sql2 := 'select to_char(age(timestamp '''||rec.data_naix||'''), '''||'YY'||''');';
      EXECUTE (sql2) INTO edat;
      IF rec.sexe = 'M' THEN
        sexe = 1;
      ELSE
        sexe = 2;
      END IF;
    END IF;
  END LOOP;
  
  IF NOT trobat THEN
    return '2';
  END IF;
  
  trobat:= False;
  sql1 := 'select * from provestecnica where idprovatecnica='||idprovatecnica||' and sexe ='||sexe||';';
  FOR rec IN EXECUTE(sql1) LOOP
    trobat :=True;
  END LOOP;
  
  IF NOT trobat THEN
    sexe=0;
  END IF;
  
  sql1 := 'select * from provestecnica where idprovatecnica='||idprovatecnica||' and sexe='||sexe||' and '||edat||' between edat_inicial and edat_final and edat_final >'||edat||' ;';
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
    return '-5';
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

CREATE OR REPLACE FUNCTION valorar_idresultat(id_resultat bigint)
RETURNS text
AS
$$
DECLARE
	sql1 text;
	ret varchar :='';
	id_provatecnica bigint;
	id_analitica bigint;
	id_pacient bigint;
	res varchar;
	rec record;
  data_analitica timestamp;
	trobat boolean :=false;
BEGIN
	sql1 := 'SELECT * FROM  resultats WHERE idresultat = ' || id_resultat || ';';
	
	trobat := false;
	FOR rec IN EXECUTE(sql1) LOOP
		trobat          := true;
		id_provatecnica := rec.idprovatecnica;
		id_analitica    := rec.idanalitica;
		res             := rec.resultats;
    
	END LOOP;
	
	IF NOT trobat THEN
		return '-5';
	END IF;	
	
	sql1 := 'SELECT idpacient FROM analitiques WHERE idanalitica = ' || id_analitica || ';';
	
	trobat := False;	
	FOR rec IN EXECUTE(sql1) LOOP
		trobat := True;
		id_pacient := rec.idpacient;
    data_analitica := rec.dataanalitica;
	END LOOP;
	
	IF NOT trobat THEN
		return '-6';
	END IF;
	
	ret := determina_resultat(id_provatecnica,id_pacient,res,data_analitica);
	
RETURN ret;
	
EXCEPTION 
	WHEN unique_violation THEN return '-1'; 
	WHEN foreign_key_violation THEN return '-2'; 
	WHEN not_null_violation THEN return '-3';
	WHEN others THEN return '-4'; 
END;
$$
language 'plpgsql' volatile;
