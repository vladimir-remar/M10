CREATE OR REPLACE FUNCTION nous_pacients()
RETURNS text AS
$$
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
$$
language 'plpgsql' volatile;

--res:=res|| E'\n';
