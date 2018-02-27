CREATE OR REPLACE FUNCTION insert_analitiques( 
iddoctor bigint,
idpacient bigint,
fecha date default null)
RETURNS text
AS
$$
DECLARE
	sql1 text;
BEGIN
  if fecha is NULL THEN
    fecha :=to_char(current_timestamp,'YYYY-MM-DD');
  END IF;
	sql1 := 'INSERT INTO analitiques VALUES (default,'|| $1 ||','|| $2 ||','''|| fecha|| ''');';
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
