psql -d lab_clinic -f /home/users/inf/hisx2/isx48262276/Documents/M10/tiggers/Practica3/sql_resultats.sql >/var/tmp/M10/log/Erros_resultats_$(date +%d-%m-%y_%H:%M:%S).log
cp /var/tmp/M10/resultats_nous.csv /var/tmp/M10/historic/resultats_nous_$(date +%d-%m-%y_%H:%M:%S).csv
