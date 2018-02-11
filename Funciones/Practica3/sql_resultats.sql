\COPY resultatsnous FROM '/var/tmp/M10/resultats_nous.csv' DELIMITER ',' CSV;
select actulizacions_resultats();
