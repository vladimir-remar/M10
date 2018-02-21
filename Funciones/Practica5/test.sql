-- =====================================================================
CREATE OR REPLACE FUNCTION test(
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
  edat int;
BEGIN
  sql1 := 'SELECT * FROM pacients WHERE idpacient = ' || idpacient || ';';
  FOR rec IN EXECUTE(sql1) LOOP
    IF rec.data_naix is NULL OR rec.sexe is NULL THEN
      return '2';
    ELSE
      sql2 := 'select to_char(age('''||fecha_analitica||''', '''||rec.data_naix||'''), '''||'YY'||''');';
      EXECUTE (sql2) INTO edat;
      raise notice '%',edat;
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
