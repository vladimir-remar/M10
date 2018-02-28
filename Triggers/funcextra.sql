/*Conti quantes proves protem durant el dia
*/
CREATE OR REPLACE FUNCTION count_provas()
RETURNS text
AS
$$
DECLARE
  ret varchar :='';
BEGIN
RETURN ret;
EXCEPTION 
  WHEN unique_violation THEN return '-1'; 
  WHEN foreign_key_violation THEN return '-2'; 
  WHEN not_null_violation THEN return '-3';
  --WHEN others THEN return '-4'; 
END;
$$
language 'plpgsql' volatile;
