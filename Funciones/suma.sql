/* EXEMPLE 1:funcion suma */
CREATE OR REPLACE FUNCTION SUMAR1 (INTEGER) 
RETURNS INTEGER 
AS  $$
BEGIN
	RETURN $1 + 1;
END;
$$ LANGUAGE plpgsql;

/* EXEMPPLE 2: multiplicacion, return integer*/
CREATE OR REPLACE FUNCTION exemple(integer, integer) 
RETURNS integer 
AS $$
DECLARE
 numero1 ALIAS FOR $1;
 numero2 ALIAS FOR $2;

 constante CONSTANT integer := 100;
 resultado integer;

BEGIN
 resultado := (numero1 * numero2) + constante;
 RETURN resultado;
END;
$$ LANGUAGE plpgsql;

/* EXEMPLE 3: return text*/
CREATE OR REPLACE FUNCTION exemple_txt(integer, integer) 
RETURNS text 
AS $$
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
$$ LANGUAGE plpgsql;

/* */
CREATE OR REPLACE FUNCTION pri_sel(id_cli integer)
RETURNS text AS
$$
DECLARE
    result text := '';
    searchsql text := '';
    var_match record;
BEGIN
     searchsql := 'SELECT * FROM clientes WHERE num_clie = ' || $1;      
     FOR var_match IN EXECUTE(searchsql) LOOP
          IF result > '' THEN
              result := result || ';' || var_match.num_clie || '= ' || var_match;
          ELSE
              result := var_match.num_clie || '= ' ||var_match;
         END IF;
    END LOOP;
    IF result = '' THEN
	result := 'Dades inexistents';
    END IF;
    RETURN searchsql || ': ' || result;
EXCEPTION 
    WHEN others THEN return '5';
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;
