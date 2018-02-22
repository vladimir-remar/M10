CREATE OR REPLACE FUNCTION emp_nom_upper() RETURNS trigger 
AS $emp_stamp$
BEGIN
  NEW.empname = upper(NEW.empname);
  RETURN NEW;
END;
$emp_stamp$ 
LANGUAGE plpgsql;

CREATE TRIGGER emp_stamp BEFORE INSERT OR UPDATE ON emp
    FOR EACH ROW EXECUTE PROCEDURE emp_nom_upper();

-- #####################################################################
CREATE OR REPLACE FUNCTION emp_stamp() 
RETURNS trigger AS $emp_stamp_2$
BEGIN
  IF NEW.empname IS NULL THEN
    RAISE EXCEPTION 'empname cannot be null';
    RETURN NULL;
  END IF;
  IF NEW.salary IS NULL THEN
    RAISE EXCEPTION '% cannot have null salary', NEW.empname;
    RETURN NULL;
  END IF;
  IF NEW.salary < 0 THEN
      RETURN NULL;
  END IF;

  NEW.last_date := current_timestamp;
  NEW.last_user := current_user;
  RETURN NEW;
  END;
$emp_stamp_2$ LANGUAGE plpgsql;

CREATE TRIGGER emp_stamp_2 BEFORE INSERT OR UPDATE ON emp
    FOR EACH ROW EXECUTE PROCEDURE emp_stamp();

-- #####################################################################
CREATE FUNCTION emp_no_esborrar() RETURNS trigger 
AS $emp_stamp_3$
  BEGIN
  IF OLD.salary > 1000 THEN
    RETURN OLD;
  ELSE
    RETURN NULL;
  END IF;
END;
$emp_stamp_3$ 
LANGUAGE plpgsql;

CREATE TRIGGER emp_stamp_3 BEFORE DELETE ON emp
    FOR EACH ROW EXECUTE PROCEDURE emp_no_esborrar();
-- #####################################################################
