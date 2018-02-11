-- 1 ->  NORMAL 
-- 2 ->  PATOLÒGIC
-- 3 ->  PÀNIC
-- alter sequence serial restart with 105;
-- CURRENT_TIMESTAMP
-- ---------------------------------------------------------------------
/*
1. Omplir amb les dades necessàries per tenir resultats de diferents analítiques per 2 pacients
*/
CREATE OR REPLACE FUNCTION insert_analitiques( 
iddoctor bigint,
idpacient bigint,
fecha varchar)
RETURNS text
AS
$$
DECLARE
	sql1 text;
	data_analitica date;
BEGIN
	data_analitica := cast (fecha as  date);
	sql1 := 'INSERT INTO analitiques VALUES (default,'|| $1 ||','|| $2 ||','''|| data_analitica || ''');';
	execute(sql1);
RETURN '1';
	
EXCEPTION 
	WHEN unique_violation THEN return '-1'; 
	WHEN foreign_key_violation THEN return '-2'; 
	WHEN not_null_violation THEN return '-3';
	--WHEN others THEN return '-4'; 
END;
$$
language 'plpgsql' volatile;
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_resultats(
id_analitica bigint,
id_povatecnica bigint,
resultat varchar)
RETURNS text
AS
$$
DECLARE
  sql1 text;
  rec record;
  ret varchar :='';
  fecha timestamp;
BEGIN
  IF resultat is NULL or resultat = '' THEN
    RETURN '-5';
  END IF;
  fecha := current_timestamp;
  sql1 := 'update resultats set resultats = '''||resultat||''', dataresultat = '''|| fecha || ''' where idanalitica = '||id_analitica||' and idprovatecnica = '||id_povatecnica||';';
  EXECUTE(sql1);
RETURN '1';
EXCEPTION 
	WHEN unique_violation THEN return '-1'; 
	WHEN foreign_key_violation THEN return '-2'; 
	WHEN not_null_violation THEN return '-3';
	--WHEN others THEN return '-4'; 
END;
$$
language 'plpgsql' volatile;
-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION insert_resultats(
idanalitica bigint,
idprovatecnica bigint,
resultats varchar)
RETURNS text AS
$$
DECLARE
	sql1 text;
BEGIN
	sql1 := 'INSERT INTO resultats VALUES (default,'|| $1 ||','|| $2 ||','''|| $3 ||''','''||current_timestamp||''');';
	execute(sql1);
RETURN '1'	;
	
EXCEPTION 
	WHEN unique_violation THEN return '-1'; 
	WHEN foreign_key_violation THEN return '-2'; 
	WHEN not_null_violation THEN return '-3';
	--WHEN others THEN return '-4'; 
END;
$$
language 'plpgsql' volatile;
-- ---------------------------------------------------------------------
CREATE OR REPLACE FUNCTION es_Numeric(num_str varchar)
RETURNS bool AS
$$
DECLARE
	i numeric;
BEGIN
	i := cast (num_str as numeric);
	return true;
EXCEPTION 
	WHEN others then return false;
END	
$$
LANGUAGE 'plpgsql' IMMUTABLE;
-- ---------------------------------------------------------------------
/*
2. Escriure una funció per determinar si un resultat és normal, 
no-normal(patològic) o pànic. La funció no tindrà en compte el sexe i 
l'edat del pacient (de moment). La funció rebrà el codi de la prova 
(idprovatecnica), el codi del pacient i el resultat i retornarà un 
1(normal), un 2(patològic) o un 3(pànic).
*/

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
-- ---------------------------------------------------------------------
/*
3. Escriure una altra funció que rebi un id_resultat de la taula 
resultats i cridi a la funció anterior per determinar la patologia del 
resultat i retornar un 1(normal), un 2(patològic) o un 3(pànic).
*/
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
	END LOOP;
	
	IF NOT trobat THEN
		return '-6';
	END IF;
	
	ret := determina_resultat(id_provatecnica,id_pacient,res);
	
RETURN ret;
	
EXCEPTION 
	WHEN unique_violation THEN return '-1'; 
	WHEN foreign_key_violation THEN return '-2'; 
	WHEN not_null_violation THEN return '-3';
	WHEN others THEN return '-4'; 
END;
$$
language 'plpgsql' volatile;
-- ---------------------------------------------------------------------
/*
4. Escriure una funció que examini tots els resultats d'una analítica 
d'un pacient, rebrà l’id del pacient i el codi d’analítica (si no rep 
el codi d’analítica s'agafarà l'última analítica que s'hagi fet el 
pacient) i retorni una cadena amb :

pacient#data#codi_prova#nom_prova#resultat#valoració|
pacient#data#codi_prova#nom_prova#resultat#valoració|
pacient#data#codi_prova#nom_prova#resultat#valoració| 

ORDER BY DATA LIMIT 1;
mirar tots els resultats
*/
CREATE OR REPLACE FUNCTION examina_resultats(
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
			trobat    := True;
			analitica := rec.idanalitica;	
		END LOOP;
		
		IF NOT trobat THEN
			return '-6';
		END IF;
	ELSE
		sql1 := 'SELECT idanalitica FROM analitiques WHERE idpacient = ' || id_pacient || ' order by dataanalitica desc limit 1;';
		FOR rec IN EXECUTE(sql1) LOOP
			trobat    := True;
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
		data_res  := to_char(rec.dataresultat,'YYYY-MM-DD');
		valoracio := valorar_idresultat(rec.idresultat);
		
		
		
		sql2 := 'SELECT * FROM  provestecnica WHERE idprovatecnica = ' || rec.idprovatecnica || ';';
		
		FOR rec2 IN EXECUTE(sql2) LOOP
			prova := rec2.idprova;
		END LOOP;
		
		sql3 := 'SELECT * FROM  catalegproves WHERE idprova = ' || prova|| ';';
		
		FOR rec2 IN EXECUTE(sql3) LOOP
			n_prova :=rec2.nom_prova ;
		END LOOP;
		
		ret := ret || '' || nom || '#' || cognom || '#' || data_res || '#' || prova || '#' || n_prova || '#' || resultat || '#' || valoracio || e' \n';
		
	
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
-- ---------------------------------------------------------------------
/*
5. Escriure una script per ser executada des del cron per omplir la 
taula ResultatsAnalitiques cada cop que arribin noves dades al 
directori /tmp/resultats. Les dades que arribin seran registres amb 
idanalItica, idprovatecnica i resultat.

Aquesta script guardara els resultats en fitxers de log. Per cada 
execucio de l’script es guardara el resultat en un fitxer de log. El 
resultat per el log serà :

data – hora – execució correcta
data – hora – error amb idanalitica-idprovatectnica-resultat, idanalitica-idprovatectnica-resultat, ...
data – hora – execució correcta
data – hora – error amb idanalitica-idprovatectnica-resultat
data – hora – error amb idanalitica-idprovatectnica-resultat, idanalitica-idprovatectnica-resultat, ...

1) Si la analitica no existe 
*/
CREATE OR REPLACE FUNCTION actulizacions_resultats()
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
	ret varchar :='';
	fecha date;
	hora time;
  update_res varchar :='';
  insertar varchar :='';
  del varchar :='';
BEGIN
  sql1 := 'select * from resultatsnous'; 
	
	FOR rec IN EXECUTE(sql1) LOOP
		sql2 := 'select * from analitiques join provestecnica ON  analitiques.idanalitica ='|| rec.id_analitica ||' and provestecnica.idprovatecnica ='|| rec.id_provatecnica ||';';
		
		FOR rec2 IN EXECUTE(sql2) LOOP
			trobat := True;
		END LOOP;
		
    fecha := to_char(current_timestamp,'YYYY-MM-DD');
    hora  := to_char(current_timestamp,'HH:MM:SS');
    
		IF NOT trobat THEN
			ret   := ret ||fecha||'--'||hora||'--'||' error amb '||rec.id_analitica||'-'||rec.id_provatecnica||'-'||rec.resultat||e' \n';
		ELSE
    /* #####################################################################
   # HASTA AQUI, TANTO COMO LA PROVATECNICA COMO LA ANALITICA EXISTEN
   #####################################################################	  
   */
      sql2 := 'select * from resultats where idanalitica ='|| rec.id_analitica ||' and idprovatecnica ='|| rec.id_provatecnica ||';';
      trobat := False;
      
      FOR rec2 IN EXECUTE(sql2) LOOP
        --update de la analitica
        trobat := True;
        update_res := update_resultats(rec.id_analitica,rec.id_provatecnica,rec.resultat);
        
        IF update_res = '1' THEN
          ret := ret ||fecha||'--'||hora||'--'||' execució correcta update'||e' \n';
        ELSE
          ret := ret ||fecha||'--'||hora||'--'||' error amb '||rec.id_analitica||'-'||rec.id_provatecnica||'-'||rec.resultat||e' \n';
        END IF;
      END LOOP;
      
      IF NOT trobat THEN
        --insert a resultats
        insertar := insert_resultats(rec.id_analitica,rec.id_provatecnica,rec.resultat);
        
        IF insertar = '1' THEN
          ret := ret ||fecha||'--'||hora||'--'||' execució correcta insert'||e' \n';
        ELSE
          ret := ret ||fecha||'--'||hora||'--'||' error amb '||rec.id_analitica||'-'||rec.id_provatecnica||'-'||rec.resultat||e' \n';
        END IF;
        
      END IF;
    END IF;
    del := 'delete from resultatsNous where id_analitica ='||rec.id_analitica||' and id_provatecnica ='|| rec.id_provatecnica||' and resultat = '''||rec.resultat||''';';
    execute(del);
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
