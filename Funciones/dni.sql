CREATE OR REPLACE FUNCTION dni_correct(dni varchar)
RETURNS text AS
$$
DECLARE

 	ret varchar := '1';
 	partnum numeric(8);
 	lletras varchar := 'TRWAGMYFPDXBNJZSQVHLCKE';
 	modul int;
 	lletraresultat varchar(1);
 	lletradni varchar(1);
BEGIN
 	IF char_length(dni) != 9 THEN
		 ret := 'LONGITUD INCORRECTA';
	ELSE
 		partnum = substr (dni, 1, 8);
 		modul := cast (partnum as int) % 23;
 		
 		lletraresultat := substring(lletras from modul + 1  for 1);
		lletradni := right(dni,1);

		IF lletraresultat <>  lletradni THEN
			ret := 'LETRA DNI INCORRECTA';
		END IF;
		
	END IF;
RETURN ret;
EXCEPTION WHEN others THEN
	RETURN '2';
END;
$$
LANGUAGE 'plpgsql' IMMUTABLE;
