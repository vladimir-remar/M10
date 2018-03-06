/* FUNCION EXAMEN
-- 1 ->  NORMAL 
-- 2 ->  PATOLÒGIC
-- 3 ->  PÀNIC
*/
CREATE OR REPLACE FUNCTION estudi_proves(
idprova1 bigint,
idprova2 bigint,
idprova3 bigint,
idprova4 bigint
)
RETURNS text
AS
$$
DECLARE
  sql1 text;
  sql2 text;
  rec record;
  rec2 record;
  hi_son varchar;
  trobat boolean;
  ret varchar:='';
  analitica int :=0;
  cont int :=0;
  ok1 boolean :=False;
  ok2 boolean :=False;
  ok3 boolean :=False;
  valoracio varchar := '';
  acronim1 varchar := '';
  acronim2 varchar := '';
  acronim3 varchar := '';
  acronim4 varchar := '';
  r1 varchar :='';
  r2 varchar :='';
  r3 varchar :='';
  r4 varchar :='';
BEGIN
  --select * from catalegproves idprova = 901 or idprova = 202 or idprova = 902 or idprova = 101;
  sql1 := 'select count(idprova) from catalegproves where idprova = '||idprova1||' or idprova = '||idprova2||' or idprova = '||idprova3||' or idprova = '||idprova4||';';
  --raise notice '%',sql1;
  for rec in execute(sql1) LOOP
    hi_son:= rec.count;
  end loop;
  --raise notice '%',hi_son;
  IF hi_son != '4' THEN
    return '-5';
  END IF;
  --select distinct resultats.idanalitica,provestecnica.idprova,resultats.resultats,analitiques.dataanalitica from analitiques join resultats on analitiques.idanalitica=resultats.idanalitica join provestecnica on resultats.idprovatecnica=provestecnica.idprovatecnica group by resultats.idanalitica,provestecnica,idprova,resultats.resultats,analitiques.dataanalitica order by idanalitica asc;
  --select bueno
  /*select distinct resultats.idanalitica,provestecnica.idprova,resultats.resultats,analitiques.dataanalitica,resultats.idresultat,catalegproves.acronim from analitiques join resultats on analitiques.idanalitica=resultats.idanalitica join provestecnica on resultats.idprovatecnica=provestecnica.idprovatecnica join catalegproves on provestecnica.idprova = catalegproves.idprova 
  and provestecnica.idprova in (select idprova from provestecnica where idprova = 901 or idprova = 902 or idprova = 903 or idprova =904 ) order by idanalitica asc;
  */
  sql1 := 'select distinct resultats.idanalitica,provestecnica.idprova,resultats.resultats,analitiques.dataanalitica,resultats.idresultat,catalegproves.acronim from analitiques join resultats on analitiques.idanalitica=resultats.idanalitica join provestecnica on resultats.idprovatecnica=provestecnica.idprovatecnica join catalegproves on provestecnica.idprova = catalegproves.idprova and provestecnica.idprova in (select idprova from provestecnica where idprova = '||idprova1||' or idprova = '||idprova2||' or idprova = '||idprova3||' or idprova ='||idprova4||' ) order by idanalitica asc;';
  FOR rec in execute(sql1) LOOP
    IF analitica != rec.idanalitica THEN
      analitica := rec.idanalitica;
      ret := ret || to_char(rec.dataanalitica,'YYYY-MM-DD')||'  -  '||analitica|| e' \n';
    END IF;
    valoracio := valorar_idresultat(rec.idresultat);
    IF valoracio IN ('2','3') THEN
      ret := ret ||
    END IF;
  END LOOP;
RETURN ret;
--RETURN 'ok';
EXCEPTION 
  WHEN unique_violation THEN return '-1'; 
  WHEN foreign_key_violation THEN return '-2'; 
  WHEN not_null_violation THEN return '-3';
  --WHEN others THEN return '-4'; 
END;
$$
language 'plpgsql' volatile;

