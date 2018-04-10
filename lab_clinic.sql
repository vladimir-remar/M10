--
-- PostgreSQL database dump
--
create database if not exists lab_clinc;
-- Dumped from database version 9.5.10
-- Dumped by pg_dump version 9.5.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: actulizacions_resultats(); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION actulizacions_resultats() RETURNS text
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.actulizacions_resultats() OWNER TOvremar;

--
-- Name: comproba_pacient(character varying, character varying); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION comproba_pacient(camp character varying, valor character varying) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
DECLARE 
	sql text;
	res varchar := '';
	res_select record;
BEGIN
	sql := 'SELECT * FROM pacients WHERE ' || $1 || ' = ''' || $2 || ''';';
	FOR res_select IN EXECUTE(sql) LOOP
		IF res = '' THEN
			res := res_select;
		END IF;
	END LOOP;
	IF res = '' THEN
		RETURN '1';
	END IF;
RETURN '0';
END;

$_$;


ALTER FUNCTION public.comproba_pacient(camp character varying, valor character varying) OWNER TOvremar;

--
-- Name: determina_resultat(bigint, bigint, character varying); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION determina_resultat(idprovatecnica bigint, idpacient bigint, resultat character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
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
      sql2 := 'select to_char(age(timestamp '''||rec.data_naix||'''), '''||'YY'||''');';
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
$$;


ALTER FUNCTION public.determina_resultat(idprovatecnica bigint, idpacient bigint, resultat character varying) OWNER TOvremar;

--
-- Name: dni_correct(character varying); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION dni_correct(dni character varying) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE

 	ret varchar := '1';
 	partnum varchar;
 	lletras varchar := 'TRWAGMYFPDXBNJZSQVHLCKE';
 	modul int;
 	lletraresultat varchar(1);
 	lletradni varchar(1);
BEGIN
 	IF char_length(dni) != 9 THEN
		 ret := '-1';
	ELSE
 		partnum = substr (dni, 1, 8);
 		modul := cast (partnum as int) % 23;
 		
 		lletraresultat := substring(lletras from modul + 1  for 1);
		lletradni := right(dni,1);

		IF lletraresultat <>  lletradni THEN
			ret := '2';
		END IF;
		
	END IF;
RETURN ret;
EXCEPTION WHEN others THEN
	RETURN '3';
END;
$$;


ALTER FUNCTION public.dni_correct(dni character varying) OWNER TOvremar;

--
-- Name: es_numeric(character varying); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION es_numeric(num_str character varying) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
	i numeric;
BEGIN
	i := cast (num_str as numeric);
	return true;
EXCEPTION 
	WHEN others then return false;
END	
$$;


ALTER FUNCTION public.es_numeric(num_str character varying) OWNER TOvremar;

--
-- Name: examina_resultats(bigint, bigint); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION examina_resultats(id_pacient bigint, id_analitica bigint DEFAULT NULL::bigint) RETURNS text
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.examina_resultats(id_pacient bigint, id_analitica bigint) OWNER TOvremar;

--
-- Name: exemple(integer, integer); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION exemple(integer, integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
 numero1 ALIAS FOR $1;
 numero2 ALIAS FOR $2;

 constante CONSTANT integer := 100;
 resultado integer;

BEGIN
 resultado := (numero1 * numero2) + constante;
 RETURN resultado;
END;
$_$;


ALTER FUNCTION public.exemple(integer, integer) OWNER TOvremar;

--
-- Name: exemple_txt(integer, integer); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION exemple_txt(integer, integer) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE
 numero1 ALIAS FOR $1;
 numero2 ALIAS FOR $2;

 constante CONSTANT integer := 100;
 resultado INTEGER;

 resultado_txt TEXT DEFAULT 'El resultat es 104'; 

BEGIN
 resultado := (numero1 * numero2) + constante;

 IF resultado <> 104 THEN
    resultado_txt :=  'El resultado NO es 104';
 END IF;

 RETURN resultado_txt;
END;
$_$;


ALTER FUNCTION public.exemple_txt(integer, integer) OWNER TOvremar;

--
-- Name: historialpacpro(bigint, bigint, timestamp without time zone); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION historialpacpro(idpacient bigint, idprova bigint, data_inici timestamp without time zone DEFAULT NULL::timestamp without time zone) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  nom varchar;
  cognom varchar;
  ret varchar :='';
  sql1 text;
  sql2 text;
  sql3 text;
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
  
BEGIN
  IF data_inici is null Then
    data_inici := current_timestamp;
  END IF;
  -- consulta base
  -- select * from provestecnica join resultats  on provestecnica.idprova = 101 and resultats.idprovatecnica=provestecnica.idprovatecnica join analitiques on resultats.idanalitica=analitiques.idanalitica and analitiques.idpacient=1 and resultats.dataresultat<=current_timestamp order by resultats.idprovatecnica,resultats.dataresultat desc;
  -- select MIN(cast(resultats.resultats as float)),Max(cast(resultats.resultats as float)) from provestecnica join resultats  on provestecnica.idprova = 101 and resultats.idprovatecnica=provestecnica.idprovatecnica join analitiques on resultats.idanalitica=analitiques.idanalitica and analitiques.idpacient=1 and resultats.dataresultat<=current_timestamp;
  -- select Max(cast(resultats.resultats as float)) from provestecnica join resultats  on provestecnica.idprova = 101 and resultats.idprovatecnica=provestecnica.idprovatecnica join analitiques on resultats.idanalitica=analitiques.idanalitica and analitiques.idpacient=1 and resultats.dataresultat<=current_timestamp;
  provatecnica := 0;
  -- Resultats per aquest pacient i aquesta prova, a partit de la data_inici
  sql2 := 'select * from provestecnica join resultats  on provestecnica.idprova ='|| idprova ||' and resultats.idprovatecnica=provestecnica.idprovatecnica join analitiques on resultats.idanalitica=analitiques.idanalitica and analitiques.idpacient='||idpacient||' and analitiques.dataanalitica<= '''||data_inici||'''order by resultats.idprovatecnica,analitiques.dataanalitica desc;';
  FOR rec2 in execute(sql2) LOOP
    data_res  := to_char(rec2.dataanalitica,'YYYY-MM-DD');
    
    IF provatecnica != rec2.idprovatecnica THEN
      provatecnica := rec2.idprovatecnica;
      sql1 :='select * from pacients join catalegproves on pacients.idpacient ='||idpacient ||' and catalegproves.idprova = '||idprova||' join provestecnica on provestecnica.idprova='||idprova||' and provestecnica.idprovatecnica='||provatecnica||';';
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
      IF valoracio = '1' THEN
        valors_ref :='';
        res_char := 'NORMAL';
      ELSEIF valoracio = '2' THEN
        valors_ref := '('||rec2.minpat||' - '||rec2.maxpat||')';
        res_char := 'PATOLOGIC';
      ELSEIF valoracio = '3' THEN
        valors_ref := '('||rec2.minpan||' - '||rec2.maxpan||')';
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
$$;


ALTER FUNCTION public.historialpacpro(idpacient bigint, idprova bigint, data_inici timestamp without time zone) OWNER TOvremar;

--
-- Name: informehistorial(bigint, bigint); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION informehistorial(id_pacient bigint, id_analitica bigint DEFAULT NULL::bigint) RETURNS text
    LANGUAGE plpgsql
    AS $$
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
    sql1 := 'SELECT idanalitica FROM analitiques WHERE idpacient = ' || id_pacient || ' order by dataanalitica desc limit 1;';
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
$$;


ALTER FUNCTION public.informehistorial(id_pacient bigint, id_analitica bigint) OWNER TOvremar;

--
-- Name: insert_analitiques(bigint, bigint, character varying); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION insert_analitiques(iddoctor bigint, idpacient bigint, fecha character varying) RETURNS text
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.insert_analitiques(iddoctor bigint, idpacient bigint, fecha character varying) OWNER TOvremar;

--
-- Name: insert_pacients(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION insert_pacients(nom character varying, cognoms character varying, dni character varying, data_naix character varying, sexe character varying, adreca character varying, ciutat character varying, c_postal character varying, telefon character varying, email character varying, num_ss character varying DEFAULT ''::character varying, num_cat character varying DEFAULT ''::character varying, nie character varying DEFAULT ''::character varying, passaport character varying DEFAULT ''::character varying) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE 
	sql1 text;
	sql2 text;
	sql3 text;
	res varchar := '';
	res_select record;
	data_naix_date date;
BEGIN
	IF dni is not null and dni_correct(dni) != '1' THEN
		RETURN '-1';
	END IF;
	
	IF dni is not null and comproba_pacient('dni',dni) = '0' THEN
		RETURN '2';
	END IF;
	/*
	ELSEIF num_ss is not null and comproba_pacient('num_ss',num_ss) = '0' THEN
		RETURN '3';
	ELSEIF  num_cat is not null and comproba_pacient('num_cat',num_cat) = '0' THEN
		RETURN '4';
	ELSEIF  nie is not null and comproba_pacient('nie',nie) = '0' THEN
		RETURN '5';
	ELSEIF passaport is not null and comproba_pacient('passaport',passaport) = '0' THEN
		RETURN '6';
	END IF;
	*/
	data_naix_date := cast (data_naix as date);
	/* to_date(var,'DD-MM-YYYY')*/
	/*(nom,cognom,dni,data_naix,sexe,adreca,ciutat,c_postal,telefom,email,num_ss,num_cat,nif,passaport)*/
	--raise notice '% % % % % % % % % % % % % %',nom,cognom,dni,data_naix,sexe,adreca,ciutat,c_postal,telefom,email,num_ss,num_cat,nif,passaport;
	--sql1 := 'INSERT INTO pacients VALUES (default,'''|| $1 ||''','|| $2 ||''','|| $3 || ''','|| data_naix_date || ''','|| $5 || ''','|| $6 || ''','|| $7 || ''','|| $8 || ''','|| $9 || ''','|| $10 || ''','|| $11 || ''','|| $12 || ''','|| $13 || ''','|| $14 || ''');';
	sql1 := 'INSERT INTO pacients VALUES (default,';
	
	IF $1 is NULL THEN
		sql2 := sql1||' NULL,';
	ELSE
		sql2 := sql1||''''||$1||''',';
	END IF;
	IF $2 is NULL THEN
		sql2 := sql2||' NULL, ';
	ELSE
		sql2 := sql2||''''||$2||''',';
	END IF;
	IF $3 is NULL THEN
		sql2 := sql2||' NULL, ';
	ELSE
		sql2 := sql2||''''||$3||''',';
	END IF;
	IF $4 is NULL THEN
		sql2 := sql2||' NULL, ';
	ELSE
		sql2 := sql2||''''||data_naix_date||''',';
	END IF;
	IF $5 is NULL THEN
		sql2 := sql2||'NULL, ';
	ELSE
		sql2 := sql2||''''||$5||''',';
	END IF;
	IF $6 is NULL THEN
		sql2 := sql2||'NULL, ';
	ELSE
		sql2 := sql2||''''||$6||''',';
	END IF;
	IF $7 is NULL THEN
		sql2 := sql2||'NULL, ';
	ELSE
		sql2 := sql2||''''||$7||''',';
	END IF;
	IF $8 is NULL THEN
		sql2 := sql2||'NULL, ';
	ELSE
		sql2 := sql2||''''||$8||''',';
	END IF;
	IF $9 is NULL THEN
		sql2 := sql2||'NULL, ';
	ELSE
		sql2 := sql2||''''||$9||''',';
	END IF;
	IF $10 is NULL THEN
		sql2 := sql2||'NULL, ';
	ELSE
		sql2 := sql2||''''||$10||''',';
	END IF;
	IF $11 is NULL THEN
		sql2 := sql2||'NULL, ';
	ELSE
		sql2 := sql2||''''||$11||''',';
	END IF;
	IF $12 is NULL THEN
		sql2 := sql2||'NULL, ';
	ELSE
		sql2 := sql2||''''||$12||''',';
	END IF;
	IF $13 is NULL THEN
		sql2 := sql2||'NULL, ';
	ELSE
		sql2 := sql2||''''||$13||''',';
	END IF;
	IF $14 is NULL THEN
		sql2 := sql2||'NULL);';
	ELSE
		sql2 := sql2||''''||$14||''');';
	END IF;
	--RAISE NOTICE 'sentenc: %',sql2;
	execute (sql2);
