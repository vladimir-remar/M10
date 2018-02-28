/*Conti quantes proves portem durant el dia
*/
CREATE OR REPLACE FUNCTION count_provas()
RETURNS text
AS
$$
DECLARE
  ret varchar :='';
  sql1 text;
  today varchar;
  data_ini timestamp;
  data_fi timestamp;
  rec record;
BEGIN
  today := to_char(current_timestamp,'YYYY-MM-DD');
  data_ini := to_timestamp(today,'YYYY-MM-DD');
  data_fi := current_timestamp;
  
  -- select count(idresultat) from resultats where dataresultat between '2018-02-28 00:00:00' and '2018-02-28 15:18:27.005648';
  -- select count(resultats.idresultat) from resultats  join analitiques on resultats.idanalitica=analitiques.idanalitica and analitiques.dataanalitica between '2018-02-28 00:00:00' and '2018-02-28 15:18:27.005648'
  -- sql1:= 'select count(idresultat) from resultats where dataresultat between '''||data_ini||''' and '''||data_fi||''';';
  
  sql1 := 'select count(resultats.idprovatecnica) from resultats join analitiques on resultats.idanalitica=analitiques.idanalitica and analitiques.dataanalitica between '''||data_ini||''' and '''||data_fi||''';';
  EXECUTE(sql1) INTO ret;
  
RETURN ret;
EXCEPTION 
  WHEN unique_violation THEN return '-1'; 
  WHEN foreign_key_violation THEN return '-2'; 
  WHEN not_null_violation THEN return '-3';
  --WHEN others THEN return '-4'; 
END;
$$
language 'plpgsql' volatile;
