psql -d lab_clinic -f /home/users/inf/hisx2/isx48262276/Documents/M10/tiggers/Practica2/sql_script.sql >/var/tmp/M10/log/errorsimportPacients_$(date +%d-%m-%y_%H:%M:%S).log
cp /var/tmp/M10/pacients_nous.csv /var/tmp/M10/historic/pacients_nous_$(date +%d-%m-%y_%H:%M:%S).csv
