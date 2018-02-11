\COPY pacients_nous FROM '/var/tmp/M10/pacients_nous.csv' DELIMITER ',' CSV;
select nous_pacients();
