// edx.students

// 1) Estudiants de gènere masculí nascuts al 1993 (81)
db.students.find({"birth_year":1993,"gender": "H"}).count()

// 2) Estudiants nascuts a la dècada dels 80 (936)
db.students.find({"birth_year":{$gte:1980,$lte:1989}}).count()

// 3) Estudiants de gènere femení nascuts a la dècada dels 90 (48)
db.students.find({"birth_year":{$gte:1990,$lte:1999},"gender":"M"}).count()

// 4) Estudiants que no hagin nascut l'any 1985 (3147)
db.students.find({"birth_year":{$ne:1985}}).count()

// 5) Estudiants nascuts el 1970, 1980 o 1990 (293)
db.students.find({"birth_year":{$in:[1970,1980,1990]}}).count()

// 6) Estudiants no nascuts el 1970, ni el 1980, ni el 1990 (2950)
db.students.find({"birth_year":{$not:{$in:[1970,1980,1990]}}}).count()

// 7) Estudiants nascuts un any parell (1684)
db.students.find({"birth_year":{$mod:[2,0]}}).count()

// 8) Estudiants nascuts un any inparell de la dècada dels 70 i de gènere femení (403)
db.students.find({"birth_year":{$gte:1970,$lte:1979,$mod:[2,1]}}).count() //SOL PARCIAL

// 9) Estudiants amb un @mail que acabi en .net (47)
db.students.find({"email":/.net$/}).count()

// 10)Estudiants amb un @mail que acabi en .org (16)
db.students.find({"email":/.org$/}).count()

// 11)Estudiants amb DNI que comenci i acabi en lletra (244)

// 12)Estudiants amb un nom que comenci per vocal (amb tots els accesnts possibles) (760)

// 13)Estudiants amb un nom compost (470)

// 14)Estudiants amb un nom de més de 13 caràcters (138)

// 15)Estudiants amb 2 o més vocals en els seu nom (705)


// edx.bios

// 16)Desenvolupadors que hagin fet contribucions en OOP (2)

// 17)Desenvolupadors que hagin fet contribucions en OOP o Java (3)

// 18)Desenvolupadors que hagin fet contribucions en OOP i Simula (2)









