ALTER TABLE provestecnica
  DROP COLUMN sexe,
  ADD COLUMN sexe int,
  ADD COLUMN edat_inicial int,
  ADD COLUMN edat_final int,
  ADD primary key(idprovatecnia,sexe,edat_inicia ,edat_fina);

insert into provestecnica values(1,101,current_timestamp,'t',77,99,55,101,'',1,4,99);
insert into provestecnica values(1,101,current_timestamp,'t',77,99,55,101,'',0,0,999);

update provestecnica SET edat_inicial =0, edat_final=4 where idprovatecnica=1;

update provestecnica SET edat_inicial =0, edat_final=4 where idprovatecnica=6;

update provestecnica SET edat_inicial =4, edat_final=99 where idprovatecnica=2;

update provestecnica SET edat_inicial =0, edat_final=999 where idprovatecnica=3;

update provestecnica SET edat_inicial =0, edat_final=999 where idprovatecnica=5;

update provestecnica SET edat_inicial =0, edat_final=999 where idprovatecnica=8;


update provestecnica set sexe = 1 where idprovatecnica=1;

update provestecnica set sexe = 2 where idprovatecnica=2;

update provestecnica set sexe = 0 where idprovatecnica=3;

update provestecnica set sexe = 0 where idprovatecnica=5;

update provestecnica set sexe = 0 where idprovatecnica=8;

update provestecnica set sexe = 1 where idprovatecnica=6;

update provestecnica set sexe = 2 where idprovatecnica=7;
 alter table resultats drop  constraint fk_idprovatecnica;
alter table provestecnica drop constraint provestecnica_pkey;