RETURN '1';
EXCEPTION 
  WHEN not_null_violation THEN return '-2'; 
  WHEN unique_violation THEN return '-3'; 
  WHEN others THEN return '-4';
END;
$_$;


ALTER FUNCTION public.insert_pacients(nom character varying, cognoms character varying, dni character varying, data_naix character varying, sexe character varying, adreca character varying, ciutat character varying, c_postal character varying, telefon character varying, email character varying, num_ss character varying, num_cat character varying, nie character varying, passaport character varying) OWNER TOvremar;

--
-- Name: insert_resultats(bigint, bigint, character varying); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION insert_resultats(idanalitica bigint, idprovatecnica bigint, resultats character varying) RETURNS text
    LANGUAGE plpgsql
    AS $_$
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
$_$;


ALTER FUNCTION public.insert_resultats(idanalitica bigint, idprovatecnica bigint, resultats character varying) OWNER TOvremar;

--
-- Name: insert_resultats(bigint, bigint, character varying, timestamp without time zone); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION insert_resultats(idanalitica bigint, idprovatecnica bigint, resultats character varying, dataresultat timestamp without time zone) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	sql1 text;
	data_res text;
BEGIN
	data_res := 'hola';
RETURN dataresultat	;
	
EXCEPTION 
	WHEN unique_violation THEN return '-1'; 
	WHEN foreign_key_violation THEN return '-2'; 
	WHEN not_null_violation THEN return '-3';
	--WHEN others THEN return '-4'; 
