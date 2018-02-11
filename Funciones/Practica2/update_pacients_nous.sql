CREATE OR REPLACE FUNCTION update_nous(
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
	WHEN others THEN return '-4'; 
END;
$$
language 'plpgsql' volatile;

	
