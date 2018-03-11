/*
Per això caldrà : 
1) Crear una taula per guardar el nom d'usuari, el timestamp, el nom de 
taula i l'operació realitzada. Cadascú ha de crear la taula amb 
l'estructura que consideri més adient 

2) Crear els trigger i les funcions necessàries per guardar el log dels 
inserts, dels updates i dels deletes de la taula analítiques i de la 
taula resultatsanalitiques. 

3) Treballar amb diferents usuaris per fer les proves.:Crear 3 rols 
nous amb permisos per Training.
*/

CREATE USER pere SUPERUSER PASSWORD '12345';
CREATE USER marta SUPERUSER PASSWORD '12345';
CREATE USER anna SUPERUSER PASSWORD '12345';

GRANT ALL PRIVILEGES ON DATABASE lab_clinic TO marta;
GRANT ALL PRIVILEGES ON DATABASE lab_clinic TO pere;
GRANT ALL PRIVILEGES ON DATABASE lab_clinic TO anna;

create table logs_users(
  userid text NOT NULL,
  stamp timestamp NOT NULL,
  nom_taula varchar(200) NOT NULL,
  operation varchar(200) NOT NULL
);

create or replace function  logs_operations() returns trigger
as $$
begin
  INSERT INTO logs_users SELECT user,now(),TG_TABLE_NAME,TG_OP;
return NEW;
end;
$$
language plpgsql;

create trigger c_user_logs after insert or update or delete on resultats for each row execute procedure logs_operations();
create trigger c_user_logs after insert or update or delete on analitiques for each row execute procedure logs_operations();

/*
create or replace function  logs_operations() returns trigger
as $$
begin
  IF (TG_OP = 'DELETE') THEN 
    INSERT INTO logs_users SELECT user,now(),TG_TABLE_NAME,'D'; 
    RETURN OLD; 
  ELSEIF (TG_OP = 'UPDATE') THEN 
    INSERT INTO logs_users SELECT user,now(),TG_TABLE_NAME,'U';
    RETURN NEW; 
  ELSEIF (TG_OP = 'INSERT') THEN 
    INSERT INTO logs_users SELECT user,now(),TG_TABLE_NAME,'I';
    RETURN NEW; 
  END IF; 
  RETURN NULL; 
END; 
$l_U$ 
LANGUAGE plpgsql; 
 

CREATE TRIGGER c_user_logs AFTER INSERT OR UPDATE OR DELETE ON resultats 
FOR EACH ROW EXECUTE PROCEDURE logs_operations(); 

CREATE TRIGGER user_logs AFTER INSERT OR UPDATE OR DELETE ON analitiques 
FOR EACH ROW EXECUTE PROCEDURE logs_operations(); 
*/
