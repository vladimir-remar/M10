/*
Escriure un procediment emmagatzemat  que rebi les dades d'un pacient i 
l'inserti a la taula de pacients. Si hi ha algun error a l'insertar l'ha 
de visualitzar. Si no hi ha cap error ha de dir 'Pacient Insertat Correctament'.

S'han de controlar els següents errors retornant un text explicatiu de cada error:
1) clau principal duplicada
2) clau única duplicada
3) clau forana inexistent

*/
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
/* FUNCION VALIDAR DNI */
CREATE OR REPLACE FUNCTION dni_correct(dni varchar)
RETURNS text AS
$$
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
$$
LANGUAGE 'plpgsql' IMMUTABLE;
/*+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
--Funcion que comprueba el valor de un campo de un paciente
CREATE OR REPLACE FUNCTION comproba_pacient(camp varchar,valor varchar)
RETURNS text AS
$$
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

$$
LANGUAGE 'plpgsql' IMMUTABLE;

/* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

CREATE OR REPLACE FUNCTION insert_pacients(
nom varchar(15),
cognoms varchar(30),
dni varchar(9),
data_naix varchar,
sexe varchar(1) ,
adreca varchar(20),
ciutat varchar(30), 
c_postal varchar(10),
telefon varchar(9),
email varchar(30),
num_ss varchar(12) default '',
num_cat varchar(20) default '',
nie varchar(20) default '',
passaport varchar (20) default '')
 
RETURNS text AS
$$
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
$$
LANGUAGE 'plpgsql' VOLATILE;
