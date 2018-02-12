# M10-STORED PROCEDURES
Funcions per la gestio d'una base de dades d'un laboratori clinic
## DB laboratori clinic
Cambiar el owner por el que tenga privilegios de creacion y modificacion
de db's.

    cp lab_clinic.sql /tmp/.
    psql template1 
    create database lab_clinic;
    \c lab_clinic;
    \i /tmp/lab_clinic.sql