END;
$$;


ALTER FUNCTION public.insert_resultats(idanalitica bigint, idprovatecnica bigint, resultats character varying, dataresultat timestamp without time zone) OWNER TOvremar;

--
-- Name: insert_resultats(bigint, bigint, character varying, character varying); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION insert_resultats(idanalitica bigint, idprovatecnica bigint, resultats character varying, dataresultat character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	sql1 text;
	data_res timestamp;
BEGIN
	data_res := cast(dataresultat as timestamp);
RETURN data_res;
	
EXCEPTION 
	WHEN unique_violation THEN return '-1'; 
	WHEN foreign_key_violation THEN return '-2'; 
	WHEN not_null_violation THEN return '-3';
	--WHEN others THEN return '-4'; 
END;
$$;


ALTER FUNCTION public.insert_resultats(idanalitica bigint, idprovatecnica bigint, resultats character varying, dataresultat character varying) OWNER TOvremar;

--
-- Name: nous_pacients(); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION nous_pacients() RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
	sql1 text;
	sql2 text;
	d_naix varchar :='';
	res varchar := '';
	res2 varchar := '';
	res_select record;
	ret varchar := '';
	del varchar := '';
	
BEGIN
	sql1:= 'SELECT * FROM pacients_nous ';
	FOR res_select  IN EXECUTE(sql1) LOOP
		
		d_naix:= cast (res_select.data_naix as varchar);
		--sql2:= ''''||res_select.nom||''','''|| res_select.cognoms || ''','''||res_select.dni||''','''||d_naix||''','''||res_select.sexe||''','''||res_select.adreca||''','''||res_select.ciutat||''','''||res_select.c_postal||''','''||res_select.telefon||''','''||res_select.email||''','''||res_select.num_ss||''','''||res_select.num_cat||''','''||res_select.nie||''','''||res_select.passaport||'''';
		--raise notice '%',sql2;
		
		res := insert_pacients(res_select.nom, res_select.cognoms, res_select.dni, d_naix, res_select.sexe, res_select.adreca, res_select.ciutat, res_select.c_postal, res_select.telefon, res_select.email, res_select.num_ss, res_select.num_cat, res_select.nie, res_select.passaport);
		--raise notice '%',res_select.dni;
		If res = '1' THEN
			ret := ret||res_select.dni||': insertat';
		ELSE
			IF res = '-1'  THEN
				ret := ret||res_select.dni||': error dni';
			ELSE
			
				IF res = '2' THEN
					res:= update_nous(res_select.nom, res_select.cognoms, res_select.dni, d_naix, res_select.sexe, res_select.adreca, res_select.ciutat, res_select.c_postal, res_select.telefon, res_select.email, res_select.num_ss, res_select.num_cat, res_select.nie, res_select.passaport);
					IF res = '1' THEN
						ret := ret||res_select.dni||': modificat';
					ELSE
						ret := ret||res_select.dni||': error modificat';
					END IF;
				ELSE
				--raise notice '%',res2;
					ret := ret||res_select.dni||': error ';
				END IF;
			END IF;
		END IF;
		ret := ret|| E'\n';
		del := 'delete from pacients_nous where dni ='''||res_select.dni||'''';
		execute(del);
	END LOOP;
	
RETURN ret;
	
EXCEPTION 
	WHEN unique_violation THEN return '-1'; 
	WHEN foreign_key_violation THEN return '-2'; 
	WHEN not_null_violation THEN return '-3';
	--WHEN others THEN return '-4'; 
END;
$$;


ALTER FUNCTION public.nous_pacients() OWNER TOvremar;

--
-- Name: sumar1(integer); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION sumar1(integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
BEGIN
	RETURN $1 + 1;
END;
$_$;


ALTER FUNCTION public.sumar1(integer) OWNER TOvremar;

--
-- Name: update_nous(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION update_nous(nom character varying, cognoms character varying, dni character varying, data_naix character varying, sexe character varying, adreca character varying, ciutat character varying, c_postal character varying, telefon character varying, email character varying, num_ss character varying DEFAULT ''::character varying, num_cat character varying DEFAULT ''::character varying, nie character varying DEFAULT ''::character varying, passaport character varying DEFAULT ''::character varying) RETURNS text
    LANGUAGE plpgsql
    AS $_$
DECLARE 

	sql1 text;
	sql2 text;
	sql3 text;
	data_naix_date date;

	
BEGIN
	
	sql1 := 'UPDATE pacients SET ';
	
	IF nom != '' THEN
		sql2 := sql1 || ' nom = ''' || $1 || '''';
	END IF;
	IF cognoms != '' THEN
		IF sql2 = '' THEN
			sql2 := sql1 || ' cognoms = ''' || $2 || '''';
		ELSE
			sql2 := sql2 || ',cognoms = ''' || $2 || '''';
		END IF;
	END IF;
	IF dni != '' THEN
		IF sql2 = '' THEN
			sql2 := sql1 || ' dni = ''' || $3 || '''';
		ELSE
			sql2 := sql2 || ',dni = ''' || $3 || '''';
		END IF;
	END IF;
	IF data_naix != '' THEN
		data_naix_date := cast (data_naix as date);
		IF sql2 = '' THEN
			sql2 := sql1 || ' data_naix = ''' || data_naix_date || '''';
		ELSE
			sql2 := sql2 || ',data_naix = ''' || data_naix_date || '''';
		END IF;
	END IF;
	IF sexe != '' THEN
		IF sql2 = '' THEN
			sql2 := sql1 || ' sexe = ''' || $5 || '''';
		ELSE
			sql2 := sql2 || ',sexe = ''' || $5 || '''';
		END IF;
	END IF;
	IF adreca != '' THEN
		IF sql2 = '' THEN
			sql2 := sql1 || ' adreca = ''' || $6 || '''';
		ELSE
			sql2 := sql2 || ',adreca = ''' || $6 || '''';
		END IF;
	END IF;
	IF ciutat != '' THEN
		IF sql2 = '' THEN
			sql2 := sql1 || ' ciutat = ''' || $7 || '''';
		ELSE
			sql2 := sql2 || ',ciutat = ''' || $7 || '''';
		END IF;
	END IF;
	IF c_postal != '' THEN
		IF sql2 = '' THEN
			sql2 := sql1 || ' c_postal = ''' || $8 || '''';
		ELSE
			sql2 := sql2 || ',c_postal = ''' || $8 || '''';
		END IF;
	END IF;
	IF telefon != '' THEN
		IF sql2 = '' THEN
			sql2 := sql1 || ' telefon = ''' || $9 || '''';
		ELSE
			sql2 := sql2 || ',telefon = ''' || $9 || '''';
		END IF;
	END IF;
	IF email != '' THEN
		IF sql2 = '' THEN
			sql2 := sql1 || ' email = ''' || $10 || '''';
		ELSE
			sql2 := sql2 || ',email = ''' || $10 || '''';
		END IF;
	END IF;
	IF num_ss != '' THEN
		IF sql2 = '' THEN
			sql2 := sql1 || ' num_ss = ''' || $11 || '''';
		ELSE
			sql2 := sql2 || ',num_ss = ''' || $11 || '''';
		END IF;
	END IF;
	IF num_cat != '' THEN
		IF sql2 = '' THEN
			sql2 := sql1 || ' num_cat = ''' || $12 || '''';
		ELSE
			sql2 := sql2 || ',num_cat = ''' || $12 || '''';
		END IF;
	END IF;
	IF nie != '' THEN
		IF sql2 = '' THEN
			sql2 := sql1 || ' nie = ''' || $13 || '''';
		ELSE
			sql2 := sql2 || ',nie = ''' || $13 || '''';
		END IF;
	END IF;
	IF passaport != '' THEN
	IF sql2 = '' THEN
			sql2 := sql1 || ' passaport = ''' || $14 || '''';
		ELSE
			sql2 := sql2 || ',passaport = ''' || $14 || '''';
		END IF;
	END IF;
	
	sql3 := sql2 || ' WHERE dni = '''|| $3 || '''';
	--raise notice '%',sql3;
	EXECUTE(sql3);
	
RETURN '1';
EXCEPTION 
	WHEN unique_violation THEN return '-1'; 
	WHEN foreign_key_violation THEN return '-2'; 
	WHEN not_null_violation THEN return '-3';
	--WHEN others THEN return '-4'; 
END;
$_$;


ALTER FUNCTION public.update_nous(nom character varying, cognoms character varying, dni character varying, data_naix character varying, sexe character varying, adreca character varying, ciutat character varying, c_postal character varying, telefon character varying, email character varying, num_ss character varying, num_cat character varying, nie character varying, passaport character varying) OWNER TOvremar;

--
-- Name: update_resultats(bigint, bigint, character varying); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION update_resultats(id_analitica bigint, id_povatecnica bigint, resultat character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.update_resultats(id_analitica bigint, id_povatecnica bigint, resultat character varying) OWNER TOvremar;

--
-- Name: valorar_idresultat(bigint); Type: FUNCTION; Schema: public; Owner:vremar
--

CREATE FUNCTION valorar_idresultat(id_resultat bigint) RETURNS text
    LANGUAGE plpgsql
    AS $$
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
$$;


ALTER FUNCTION public.valorar_idresultat(id_resultat bigint) OWNER TOvremar;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: alarmes; Type: TABLE; Schema: public; Owner:vremar
--

CREATE TABLE alarmes (
    idalarma integer NOT NULL,
    idresultat bigint,
    nivellalama smallint NOT NULL,
    validat boolean NOT NULL,
    missatge character varying(100) NOT NULL
);


ALTER TABLE alarmes OWNER TOvremar;

--
-- Name: alarmes_idalarma_seq; Type: SEQUENCE; Schema: public; Owner:vremar
--

CREATE SEQUENCE alarmes_idalarma_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE alarmes_idalarma_seq OWNER TOvremar;

--
-- Name: alarmes_idalarma_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner:vremar
--

ALTER SEQUENCE alarmes_idalarma_seq OWNED BY alarmes.idalarma;


--
-- Name: analitiques; Type: TABLE; Schema: public; Owner:vremar
--

CREATE TABLE analitiques (
    idanalitica integer NOT NULL,
    iddoctor bigint,
    idpacient bigint,
    dataanalitica timestamp without time zone NOT NULL
);


ALTER TABLE analitiques OWNER TOvremar;

--
-- Name: analitiques_idanalitica_seq; Type: SEQUENCE; Schema: public; Owner:vremar
--

CREATE SEQUENCE analitiques_idanalitica_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE analitiques_idanalitica_seq OWNER TOvremar;

--
-- Name: analitiques_idanalitica_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner:vremar
--

ALTER SEQUENCE analitiques_idanalitica_seq OWNED BY analitiques.idanalitica;


--
-- Name: catalegproves; Type: TABLE; Schema: public; Owner:vremar
--

CREATE TABLE catalegproves (
    idprova integer NOT NULL,
    nom_prova character varying(15) NOT NULL,
    descripcio character varying(100) NOT NULL,
    acronim character varying(15)
);


ALTER TABLE catalegproves OWNER TOvremar;

--
-- Name: doctors; Type: TABLE; Schema: public; Owner:vremar
--

CREATE TABLE doctors (
    iddoctor integer NOT NULL,
    nom character varying(15) NOT NULL,
    cognoms character varying(30) NOT NULL,
    especialitat character varying(30) NOT NULL
);


ALTER TABLE doctors OWNER TOvremar;

--
-- Name: doctors_iddoctor_seq; Type: SEQUENCE; Schema: public; Owner:vremar
--

CREATE SEQUENCE doctors_iddoctor_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE doctors_iddoctor_seq OWNER TOvremar;

--
-- Name: doctors_iddoctor_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner:vremar
--

ALTER SEQUENCE doctors_iddoctor_seq OWNED BY doctors.iddoctor;


--
-- Name: pacients; Type: TABLE; Schema: public; Owner:vremar
--

CREATE TABLE pacients (
    idpacient integer NOT NULL,
    nom character varying(15) NOT NULL,
    cognoms character varying(30) NOT NULL,
    dni character varying(9),
    data_naix date,
    sexe character varying(1),
    adreca character varying(20) NOT NULL,
    ciutat character varying(30) NOT NULL,
    c_postal character varying(10) NOT NULL,
    telefon character varying(9) NOT NULL,
    email character varying(30) NOT NULL,
    num_ss character varying(12),
    num_cat character varying(20),
    nie character varying(20),
    passaport character varying(20)
);


ALTER TABLE pacients OWNER TOvremar;

--
-- Name: pacients_idpacient_seq; Type: SEQUENCE; Schema: public; Owner:vremar
--

CREATE SEQUENCE pacients_idpacient_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE pacients_idpacient_seq OWNER TOvremar;

--
-- Name: pacients_idpacient_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner:vremar
--

ALTER SEQUENCE pacients_idpacient_seq OWNED BY pacients.idpacient;


--
-- Name: pacients_nous; Type: TABLE; Schema: public; Owner:vremar
--

CREATE TABLE pacients_nous (
    nom character varying(15) NOT NULL,
    cognoms character varying(30) NOT NULL,
    dni character varying(9),
    data_naix date NOT NULL,
    sexe character varying(1) NOT NULL,
    adreca character varying(20) NOT NULL,
    ciutat character varying(30) NOT NULL,
    c_postal character varying(10) NOT NULL,
    telefon character varying(9) NOT NULL,
    email character varying(30) NOT NULL,
    num_ss character varying(12),
    num_cat character varying(20),
    nie character varying(20),
    passaport character varying(20)
);


ALTER TABLE pacients_nous OWNER TOvremar;

--
-- Name: provestecnica; Type: TABLE; Schema: public; Owner:vremar
--

CREATE TABLE provestecnica (
    idprovatecnica integer NOT NULL,
    idprova integer,
    dataprova timestamp without time zone NOT NULL,
    resultat_numeric boolean DEFAULT true NOT NULL,
    minpat double precision,
    maxpat double precision,
    minpan double precision,
    maxpan double precision,
    alfpat character varying(10),
    sexe integer NOT NULL,
    edat_inicial integer NOT NULL,
    edat_final integer NOT NULL
);


ALTER TABLE provestecnica OWNER TOvremar;

--
-- Name: provestecnica_idprovatecnica_seq; Type: SEQUENCE; Schema: public; Owner:vremar
--

CREATE SEQUENCE provestecnica_idprovatecnica_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE provestecnica_idprovatecnica_seq OWNER TOvremar;

--
-- Name: provestecnica_idprovatecnica_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner:vremar
--

ALTER SEQUENCE provestecnica_idprovatecnica_seq OWNED BY provestecnica.idprovatecnica;


--
-- Name: resultats; Type: TABLE; Schema: public; Owner:vremar
--

CREATE TABLE resultats (
    idresultat integer NOT NULL,
    idanalitica bigint,
    idprovatecnica bigint,
    resultats character varying(10) NOT NULL,
    dataresultat timestamp without time zone NOT NULL
);


ALTER TABLE resultats OWNER TOvremar;

--
-- Name: resultats_idresultat_seq; Type: SEQUENCE; Schema: public; Owner:vremar
--

CREATE SEQUENCE resultats_idresultat_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE resultats_idresultat_seq OWNER TOvremar;

--
-- Name: resultats_idresultat_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner:vremar
--

ALTER SEQUENCE resultats_idresultat_seq OWNED BY resultats.idresultat;


--
-- Name: resultatsnous; Type: TABLE; Schema: public; Owner:vremar
--

CREATE TABLE resultatsnous (
    id_analitica bigint,
    id_provatecnica bigint,
    resultat character varying
);


ALTER TABLE resultatsnous OWNER TOvremar;

--
-- Name: idalarma; Type: DEFAULT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY alarmes ALTER COLUMN idalarma SET DEFAULT nextval('alarmes_idalarma_seq'::regclass);


--
-- Name: idanalitica; Type: DEFAULT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY analitiques ALTER COLUMN idanalitica SET DEFAULT nextval('analitiques_idanalitica_seq'::regclass);


--
-- Name: iddoctor; Type: DEFAULT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY doctors ALTER COLUMN iddoctor SET DEFAULT nextval('doctors_iddoctor_seq'::regclass);


--
-- Name: idpacient; Type: DEFAULT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY pacients ALTER COLUMN idpacient SET DEFAULT nextval('pacients_idpacient_seq'::regclass);


--
-- Name: idprovatecnica; Type: DEFAULT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY provestecnica ALTER COLUMN idprovatecnica SET DEFAULT nextval('provestecnica_idprovatecnica_seq'::regclass);


--
-- Name: idresultat; Type: DEFAULT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY resultats ALTER COLUMN idresultat SET DEFAULT nextval('resultats_idresultat_seq'::regclass);


--
-- Data for Name: alarmes; Type: TABLE DATA; Schema: public; Owner:vremar
--

COPY alarmes (idalarma, idresultat, nivellalama, validat, missatge) FROM stdin;
\.


--
-- Name: alarmes_idalarma_seq; Type: SEQUENCE SET; Schema: public; Owner:vremar
--

SELECT pg_catalog.setval('alarmes_idalarma_seq', 1, false);


--
-- Data for Name: analitiques; Type: TABLE DATA; Schema: public; Owner:vremar
--

COPY analitiques (idanalitica, iddoctor, idpacient, dataanalitica) FROM stdin;
1	1	2	2018-01-18 08:01:32.454655
2	1	1	2018-01-18 08:01:32.455504
3	2	1	2018-01-18 08:01:32.455913
4	1	1	1988-06-06 00:00:00
5	2	21	2018-01-01 00:00:00
6	3	21	2018-01-01 00:00:00
7	1	21	2018-01-01 00:00:00
8	1	23	2017-11-21 00:00:00
9	1	27	2017-11-21 00:00:00
10	3	27	2017-11-30 00:00:00
11	1	1	2018-01-02 00:00:00
12	1	1	2018-01-03 00:00:00
13	1	1	2018-01-04 00:00:00
14	1	1	2018-01-05 00:00:00
\.


--
-- Name: analitiques_idanalitica_seq; Type: SEQUENCE SET; Schema: public; Owner:vremar
--

SELECT pg_catalog.setval('analitiques_idanalitica_seq', 14, true);


--
-- Data for Name: catalegproves; Type: TABLE DATA; Schema: public; Owner:vremar
--

COPY catalegproves (idprova, nom_prova, descripcio, acronim) FROM stdin;
101	glucosa	Es una hexosa	\N
82520	COCAINA	prueba de cocaina	COAC
202	colesterol	test colesterol nivell en sangre	COL
303	SIDA	control sida	VIH
\.


--
-- Data for Name: doctors; Type: TABLE DATA; Schema: public; Owner:vremar
--

COPY doctors (iddoctor, nom, cognoms, especialitat) FROM stdin;
1	albert	marinom	cirugia
2	maria	benavent	podologia
3	renzo	remar	fisioterapia
\.


--
-- Name: doctors_iddoctor_seq; Type: SEQUENCE SET; Schema: public; Owner:vremar
--

SELECT pg_catalog.setval('doctors_iddoctor_seq', 3, true);


--
-- Data for Name: pacients; Type: TABLE DATA; Schema: public; Owner:vremar
--

COPY pacients (idpacient, nom, cognoms, dni, data_naix, sexe, adreca, ciutat, c_postal, telefon, email, num_ss, num_cat, nie, passaport) FROM stdin;
1	jose	remar silva	4811111M	1996-07-12	M	veciana 8 2 2	barcelona	08023	989856565	jose@mail.com	\N	\N	\N	\N
2	cecilia	vazques	47888855M	2007-11-12	F	tallat 27	cornella	08632	989877878	cesi@mail.com	\N	\N	x232233321l	\N
21	Alex	Joyce	27359570N	1991-11-01	M	c/Veciana 8 2 2	Barcelona	8132	692393916	11111166	555588885555	NULL	1234567898769	7879879
22	Marc	Ribas Torrevieja	58723081X	1991-11-02	M	c/Balmes 231 1 1	Barcelona	8132	692393917	11111167	555522225555	NULL	1234567898770	7879880
23	Marta	Alvarado 	57109646W	1991-11-03	F	c/Gran Via 482 E 1	Barcelona	8132	692393918	11111168	555533333555	NULL	1234567898771	7879881
24	Laura	Silva	11052235E	1991-11-04	F	c/Valencia 12 A 1	Barcelona	8666	692393919	11111169	555555555555	NULL	1234567811111	7879882
27	Anna	Puig	96494591T	1991-11-05	F	c/Mallorca 35 SA 1	Barcelona	8667	692393920	11111173	555588885556	NULL	1234567898770	7879884
\.


--
-- Name: pacients_idpacient_seq; Type: SEQUENCE SET; Schema: public; Owner:vremar
--

SELECT pg_catalog.setval('pacients_idpacient_seq', 27, true);


--
-- Data for Name: pacients_nous; Type: TABLE DATA; Schema: public; Owner:vremar
--

COPY pacients_nous (nom, cognoms, dni, data_naix, sexe, adreca, ciutat, c_postal, telefon, email, num_ss, num_cat, nie, passaport) FROM stdin;
\.


--
-- Data for Name: provestecnica; Type: TABLE DATA; Schema: public; Owner:vremar
--

COPY provestecnica (idprovatecnica, idprova, dataprova, resultat_numeric, minpat, maxpat, minpan, maxpan, alfpat, sexe, edat_inicial, edat_final) FROM stdin;
6	202	2018-02-07 09:37:53.510512	t	50	75	35	90	\N	1	0	4
2	101	2018-01-18 08:01:32.456988	t	70	90	50	110	\N	2	4	99
3	101	2017-11-01 00:00:00	t	111	150	80	170	\N	0	0	999
5	303	2018-02-01 11:24:52.629639	f	\N	\N	\N	\N	POS	0	0	999
8	303	2018-02-07 09:47:28.103917	f	\N	\N	\N	\N	NEG	0	0	999
7	202	2018-02-07 09:38:51.512237	t	80	110	75	120	\N	2	4	99
9	101	2018-02-17 10:32:13.964535	t	90	115	65	130		2	1	4
1	101	2018-02-17 11:35:37.422756	t	77	99	55	101		1	4	99
1	101	2018-02-17 11:35:53.510736	t	77	99	55	101		0	0	999
6	101	2018-02-17 11:37:22.189084	t	33	66	22	77		0	0	999
1	101	2018-02-17 11:38:23.403369	t	111	168	99	180		2	4	99
1	101	2018-01-18 08:01:32.456359	t	80	100	60	150	\N	1	0	1
1	101	2018-02-17 11:38:53.067475	t	122	177	100	200		2	0	1
1	101	2018-02-17 11:42:13.080467	t	67	77	50	90		1	1	4
1	101	2018-02-17 11:42:36.888897	t	83	97	61	101		2	1	4
\.


--
-- Name: provestecnica_idprovatecnica_seq; Type: SEQUENCE SET; Schema: public; Owner:vremar
--

SELECT pg_catalog.setval('provestecnica_idprovatecnica_seq', 9, true);


--
-- Data for Name: resultats; Type: TABLE DATA; Schema: public; Owner:vremar
--

COPY resultats (idresultat, idanalitica, idprovatecnica, resultats, dataresultat) FROM stdin;
2	1	2	80	2018-01-25 11:37:08.298143
4	2	1	75	2018-02-07 09:49:47.244627
5	2	3	25	2018-02-07 09:50:27.805407
6	6	5	POS	2018-02-08 10:12:22.279139
14	8	1	100	2018-02-08 11:17:57.27852
15	8	5	99	2018-02-08 11:17:57.27852
7	7	8	POS	2018-02-08 11:17:57.27852
1	1	1	75	2018-02-08 11:17:57.27852
18	11	3	90	2018-02-12 12:06:34.140309
20	13	1	34	2018-02-12 12:06:55.259746
21	14	1	125	2018-02-12 12:07:03.156021
19	12	3	112	2018-02-12 12:06:42.124315
22	11	6	50	2018-02-14 14:43:07.607756
23	11	7	150	2018-02-14 14:43:24.223375
24	12	7	117	2018-02-14 14:43:34.223156
25	12	6	17	2018-02-14 14:43:56.09782
26	1	6	27	2018-02-14 14:44:06.926983
27	1	7	88	2018-02-14 14:44:17.12673
\.


--
-- Name: resultats_idresultat_seq; Type: SEQUENCE SET; Schema: public; Owner:vremar
--

SELECT pg_catalog.setval('resultats_idresultat_seq', 27, true);


--
-- Data for Name: resultatsnous; Type: TABLE DATA; Schema: public; Owner:vremar
--

COPY resultatsnous (id_analitica, id_provatecnica, resultat) FROM stdin;
\.


--
-- Name: alarmes_pkey; Type: CONSTRAINT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY alarmes
    ADD CONSTRAINT alarmes_pkey PRIMARY KEY (idalarma);


--
-- Name: analitiques_pkey; Type: CONSTRAINT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY analitiques
    ADD CONSTRAINT analitiques_pkey PRIMARY KEY (idanalitica);


--
-- Name: catalegproves_pkey; Type: CONSTRAINT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY catalegproves
    ADD CONSTRAINT catalegproves_pkey PRIMARY KEY (idprova);


--
-- Name: doctors_pkey; Type: CONSTRAINT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY doctors
    ADD CONSTRAINT doctors_pkey PRIMARY KEY (iddoctor);


--
-- Name: pacients_pkey; Type: CONSTRAINT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY pacients
    ADD CONSTRAINT pacients_pkey PRIMARY KEY (idpacient);


--
-- Name: provestecnica_pkey; Type: CONSTRAINT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY provestecnica
    ADD CONSTRAINT provestecnica_pkey PRIMARY KEY (idprovatecnica, sexe, edat_inicial, edat_final);


--
-- Name: resultats_idanalitica_idprovatecnica_key; Type: CONSTRAINT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY resultats
    ADD CONSTRAINT resultats_idanalitica_idprovatecnica_key UNIQUE (idanalitica, idprovatecnica);


--
-- Name: resultats_pkey; Type: CONSTRAINT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY resultats
    ADD CONSTRAINT resultats_pkey PRIMARY KEY (idresultat);


--
-- Name: fk_idanalitica; Type: FK CONSTRAINT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY resultats
    ADD CONSTRAINT fk_idanalitica FOREIGN KEY (idanalitica) REFERENCES analitiques(idanalitica) ON UPDATE CASCADE;


--
-- Name: fk_iddoctor; Type: FK CONSTRAINT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY analitiques
    ADD CONSTRAINT fk_iddoctor FOREIGN KEY (iddoctor) REFERENCES doctors(iddoctor) ON UPDATE CASCADE;


--
-- Name: fk_idpacient; Type: FK CONSTRAINT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY analitiques
    ADD CONSTRAINT fk_idpacient FOREIGN KEY (idpacient) REFERENCES pacients(idpacient) ON UPDATE CASCADE;


--
-- Name: fk_idprova; Type: FK CONSTRAINT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY provestecnica
    ADD CONSTRAINT fk_idprova FOREIGN KEY (idprova) REFERENCES catalegproves(idprova) ON UPDATE CASCADE;


--
-- Name: fk_idresultat; Type: FK CONSTRAINT; Schema: public; Owner:vremar
--

ALTER TABLE ONLY alarmes
    ADD CONSTRAINT fk_idresultat FOREIGN KEY (idresultat) REFERENCES resultats(idresultat) ON UPDATE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

