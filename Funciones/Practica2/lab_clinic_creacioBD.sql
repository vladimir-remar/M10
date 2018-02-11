DROP DATABASE lab_clinic;
CREATE DATABASE lab_clinic;
\c lab_clinic;

CREATE TABLE pacients (
  idpacient serial PRIMARY KEY,
  nom varchar(15) NOT NULL,
  cognoms varchar(30) NOT NULL,
  dni varchar(9),
  data_naix date NOT NULL,
  sexe varchar(1) NOT NULL,
  adreca varchar(20) NOT NULL,
  ciutat varchar(30) NOT NULL,
  c_postal varchar(10) NOT NULL,
  telefon varchar(9) NOT NULL,
  email varchar(30) NOT NULL,
  num_ss varchar(12) ,
  num_cat varchar(20) ,
  nie varchar(20),
  passaport varchar(20) 
);

CREATE TABLE doctors (
  iddoctor serial PRIMARY KEY,
  nom varchar(15) NOT NULL,
  cognoms varchar(30) NOT NULL,
  especialitat varchar(30) NOT NULL
);

CREATE TABLE analitiques (
  idanalitica serial PRIMARY KEY,
  iddoctor bigint ,
  idpacient bigint ,
  dataanalitica timestamp NOT NULL 
);

CREATE TABLE catalegproves (
  idprova int  PRIMARY KEY,
  nom_prova varchar(15) NOT NULL,
  descripcio varchar(100) NOT NULL,
  acronim varchar (15)
);

CREATE TABLE provestecnica (
  idprovatecnica serial PRIMARY KEY,
  idprova int ,
  sexe varchar(1) NOT NULL,
  dataprova timestamp NOT NULL ,
  resultat_numeric boolean NOT NULL DEFAULT true,
  minpat float,
  maxpat float,
  minpan float,
  maxpan float
);

CREATE TABLE resultats (
  idresultat serial PRIMARY KEY,
  idanalitica bigint ,
  idprovatecnica bigint ,
  resultats varchar(10) NOT NULL,
  dataresultat timestamp NOT NULL,
  UNIQUE(idanalitica,idprovatecnica) 
);

CREATE TABLE alarmes (
  idalarma serial PRIMARY KEY,
  idresultat bigint ,
  nivellalama smallint NOT NULL,
  validat bool NOT NULL,
  missatge varchar(100) NOT NULL
);

/* ALTERS*/


/*analitiques*/
ALTER TABLE analitiques
  ADD CONSTRAINT fk_idpacient FOREIGN KEY (idpacient) REFERENCES pacients (idpacient) ON UPDATE CASCADE,
  ADD CONSTRAINT fk_iddoctor FOREIGN KEY (iddoctor) REFERENCES doctors (iddoctor) ON UPDATE CASCADE;
  
/* provestecnica*/
ALTER TABLE provestecnica
  ADD CONSTRAINT fk_idprova FOREIGN KEY (idprova) REFERENCES catalegproves (idprova) ON UPDATE CASCADE;
 
/*resultas*/
ALTER TABLE resultats
  ADD CONSTRAINT fk_idanalitica FOREIGN KEY (idanalitica) REFERENCES analitiques (idanalitica) ON UPDATE CASCADE,
  ADD CONSTRAINT fk_idprovatecnica FOREIGN KEY (idprovatecnica) REFERENCES provestecnica (idprovatecnica) ON UPDATE CASCADE;
  
/* alarmes*/ 
ALTER TABLE alarmes
  ADD CONSTRAINT fk_idresultat FOREIGN KEY (idresultat) REFERENCES resultats (idresultat) ON UPDATE CASCADE;

/* INSERTS*/
INSERT INTO pacients (idpacient, nom, cognoms, dni, data_naix, sexe, adreca, ciutat, c_postal, telefon, email, num_ss, num_cat, nie, passaport) VALUES (default, 'jose', 'remar silva', '4811111M', '1996-07-12', 'M', 'veciana 8 2 2', 'barcelona', '08023', '989856565', 'jose@mail.com', NULL, NULL, NULL, NULL);
INSERT INTO pacients (idpacient, nom, cognoms, dni, data_naix, sexe, adreca, ciutat, c_postal, telefon, email, num_ss, num_cat, nie, passaport) VALUES (default, 'cecilia', 'vazques', '47888855M', '2007-11-12', 'F', 'tallat 27', 'cornella', '08632', '989877878', 'cesi@mail.com', NULL, NULL, 'x232233321l', NULL);
INSERT INTO doctors (iddoctor, nom, cognoms, especialitat) VALUES (default, 'albert', 'marinom', 'cirugia');
INSERT INTO doctors (iddoctor, nom, cognoms, especialitat) VALUES (default, 'maria', 'benavent', 'podologia');
INSERT INTO doctors (iddoctor, nom, cognoms, especialitat) VALUES (default, 'renzo', 'remar', 'fisioterapia');
INSERT INTO catalegproves (idprova, nom_prova, descripcio,acronim) VALUES ('101', 'glucosa', 'Es una hexosa',NULL);
INSERT INTO catalegproves (idprova, nom_prova, descripcio, acronim) VALUES ('82520', 'COCAINA', 'prueba de cocaina', 'COAC');
INSERT INTO catalegproves (idprova, nom_prova, descripcio, acronim) VALUES ('202', 'colesterol', 'test colesterol nivell en sangre', 'COL');
INSERT INTO analitiques (idanalitica, iddoctor, idpacient, dataanalitica) VALUES (default, '1', '2', CURRENT_TIMESTAMP);
INSERT INTO analitiques (idanalitica, iddoctor, idpacient, dataanalitica) VALUES (default, '1', '1', CURRENT_TIMESTAMP);
INSERT INTO analitiques (idanalitica, iddoctor, idpacient, dataanalitica) VALUES (default, '2', '1', CURRENT_TIMESTAMP);
INSERT INTO provestecnica (idprovatecnica, idprova, sexe, dataprova, minpat, maxpat, minpan, maxpan) VALUES (default, '101', 'M', CURRENT_TIMESTAMP, '80', '100', '60', '150');
INSERT INTO provestecnica (idprovatecnica, idprova, sexe, dataprova, minpat, maxpat, minpan, maxpan) VALUES (default, '101', 'F', CURRENT_TIMESTAMP, '70', '90', '50', '110');
INSERT INTO provestecnica (idprovatecnica, idprova, sexe, dataprova, minpat, maxpat, minpan, maxpan) VALUES (default, '101', 'M', '2017-11-01 00:00:00', '111', '150', '80', '170');