--######################################################################
-- #####################################################################
-- FUNCIONES UTILIZADAS
-- #####################################################################
-- Funcio valors ref
CREATE OR REPLACE FUNCTION determina_resultat(
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
      sql2 := 'select to_char(age('''||fecha_analitica||''','''||rec.data_naix||'''), '''||'YY'||''');';
      --sql2 := 'select to_char(age(timestamp '''||rec.data_naix||'''), '''||'YY'||''');';
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
$$
language 'plpgsql' volatile;
-- =====================================================================

CREATE OR REPLACE FUNCTION valorar_idresultat(id_resultat bigint)
RETURNS text
AS
$$
DECLARE
	sql1 text;
	ret varchar :='';
	id_provatecnica bigint;
	id_analitica bigint;
	id_pacient bigint;
	res varchar;
	rec record;
  data_analitica timestamp;
	trobat boolean :=false;
BEGIN
	sql1 := 'SELECT * FROM  resultats WHERE idresultat = ' || id_resultat || ';';
	
	trobat := false;
	FOR rec IN EXECUTE(sql1) LOOP
		trobat          := true;
		id_provatecnica := rec.idprovatecnica;
		id_analitica    := rec.idanalitica;
    res := rec.resultats;
	END LOOP;
	
	IF NOT trobat THEN
		return '-5';
	END IF;	
	
	sql1 := 'SELECT * FROM analitiques WHERE idanalitica = ' || id_analitica || ';';
	
	trobat := False;	
	FOR rec IN EXECUTE(sql1) LOOP
		trobat := True;
		id_pacient := rec.idpacient;
    data_analitica := rec.dataanalitica;
	END LOOP;
	
	IF NOT trobat THEN
		return '-6';
	END IF;
	
	ret := determina_resultat(id_provatecnica,id_pacient,res,data_analitica);
	
RETURN ret;
	
EXCEPTION 
	WHEN unique_violation THEN return '-1'; 
	WHEN foreign_key_violation THEN return '-2'; 
	WHEN not_null_violation THEN return '-3';
	--WHEN others THEN return '-4'; 
END;
$$
language 'plpgsql' volatile;
--######################################################################
-- RESULTATS
/*
select * from catalegproves;
 idprova | nom_prova  |            descripcio            | acronim 
---------+------------+----------------------------------+---------
     101 | glucosa    | Es una hexosa                    | 
   82520 | COCAINA    | prueba de cocaina                | COAC
     202 | colesterol | test colesterol nivell en sangre | COL
     303 | SIDA       | control sida                     | VIH
     901 | ALT_1      | ALT_1_Grup_ALTs                  | ALT1
     902 | ALT_2      | ALT_2_Grup_ALTs                  | ALT2
     903 | ALT_3      | ALT_3_Grup_ALTs                  | ALT3
     904 | ALT_4      | ALT_4_Grup_ALTs                  | ALT4
     905 | ALT_5      | ALT_5_Grup_ALTs                  | ALT5
     906 | ALT_6      | ALT_6_Grup_ALTs                  | ALT6
     907 | ALT_7      | ALT_7_Grup_ALTs                  | ALT7
     908 | ALT_8      | ALT_8_Grup_ALTs                  | ALT8
     909 | ALT_9      | ALT_9_Grup_ALTs                  | ALT9
     910 | ALT_10     | ALT_10_Grup_ALTs                 | ALT20

select * from provestecnica;
 idprovatecnica | idprova |         dataprova          | resultat_numeric | minpat | maxpat | minpan | maxpan | alfpat | sexe | edat_inicial | edat_final 
----------------+---------+----------------------------+------------------+--------+--------+--------+--------+--------+------+--------------+------------
              6 |     202 | 2018-02-07 09:37:53.510512 | t                |     50 |     75 |     35 |     90 |        |    1 |            0 |          4
              2 |     101 | 2018-01-18 08:01:32.456988 | t                |     70 |     90 |     50 |    110 |        |    2 |            4 |         99
              3 |     101 | 2017-11-01 00:00:00        | t                |    111 |    150 |     80 |    170 |        |    0 |            0 |        999
              5 |     303 | 2018-02-01 11:24:52.629639 | f                |        |        |        |        | POS    |    0 |            0 |        999
              8 |     303 | 2018-02-07 09:47:28.103917 | f                |        |        |        |        | NEG    |    0 |            0 |        999
              7 |     202 | 2018-02-07 09:38:51.512237 | t                |     80 |    110 |     75 |    120 |        |    2 |            4 |         99
              9 |     101 | 2018-02-17 10:32:13.964535 | t                |     90 |    115 |     65 |    130 |        |    2 |            1 |          4
              1 |     101 | 2018-02-17 11:35:37.422756 | t                |     77 |     99 |     55 |    101 |        |    1 |            4 |         99
              1 |     101 | 2018-02-17 11:35:53.510736 | t                |     77 |     99 |     55 |    101 |        |    0 |            0 |        999
              6 |     101 | 2018-02-17 11:37:22.189084 | t                |     33 |     66 |     22 |     77 |        |    0 |            0 |        999
              1 |     101 | 2018-02-17 11:38:23.403369 | t                |    111 |    168 |     99 |    180 |        |    2 |            4 |         99
              1 |     101 | 2018-01-18 08:01:32.456359 | t                |     80 |    100 |     60 |    150 |        |    1 |            0 |          1
              1 |     101 | 2018-02-17 11:38:53.067475 | t                |    122 |    177 |    100 |    200 |        |    2 |            0 |          1
              1 |     101 | 2018-02-17 11:42:13.080467 | t                |     67 |     77 |     50 |     90 |        |    1 |            1 |          4
              1 |     101 | 2018-02-17 11:42:36.888897 | t                |     83 |     97 |     61 |    101 |        |    2 |            1 |          4
          90101 |     901 | 2018-02-28 09:40:13.916961 | t                |     80 |    100 |     60 |    150 |        |    0 |            0 |        999
          90201 |     902 | 2018-02-28 09:40:13.927229 | t                |     80 |    100 |     60 |    150 |        |    0 |            0 |        999
          90301 |     903 | 2018-02-28 09:40:13.930659 | t                |     80 |    100 |     60 |    150 |        |    0 |            0 |        999
          90401 |     904 | 2018-02-28 09:40:13.934397 | t                |     80 |    100 |     60 |    150 |        |    0 |            0 |        999
          90501 |     905 | 2018-02-28 09:40:13.9385   | t                |     80 |    100 |     60 |    150 |        |    0 |            0 |        999
          90601 |     906 | 2018-02-28 09:40:13.943741 | t                |     80 |    100 |     60 |    150 |        |    0 |            0 |        999
          90701 |     907 | 2018-02-28 09:40:13.9492   | t                |     80 |    100 |     60 |    150 |        |    0 |            0 |        999
          90801 |     908 | 2018-02-28 09:40:13.954108 | t                |     80 |    100 |     60 |    150 |        |    0 |            0 |        999
          90901 |     909 | 2018-02-28 09:40:13.958035 | t                |     80 |    100 |     60 |    150 |        |    0 |            0 |        999
          91001 |     910 | 2018-02-28 09:40:13.961209 | t                |     80 |    100 |     60 |    150 |        |    1 |            0 |        999
          91001 |     910 | 2018-02-28 09:40:13.963949 | t                |     80 |    100 |     60 |    150 |        |    2 |            1 |         10
          91001 |     910 | 2018-02-28 09:40:21.644085 | t                |     80 |    100 |     60 |    150 |        |    2 |           11 |        999

select * from resultats;
idresultat | idanalitica | idprovatecnica | resultats |        dataresultat        
------------+-------------+----------------+-----------+----------------------------
        146 |        5001 |          90101 | 85        | 2018-02-28 09:46:48.680194
        147 |        5001 |          90201 | 85        | 2018-02-28 09:46:48.692145
        148 |        5001 |          90301 | 85        | 2018-02-28 09:46:48.694404
        149 |        5001 |          90401 | 85        | 2018-02-28 09:46:48.696619
        150 |        5001 |          90501 | 85        | 2018-02-28 09:46:48.698684
        151 |        5001 |          90601 | 85        | 2018-02-28 09:46:48.700702
        152 |        5001 |          90701 | 85        | 2018-02-28 09:46:48.702682
        153 |        5001 |          90801 | 85        | 2018-02-28 09:46:48.704613
        154 |        5001 |          90901 | 85        | 2018-02-28 09:46:48.706388
        155 |        5001 |          91001 | 85        | 2018-02-28 09:46:48.708363
        156 |        5002 |          90101 | 95        | 2018-02-28 09:46:48.71036
        157 |        5002 |          90201 | 95        | 2018-02-28 09:46:48.712337
        158 |        5002 |          90301 | 95        | 2018-02-28 09:46:48.714312
        159 |        5002 |          90401 | 95        | 2018-02-28 09:46:48.716285
        160 |        5002 |          90501 | 95        | 2018-02-28 09:46:48.718255
        161 |        5002 |          90601 | 95        | 2018-02-28 09:46:48.720225
        162 |        5002 |          90701 | 95        | 2018-02-28 09:46:48.722193
        163 |        5002 |          90801 | 95        | 2018-02-28 09:46:48.724177
        164 |        5002 |          90901 | 95        | 2018-02-28 09:46:48.72741
        165 |        5002 |          91001 | 95        | 2018-02-28 09:46:48.730543
        166 |        5003 |          90101 | 105       | 2018-02-28 09:46:48.733389
        167 |        5003 |          90201 | 105       | 2018-02-28 09:46:48.736179
        168 |        5003 |          90301 | 105       | 2018-02-28 09:46:48.739088
        169 |        5003 |          90401 | 105       | 2018-02-28 09:46:48.742013
        170 |        5003 |          90501 | 105       | 2018-02-28 09:46:48.744778
        171 |        5003 |          90601 | 105       | 2018-02-28 09:46:48.747544
        172 |        5003 |          90701 | 105       | 2018-02-28 09:46:48.74971
        173 |        5003 |          90801 | 105       | 2018-02-28 09:46:48.751744
        174 |        5003 |          90901 | 105       | 2018-02-28 09:46:48.753633
        175 |        5003 |          91001 | 105       | 2018-02-28 09:46:48.755597
        176 |        5004 |          90101 | 115       | 2018-02-28 09:46:48.758111
        177 |        5004 |          90201 | 115       | 2018-02-28 09:46:48.760271
        178 |        5004 |          90301 | 115       | 2018-02-28 09:46:48.762116
        179 |        5004 |          90401 | 115       | 2018-02-28 09:46:48.76458
        180 |        5004 |          90501 | 115       | 2018-02-28 09:46:48.766785
        181 |        5004 |          90601 | 115       | 2018-02-28 09:46:48.768814
        182 |        5004 |          90701 | 115       | 2018-02-28 09:46:48.770821
        183 |        5004 |          90801 | 115       | 2018-02-28 09:46:48.772794
        184 |        5004 |          90901 | 115       | 2018-02-28 09:46:48.774764
        185 |        5004 |          91001 | 115       | 2018-02-28 09:46:48.776608
        186 |        5005 |          90101 | 125       | 2018-02-28 09:46:48.7786
        187 |        5005 |          90201 | 125       | 2018-02-28 09:46:48.780509
        188 |        5005 |          90301 | 125       | 2018-02-28 09:46:48.782691
        189 |        5005 |          90401 | 125       | 2018-02-28 09:46:48.785354
        190 |        5005 |          90501 | 125       | 2018-02-28 09:46:48.787321
        191 |        5005 |          90601 | 125       | 2018-02-28 09:46:48.789771
        192 |        5005 |          90701 | 125       | 2018-02-28 09:46:48.791827
        193 |        5005 |          90801 | 125       | 2018-02-28 09:46:48.79376
        194 |        5005 |          90901 | 125       | 2018-02-28 09:46:48.795665
        195 |        5005 |          91001 | 125       | 2018-02-28 09:46:48.797635
        196 |        5006 |          90101 | 135       | 2018-02-28 09:46:48.799536
        197 |        5006 |          90201 | 135       | 2018-02-28 09:46:48.801462
        198 |        5006 |          90301 | 135       | 2018-02-28 09:46:48.803383
        199 |        5006 |          90401 | 135       | 2018-02-28 09:46:48.805383
        200 |        5006 |          90501 | 135       | 2018-02-28 09:46:48.807468
        201 |        5006 |          90601 | 135       | 2018-02-28 09:46:48.809433
        202 |        5006 |          90701 | 135       | 2018-02-28 09:46:48.811363
        203 |        5006 |          90801 | 135       | 2018-02-28 09:46:48.813329
        204 |        5006 |          90901 | 135       | 2018-02-28 09:46:48.815217
        205 |        5006 |          91001 | 135       | 2018-02-28 09:46:48.81708
        206 |        5007 |          90101 | 145       | 2018-02-28 09:46:48.819539
        207 |        5007 |          90201 | 145       | 2018-02-28 09:46:48.822136
        208 |        5007 |          90301 | 145       | 2018-02-28 09:46:48.824492
        209 |        5007 |          90401 | 145       | 2018-02-28 09:46:48.826422
        210 |        5007 |          90501 | 145       | 2018-02-28 09:46:48.828305
        211 |        5007 |          90601 | 145       | 2018-02-28 09:46:48.830094
        212 |        5007 |          90701 | 145       | 2018-02-28 09:46:48.831913
        213 |        5007 |          90801 | 145       | 2018-02-28 09:46:48.83376
        214 |        5007 |          90901 | 145       | 2018-02-28 09:46:48.83567
        215 |        5007 |          91001 | 145       | 2018-02-28 09:46:48.837615
        216 |        5008 |          90101 | 155       | 2018-02-28 09:46:48.839517
        217 |        5008 |          90201 | 155       | 2018-02-28 09:46:48.841447
        218 |        5008 |          90301 | 155       | 2018-02-28 09:46:48.843366
        219 |        5008 |          90401 | 155       | 2018-02-28 09:46:48.845271
        220 |        5008 |          90501 | 155       | 2018-02-28 09:46:48.847168
        221 |        5008 |          90601 | 155       | 2018-02-28 09:46:48.849073
        222 |        5008 |          90701 | 155       | 2018-02-28 09:46:48.851114
        223 |        5008 |          90801 | 155       | 2018-02-28 09:46:48.853561
        224 |        5008 |          90901 | 155       | 2018-02-28 09:46:48.856079
        225 |        5008 |          91001 | 155       | 2018-02-28 09:46:48.859068
        226 |        5009 |          90101 | 165       | 2018-02-28 09:46:48.861893
        227 |        5009 |          90201 | 165       | 2018-02-28 09:46:48.86455
        228 |        5009 |          90301 | 165       | 2018-02-28 09:46:48.866313
        229 |        5009 |          90401 | 165       | 2018-02-28 09:46:48.868274
        230 |        5009 |          90501 | 165       | 2018-02-28 09:46:48.870173
        231 |        5009 |          90601 | 165       | 2018-02-28 09:46:48.872153
        232 |        5009 |          90701 | 165       | 2018-02-28 09:46:48.874061
        233 |        5009 |          90801 | 165       | 2018-02-28 09:46:48.875974
        234 |        5009 |          90901 | 165       | 2018-02-28 09:46:48.877852
        235 |        5009 |          91001 | 165       | 2018-02-28 09:46:48.87975
        236 |        5010 |          90101 | 175       | 2018-02-28 09:46:48.881639
        237 |        5010 |          90201 | 175       | 2018-02-28 09:46:48.885561
        238 |        5010 |          90301 | 175       | 2018-02-28 09:46:48.8876
        239 |        5010 |          90401 | 175       | 2018-02-28 09:46:48.88999
        240 |        5010 |          90501 | 175       | 2018-02-28 09:46:48.892055
        241 |        5010 |          90601 | 175       | 2018-02-28 09:46:48.893882
        242 |        5010 |          90701 | 175       | 2018-02-28 09:46:48.89576
        243 |        5010 |          90801 | 175       | 2018-02-28 09:46:48.897601
        244 |        5010 |          90901 | 175       | 2018-02-28 09:46:48.899471
        245 |        5010 |          91001 | 175       | 2018-02-28 09:46:48.901449
        246 |        5011 |          90101 | 185       | 2018-02-28 09:46:48.903312
        247 |        5011 |          90201 | 185       | 2018-02-28 09:46:48.905215
        248 |        5011 |          90301 | 185       | 2018-02-28 09:46:48.907118
        249 |        5011 |          90401 | 185       | 2018-02-28 09:46:48.908997
        250 |        5011 |          90501 | 185       | 2018-02-28 09:46:48.91091
        251 |        5011 |          90601 | 185       | 2018-02-28 09:46:48.912785
        252 |        5011 |          90701 | 185       | 2018-02-28 09:46:48.91518
        253 |        5011 |          90801 | 185       | 2018-02-28 09:46:48.917736
        254 |        5011 |          90901 | 185       | 2018-02-28 09:46:48.919655
        255 |        5011 |          91001 | 185       | 2018-02-28 09:46:50.536555
select estudi_proves(901,902,903,904);
             estudi_proves             
---------------------------------------
 2018-02-28  -  5003                  +
                         901-ALT1-105 +
                         902-ALT2-105 +
                         903-ALT3-105 +
                         904-ALT4-105 +
 2018-02-28  -  5004                  +
                         901-ALT1-115 +
                         902-ALT2-115 +
                         903-ALT3-115 +
                         904-ALT4-115 +
 2018-02-28  -  5005                  +
                         901-ALT1-125 +
                         902-ALT2-125 +
                         903-ALT3-125 +
                         904-ALT4-125 +
 2018-02-28  -  5006                  +
                         901-ALT1-135 +
                         902-ALT2-135 +
                         903-ALT3-135 +
                         904-ALT4-135 +
 2018-02-28  -  5007                  +
                         901-ALT1-145 +
                         902-ALT2-145 +
                         903-ALT3-145 +
                         904-ALT4-145 +
 2018-02-28  -  5008                  +
                         901-ALT1-155 +
                         902-ALT2-155 +
                         903-ALT3-155 +
                         904-ALT4-155 +
 2018-02-28  -  5009                  +
                         901-ALT1-165 +
                         902-ALT2-165 +
                         903-ALT3-165 +
                         904-ALT4-165 +
 2018-02-28  -  5010                  +
                         901-ALT1-175 +
                         902-ALT2-175 +
                         903-ALT3-175 +
                         904-ALT4-175 +
 2018-02-28  -  5011                  +
                         901-ALT1-185 +
                         902-ALT2-185 +
                         903-ALT3-185 +
                         904-ALT4-185 +

*/
