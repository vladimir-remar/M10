############################################################################################################################################################
############################################################################################################################################################
#####################  					D A T A B A S E: imdb | C O L L E C T I O N: people                            #####################
############################################################################################################################################################
############################################################################################################################################################

//1.- Buscar las personas que sólo han actuado (no dirigido) (1909)
-------------------------------------------------------------------------------------------------------------------------------------------------------------
> 
{
        "_id" : "0000002",
        "name" : "Lauren Bacall",
        "dob" : "1924-9-16",
        "pob" : "New York, New York, USA",
        "hasActed" : true
}
{
        "_id" : "0000004",
        "name" : "John Belushi",
        "dob" : "1949-1-24",
        "pob" : "Chicago, Illinois, USA",
        "hasActed" : true
}
....

//2.- Buscar las personas que sólo han dirigido (no actuado) (341)
-------------------------------------------------------------------------------------------------------------------------------------------------------------
> 

{
        "_id" : "0000033",
        "name" : "Alfred Hitchcock",
        "dob" : "1899-8-13",
        "pob" : "Leytonstone, London, England, UK",
        "hasDirected" : true
}
{
        "_id" : "0000040",
        "name" : "Stanley Kubrick",
        "dob" : "1928-7-26",
        "pob" : "Bronx, New York, USA",
        "hasDirected" : true
}
....

//3.- Buscar las personas que han actuado y dirigido (20)
-------------------------------------------------------------------------------------------------------------------------------------------------------------
> 

{
        "_id" : "0000059",
        "name" : "Laurence Olivier",
        "dob" : "1907-5-22",
        "pob" : "Dorking, Surrey, England, UK",
        "hasActed" : true,
        "hasDirected" : true
}
{
        "_id" : "0000095",
        "name" : "Woody Allen",
        "dob" : "1935-12-1",
        "pob" : "Brooklyn, New York, USA",
        "hasActed" : true,
        "hasDirected" : true
}
...


//4.- Buscar las personas que ni han actuado ni dirigido (29)
-------------------------------------------------------------------------------------------------------------------------------------------------------------
> 

{
        "_id" : "0000076",
        "name" : "Francois Truffaut",
        "dob" : "1932-2-6",
        "pob" : "Paris, France"
}
{
        "_id" : "0000334",
        "name" : "Yun-Fat Chow",
        "dob" : "1955-5-18",
        "pob" : "Lamma Island, Hong Kong"
}
...

############################################################################################################################################################
############################################################################################################################################################
#####################  					D A T A B A S E: edx   | C O L L E C T I O N: bios                             #####################
############################################################################################################################################################
############################################################################################################################################################

//1.- Buscar las personas con premios otorgados en el año 2001 (3)
-------------------------------------------------------------------------------------------------------------------------------------------------------------
> 

{
        "_id" : 4,
        "name" : {
                "first" : "Kristen",
                "last" : "Nygaard"
        },
        "birthYear" : 1906,
        "deathYear" : 2002,
        "contribs" : [
                "OOP",
                "Simula"
        ],
        "awards" : [
                {
                        "award" : "Rosing Prize",
                        "year" : 1999,
                        "by" : "Norwegian Data Association"
                },
                {
                        "award" : "Turing Award",
                        "year" : 2001,
                        "by" : "ACM"
                },
                {
                        "award" : "IEEE John von Neumann Medal",
                        "year" : 2001,
                        "by" : "IEEE"
                }
        ]
}
{
        "_id" : 5,
        "name" : {
                "first" : "Ole-Johan",
                "last" : "Dahl"
        },
        "birthYear" : 1926,
        "deathYear" : 2002,
        "contribs" : [
                "OOP",
                "Simula"
        ],
        "awards" : [
                {
                        "award" : "Rosing Prize",
                        "year" : 1999,
                        "by" : "Norwegian Data Association"
                },
                {
                        "award" : "Turing Award",
                        "year" : 2001,
                        "by" : "ACM"
                },
                {
                        "award" : "IEEE John von Neumann Medal",
                        "year" : 2001,
                        "by" : "IEEE"
                }
        ]
}
{
        "_id" : 6,
        "name" : {
                "first" : "Guido",
                "last" : "van Rossum"
        },
        "birthYear" : 1931,
        "contribs" : [
                "Python"
        ],
        "awards" : [
                {
                        "award" : "Award for the Advancement of Free Software",
                        "year" : 2001,
                        "by" : "Free Software Foundation"
                },
                {
                        "award" : "NLUUG Award",
                        "year" : 2003,
                        "by" : "NLUUG"
                }
        ]
}

############################################################################################################################################################
############################################################################################################################################################
############################################################################################################################################################

//2.- Buscar las personas que hayan obtenido el premio 'Turing Award' (5)
-------------------------------------------------------------------------------------------------------------------------------------------------------------

> 

{
        "_id" : 1,
        "name" : {
                "first" : "John",
                "last" : "Backus"
        },
        "birthYear" : 1924,
        "deathYear" : 2007,
        "contribs" : [
                "Fortran",
                "ALGOL",
                "Backus-Naur Form",
                "FP"
        ],
        "awards" : [
                {
                        "award" : "W.W. McDowell Award",
                        "year" : 1967,
                        "by" : "IEEE Computer Society"
                },
                {
                        "award" : "National Medal of Science",
                        "year" : 1975,
                        "by" : "National Science Foundation"
                },
                {
                        "award" : "Turing Award",
                        "year" : 1977,
                        "by" : "ACM"
                },
                {
                        "award" : "Draper Prize",
                        "year" : 1993,
                        "by" : "National Academy of Engineering"
                }
        ]
}
{
        "_id" : 2,
        "name" : {
                "first" : "John",
                "last" : "McCarthy"
        },
        "birthYear" : 1927,
        "deathYear" : 2011,
        "contribs" : [
                "Lisp",
                "Artificial Intelligence",
                "ALGOL"
        ],
        "awards" : [
                {
                        "award" : "Turing Award",
                        "year" : 1971,
                        "by" : "ACM"
                },
                {
                        "award" : "Kyoto Prize",
                        "year" : 1988,
                        "by" : "Inamori Foundation"
                },
                {
                        "award" : "National Medal of Science",
                        "year" : 1990,
                        "by" : "National Science Foundation"
                }
        ]
}
{
        "_id" : 4,
        "name" : {
                "first" : "Kristen",
                "last" : "Nygaard"
        },
        "birthYear" : 1906,
        "deathYear" : 2002,
        "contribs" : [
                "OOP",
                "Simula"
        ],
        "awards" : [
                {
                        "award" : "Rosing Prize",
                        "year" : 1999,
                        "by" : "Norwegian Data Association"
                },
                {
                        "award" : "Turing Award",
                        "year" : 2001,
                        "by" : "ACM"
                },
                {
                        "award" : "IEEE John von Neumann Medal",
                        "year" : 2001,
                        "by" : "IEEE"
                }
        ]
}
{
        "_id" : 5,
        "name" : {
                "first" : "Ole-Johan",
                "last" : "Dahl"
        },
        "birthYear" : 1926,
        "deathYear" : 2002,
        "contribs" : [
                "OOP",
                "Simula"
        ],
        "awards" : [
                {
                        "award" : "Rosing Prize",
                        "year" : 1999,
                        "by" : "Norwegian Data Association"
                },
                {
                        "award" : "Turing Award",
                        "year" : 2001,
                        "by" : "ACM"
                },
                {
                        "award" : "IEEE John von Neumann Medal",
                        "year" : 2001,
                        "by" : "IEEE"
                }
        ]
}
{
        "_id" : 7,
        "name" : {
                "first" : "Dennis",
                "last" : "Ritchie"
        },
        "birthYear" : 1956,
        "deathYear" : 2011,
        "contribs" : [
                "UNIX",
                "C"
        ],
        "awards" : [
                {
                        "award" : "Turing Award",
                        "year" : 1983,
                        "by" : "ACM"
                },
                {
                        "award" : "National Medal of Technology",
                        "year" : 1998,
                        "by" : "United States"
                },
                {
                        "award" : "Japan Prize",
                        "year" : 2011,
                        "by" : "The Japan Prize Foundation"
                }
        ]
}

############################################################################################################################################################
############################################################################################################################################################
############################################################################################################################################################

//3.- Buscar las personas que haya obtenido un premio del tipo 'National Medal of' (4)
-------------------------------------------------------------------------------------------------------------------------------------------------------------

> 
{
        "_id" : 1,
        "name" : {
                "first" : "John",
                "last" : "Backus"
        },
        "birthYear" : 1924,
        "deathYear" : 2007,
        "contribs" : [
                "Fortran",
                "ALGOL",
                "Backus-Naur Form",
                "FP"
        ],
        "awards" : [
                {
                        "award" : "W.W. McDowell Award",
                        "year" : 1967,
                        "by" : "IEEE Computer Society"
                },
                {
                        "award" : "National Medal of Science",
                        "year" : 1975,
                        "by" : "National Science Foundation"
                },
                {
                        "award" : "Turing Award",
                        "year" : 1977,
                        "by" : "ACM"
                },
                {
                        "award" : "Draper Prize",
                        "year" : 1993,
                        "by" : "National Academy of Engineering"
                }
        ]
}
{
        "_id" : 2,
        "name" : {
                "first" : "John",
                "last" : "McCarthy"
        },
        "birthYear" : 1927,
        "deathYear" : 2011,
        "contribs" : [
                "Lisp",
                "Artificial Intelligence",
                "ALGOL"
        ],
        "awards" : [
                {
                        "award" : "Turing Award",
                        "year" : 1971,
                        "by" : "ACM"
                },
                {
                        "award" : "Kyoto Prize",
                        "year" : 1988,
                        "by" : "Inamori Foundation"
                },
                {
                        "award" : "National Medal of Science",
                        "year" : 1990,
                        "by" : "National Science Foundation"
                }
        ]
}
{
        "_id" : 3,
        "name" : {
                "first" : "Grace",
                "last" : "Hopper"
        },
        "title" : "Rear Admiral",
        "birthYear" : 1915,
        "deathYear" : 1992,
        "contribs" : [
                "UNIVAC",
                "compiler",
                "FLOW-MATIC",
                "COBOL"
        ],
        "awards" : [
                {
                        "award" : "Computer Sciences Man of the Year",
                        "year" : 1969,
                        "by" : "Data Processing Management Association"
                },
                {
                        "award" : "Distinguished Fellow",
                        "year" : 1973,
                        "by" : " British Computer Society"
                },
                {
                        "award" : "W. W. McDowell Award",
                        "year" : 1976,
                        "by" : "IEEE Computer Society"
                },
                {
                        "award" : "National Medal of Technology",
                        "year" : 1991,
                        "by" : "United States"
                }
        ]
}
{
        "_id" : 7,
        "name" : {
                "first" : "Dennis",
                "last" : "Ritchie"
        },
        "birthYear" : 1956,
        "deathYear" : 2011,
        "contribs" : [
                "UNIX",
                "C"
        ],
        "awards" : [
                {
                        "award" : "Turing Award",
                        "year" : 1983,
                        "by" : "ACM"
                },
                {
                        "award" : "National Medal of Technology",
                        "year" : 1998,
                        "by" : "United States"
                },
                {
                        "award" : "Japan Prize",
                        "year" : 2011,
                        "by" : "The Japan Prize Foundation"
                }
        ]
}

############################################################################################################################################################
############################################################################################################################################################
############################################################################################################################################################

//4.- Buscar las personas con fecha de nacimiento de la que no conste su fecha de defunción (3)
-------------------------------------------------------------------------------------------------------------------------------------------------------------

> 
> 

{
        "_id" : 6,
        "name" : {
                "first" : "Guido",
                "last" : "van Rossum"
        },
        "birthYear" : 1931,
        "contribs" : [
                "Python"
        ],
        "awards" : [
                {
                        "award" : "Award for the Advancement of Free Software",
                        "year" : 2001,
                        "by" : "Free Software Foundation"
                },
                {
                        "award" : "NLUUG Award",
                        "year" : 2003,
                        "by" : "NLUUG"
                }
        ]
}
{
        "_id" : 8,
        "name" : {
                "first" : "Yukihiro",
                "aka" : "Matz",
                "last" : "Matsumoto"
        },
        "birthYear" : 1941,
        "contribs" : [
                "Ruby"
        ],
        "awards" : [
                {
                        "award" : "Award for the Advancement of Free Software",
                        "year" : "2011",
                        "by" : "Free Software Foundation"
                }
        ]
}
{
        "_id" : 9,
        "name" : {
                "first" : "James",
                "last" : "Gosling"
        },
        "birthYear" : 1965,
        "contribs" : [
                "Java"
        ],
        "awards" : [
                {
                        "award" : "The Economist Innovation Award",
                        "year" : 2002,
                        "by" : "The Economist"
                },
                {
                        "award" : "Officer of the Order of Canada",
                        "year" : 2007,
                        "by" : "Canada"
                }
        ]
}

############################################################################################################################################################
############################################################################################################################################################
############################################################################################################################################################

//5.- Buscar las personas de la colección bios que destaquen en el terreno de OOP (2)
-------------------------------------------------------------------------------------------------------------------------------------------------------------

> 
{
        "_id" : 4,
        "name" : {
                "first" : "Kristen",
                "last" : "Nygaard"
        },
        "birthYear" : 1906,
        "deathYear" : 2002,
        "contribs" : [
                "OOP",
                "Simula"
        ],
        "awards" : [
                {
                        "award" : "Rosing Prize",
                        "year" : 1999,
                        "by" : "Norwegian Data Association"
                },
                {
                        "award" : "Turing Award",
                        "year" : 2001,
                        "by" : "ACM"
                },
                {
                        "award" : "IEEE John von Neumann Medal",
                        "year" : 2001,
                        "by" : "IEEE"
                }
        ]
}
{
        "_id" : 5,
        "name" : {
                "first" : "Ole-Johan",
                "last" : "Dahl"
        },
        "birthYear" : 1926,
        "deathYear" : 2002,
        "contribs" : [
                "OOP",
                "Simula"
        ],
        "awards" : [
                {
                        "award" : "Rosing Prize",
                        "year" : 1999,
                        "by" : "Norwegian Data Association"
                },
                {
                        "award" : "Turing Award",
                        "year" : 2001,
                        "by" : "ACM"
                },
                {
                        "award" : "IEEE John von Neumann Medal",
                        "year" : 2001,
                        "by" : "IEEE"
                }
        ]
}

//6.- Buscar las personas de la colección bios que destaquen en el terreno de Java, Ruby o Python (3)
-------------------------------------------------------------------------------------------------------------------------------------------------------------

> 

{
        "_id" : 6,
        "name" : {
                "first" : "Guido",
                "last" : "van Rossum"
        },
        "birthYear" : 1931,
        "contribs" : [
                "Python"
        ],
        "awards" : [
                {
                        "award" : "Award for the Advancement of Free Software",
                        "year" : 2001,
                        "by" : "Free Software Foundation"
                },
                {
                        "award" : "NLUUG Award",
                        "year" : 2003,
                        "by" : "NLUUG"
                }
        ]
}
{
        "_id" : 8,
        "name" : {
                "first" : "Yukihiro",
                "aka" : "Matz",
                "last" : "Matsumoto"
        },
        "birthYear" : 1941,
        "contribs" : [
                "Ruby"
        ],
        "awards" : [
                {
                        "award" : "Award for the Advancement of Free Software",
                        "year" : "2011",
                        "by" : "Free Software Foundation"
                }
        ]
}
{
        "_id" : 9,
        "name" : {
                "first" : "James",
                "last" : "Gosling"
        },
        "birthYear" : 1965,
        "contribs" : [
                "Java"
        ],
        "awards" : [
                {
                        "award" : "The Economist Innovation Award",
                        "year" : 2002,
                        "by" : "The Economist"
                },
                {
                        "award" : "Officer of the Order of Canada",
                        "year" : 2007,
                        "by" : "Canada"
                }
        ]
}

############################################################################################################################################################
############################################################################################################################################################
############################################################################################################################################################

//7.- Buscar las personas de la colección bios que destaquen en el terreno de OOP y Simula (2)
-------------------------------------------------------------------------------------------------------------------------------------------------------------

> 
> 

{
        "_id" : 4,
        "name" : {
                "first" : "Kristen",
                "last" : "Nygaard"
        },
        "birthYear" : 1906,
        "deathYear" : 2002,
        "contribs" : [
                "OOP",
                "Simula"
        ],
        "awards" : [
                {
                        "award" : "Rosing Prize",
                        "year" : 1999,
                        "by" : "Norwegian Data Association"
                },
                {
                        "award" : "Turing Award",
                        "year" : 2001,
                        "by" : "ACM"
                },
                {
                        "award" : "IEEE John von Neumann Medal",
                        "year" : 2001,
                        "by" : "IEEE"
                }
        ]
}
{
        "_id" : 5,
        "name" : {
                "first" : "Ole-Johan",
                "last" : "Dahl"
        },
        "birthYear" : 1926,
        "deathYear" : 2002,
        "contribs" : [
                "OOP",
                "Simula"
        ],
        "awards" : [
                {
                        "award" : "Rosing Prize",
                        "year" : 1999,
                        "by" : "Norwegian Data Association"
                },
                {
                        "award" : "Turing Award",
                        "year" : 2001,
                        "by" : "ACM"
                },
                {
                        "award" : "IEEE John von Neumann Medal",
                        "year" : 2001,
                        "by" : "IEEE"
                }
        ]
}


############################################################################################################################################################
############################################################################################################################################################
############################################################################################################################################################

//8.- Buscar las personas de la colección bios sin premios logrados (1)
-------------------------------------------------------------------------------------------------------------------------------------------------------------

> 
{
        "_id" : 10,
        "name" : {
                "first" : "Martin",
                "last" : "Odersky"
        },
        "contribs" : [
                "Scala"
        ]
}

############################################################################################################################################################
############################################################################################################################################################
############################################################################################################################################################

//9.- Buscar las personas de la colección bios con 1 premio conseguido (1)
-------------------------------------------------------------------------------------------------------------------------------------------------------------

> 

{
        "_id" : 8,
        "name" : {
                "first" : "Yukihiro",
                "aka" : "Matz",
                "last" : "Matsumoto"
        },
        "birthYear" : 1941,
        "contribs" : [
                "Ruby"
        ],
        "awards" : [
                {
                        "award" : "Award for the Advancement of Free Software",
                        "year" : "2011",
                        "by" : "Free Software Foundation"
                }
        ]
}

############################################################################################################################################################
############################################################################################################################################################
############################################################################################################################################################

//10.- Buscar las personas de la colección bios con 3 o más premios conseguidos (6)
-------------------------------------------------------------------------------------------------------------------------------------------------------------

> 

{
        "_id" : 1,
        "name" : {
                "first" : "John",
                "last" : "Backus"
        },
        "birthYear" : 1924,
        "deathYear" : 2007,
        "contribs" : [
                "Fortran",
                "ALGOL",
                "Backus-Naur Form",
                "FP"
        ],
        "awards" : [
                {
                        "award" : "W.W. McDowell Award",
                        "year" : 1967,
                        "by" : "IEEE Computer Society"
                },
                {
                        "award" : "National Medal of Science",
                        "year" : 1975,
                        "by" : "National Science Foundation"
                },
                {
                        "award" : "Turing Award",
                        "year" : 1977,
                        "by" : "ACM"
                },
                {
                        "award" : "Draper Prize",
                        "year" : 1993,
                        "by" : "National Academy of Engineering"
                }
        ]
}
{
        "_id" : 2,
        "name" : {
                "first" : "John",
                "last" : "McCarthy"
        },
        "birthYear" : 1927,
        "deathYear" : 2011,
        "contribs" : [
                "Lisp",
                "Artificial Intelligence",
                "ALGOL"
        ],
        "awards" : [
                {
                        "award" : "Turing Award",
                        "year" : 1971,
                        "by" : "ACM"
                },
                {
                        "award" : "Kyoto Prize",
                        "year" : 1988,
                        "by" : "Inamori Foundation"
                },
                {
                        "award" : "National Medal of Science",
                        "year" : 1990,
                        "by" : "National Science Foundation"
                }
        ]
}
{
        "_id" : 3,
        "name" : {
                "first" : "Grace",
                "last" : "Hopper"
        },
        "title" : "Rear Admiral",
        "birthYear" : 1915,
        "deathYear" : 1992,
        "contribs" : [
                "UNIVAC",
                "compiler",
                "FLOW-MATIC",
                "COBOL"
        ],
        "awards" : [
                {
                        "award" : "Computer Sciences Man of the Year",
                        "year" : 1969,
                        "by" : "Data Processing Management Association"
                },
                {
                        "award" : "Distinguished Fellow",
                        "year" : 1973,
                        "by" : " British Computer Society"
                },
                {
                        "award" : "W. W. McDowell Award",
                        "year" : 1976,
                        "by" : "IEEE Computer Society"
                },
                {
                        "award" : "National Medal of Technology",
                        "year" : 1991,
                        "by" : "United States"
                }
        ]
}
{
        "_id" : 4,
        "name" : {
                "first" : "Kristen",
                "last" : "Nygaard"
        },
        "birthYear" : 1906,
        "deathYear" : 2002,
        "contribs" : [
                "OOP",
                "Simula"
        ],
        "awards" : [
                {
                        "award" : "Rosing Prize",
                        "year" : 1999,
                        "by" : "Norwegian Data Association"
                },
                {
                        "award" : "Turing Award",
                        "year" : 2001,
                        "by" : "ACM"
                },
                {
                        "award" : "IEEE John von Neumann Medal",
                        "year" : 2001,
                        "by" : "IEEE"
                }
        ]
}
{
        "_id" : 5,
        "name" : {
                "first" : "Ole-Johan",
                "last" : "Dahl"
        },
        "birthYear" : 1926,
        "deathYear" : 2002,
        "contribs" : [
                "OOP",
                "Simula"
        ],
        "awards" : [
                {
                        "award" : "Rosing Prize",
                        "year" : 1999,
                        "by" : "Norwegian Data Association"
                },
                {
                        "award" : "Turing Award",
                        "year" : 2001,
                        "by" : "ACM"
                },
                {
                        "award" : "IEEE John von Neumann Medal",
                        "year" : 2001,
                        "by" : "IEEE"
                }
        ]
}
{
        "_id" : 7,
        "name" : {
                "first" : "Dennis",
                "last" : "Ritchie"
        },
        "birthYear" : 1956,
        "deathYear" : 2011,
        "contribs" : [
                "UNIX",
                "C"
        ],
        "awards" : [
                {
                        "award" : "Turing Award",
                        "year" : 1983,
                        "by" : "ACM"
                },
                {
                        "award" : "National Medal of Technology",
                        "year" : 1998,
                        "by" : "United States"
                },
                {
                        "award" : "Japan Prize",
                        "year" : 2011,
                        "by" : "The Japan Prize Foundation"
                }
        ]
}

############################################################################################################################################################
############################################################################################################################################################
############################################################################################################################################################

//11.- Buscar las personas de la colección bios con entre 2 y 4 premios conseguidos (8)
-------------------------------------------------------------------------------------------------------------------------------------------------------------

> 

{
        "_id" : 1,
        "name" : {
                "first" : "John",
                "last" : "Backus"
        },
        "birthYear" : 1924,
        "deathYear" : 2007,
        "contribs" : [
                "Fortran",
                "ALGOL",
                "Backus-Naur Form",
                "FP"
        ],
        "awards" : [
                {
                        "award" : "W.W. McDowell Award",
                        "year" : 1967,
                        "by" : "IEEE Computer Society"
                },
                {
                        "award" : "National Medal of Science",
                        "year" : 1975,
                        "by" : "National Science Foundation"
                },
                {
                        "award" : "Turing Award",
                        "year" : 1977,
                        "by" : "ACM"
                },
                {
                        "award" : "Draper Prize",
                        "year" : 1993,
                        "by" : "National Academy of Engineering"
                }
        ]
}
{
        "_id" : 2,
        "name" : {
                "first" : "John",
                "last" : "McCarthy"
        },
        "birthYear" : 1927,
        "deathYear" : 2011,
        "contribs" : [
                "Lisp",
                "Artificial Intelligence",
                "ALGOL"
        ],
        "awards" : [
                {
                        "award" : "Turing Award",
                        "year" : 1971,
                        "by" : "ACM"
                },
                {
                        "award" : "Kyoto Prize",
                        "year" : 1988,
                        "by" : "Inamori Foundation"
                },
                {
                        "award" : "National Medal of Science",
                        "year" : 1990,
                        "by" : "National Science Foundation"
                }
        ]
}
{
        "_id" : 3,
        "name" : {
                "first" : "Grace",
                "last" : "Hopper"
        },
        "title" : "Rear Admiral",
        "birthYear" : 1915,
        "deathYear" : 1992,
        "contribs" : [
                "UNIVAC",
                "compiler",
                "FLOW-MATIC",
                "COBOL"
        ],
        "awards" : [
                {
                        "award" : "Computer Sciences Man of the Year",
                        "year" : 1969,
                        "by" : "Data Processing Management Association"
                },
                {
                        "award" : "Distinguished Fellow",
                        "year" : 1973,
                        "by" : " British Computer Society"
                },
                {
                        "award" : "W. W. McDowell Award",
                        "year" : 1976,
                        "by" : "IEEE Computer Society"
                },
                {
                        "award" : "National Medal of Technology",
                        "year" : 1991,
                        "by" : "United States"
                }
        ]
}
{
        "_id" : 4,
        "name" : {
                "first" : "Kristen",
                "last" : "Nygaard"
        },
        "birthYear" : 1906,
        "deathYear" : 2002,
        "contribs" : [
                "OOP",
                "Simula"
        ],
        "awards" : [
                {
                        "award" : "Rosing Prize",
                        "year" : 1999,
                        "by" : "Norwegian Data Association"
                },
                {
                        "award" : "Turing Award",
                        "year" : 2001,
                        "by" : "ACM"
                },
                {
                        "award" : "IEEE John von Neumann Medal",
                        "year" : 2001,
                        "by" : "IEEE"
                }
        ]
}
{
        "_id" : 5,
        "name" : {
                "first" : "Ole-Johan",
                "last" : "Dahl"
        },
        "birthYear" : 1926,
        "deathYear" : 2002,
        "contribs" : [
                "OOP",
                "Simula"
        ],
        "awards" : [
                {
                        "award" : "Rosing Prize",
                        "year" : 1999,
                        "by" : "Norwegian Data Association"
                },
                {
                        "award" : "Turing Award",
                        "year" : 2001,
                        "by" : "ACM"
                },
                {
                        "award" : "IEEE John von Neumann Medal",
                        "year" : 2001,
                        "by" : "IEEE"
                }
        ]
}
{
        "_id" : 6,
        "name" : {
                "first" : "Guido",
                "last" : "van Rossum"
        },
        "birthYear" : 1931,
        "contribs" : [
                "Python"
        ],
        "awards" : [
                {
                        "award" : "Award for the Advancement of Free Software",
                        "year" : 2001,
                        "by" : "Free Software Foundation"
                },
                {
                        "award" : "NLUUG Award",
                        "year" : 2003,
                        "by" : "NLUUG"
                }
        ]
}
{
        "_id" : 7,
        "name" : {
                "first" : "Dennis",
                "last" : "Ritchie"
        },
        "birthYear" : 1956,
        "deathYear" : 2011,
        "contribs" : [
                "UNIX",
                "C"
        ],
        "awards" : [
                {
                        "award" : "Turing Award",
                        "year" : 1983,
                        "by" : "ACM"
                },
                {
                        "award" : "National Medal of Technology",
                        "year" : 1998,
                        "by" : "United States"
                },
                {
                        "award" : "Japan Prize",
                        "year" : 2011,
                        "by" : "The Japan Prize Foundation"
                }
        ]
}
{
        "_id" : 9,
        "name" : {
                "first" : "James",
                "last" : "Gosling"
        },
        "birthYear" : 1965,
        "contribs" : [
                "Java"
        ],
        "awards" : [
                {
                        "award" : "The Economist Innovation Award",
                        "year" : 2002,
                        "by" : "The Economist"
                },
                {
                        "award" : "Officer of the Order of Canada",
                        "year" : 2007,
                        "by" : "Canada"
                }
        ]
}


############################################################################################################################################################
############################################################################################################################################################
#####################  					D A T A B A S E: edx   | C O L L E C T I O N: books                            #####################
############################################################################################################################################################
############################################################################################################################################################

//1.- Buscar todos los libros con precio superior a 100 USD (7)
-------------------------------------------------------------------------------------------------------------------------------------------------------------
> 

{
        "_id" : ObjectId("4d59b5b6cad49870530000f4"),
        "author" : [
                "Johannes Itten"
        ],
        "isbn" : "9780471289289",
        "price" : {
                "currency" : "USD",
                "discount" : 76.78,
                "msrp" : 120
        },
        "publicationYear" : 1997,
        "publisher" : "Wiley",
        "tags" : [
                "use of color",
                "color theory",
                "color",
                "johannes itten",
                "graphic design",
                "arts",
                "design",
                "art",
                "bd",
                "colour"
        ],
        "title" : "The Art of Color: The Subjective Experience and Objective Rationale of Color - Revised Edition"
}
...

//2.- Buscar todos los libros publicados por "Martin Fowler" (4)
-------------------------------------------------------------------------------------------------------------------------------------------------------------
> 

{
        "_id" : ObjectId("4d59b40acad4987053000013"),
        "author" : [
                "Kent Beck",
                "Martin Fowler"
        ],
        "isbn" : "0201710919",
        "price" : {
                "currency" : "USD",
                "discount" : 26.58,
                "msrp" : 38.99
        },
        "publicationYear" : 2001,
        "publisher" : "Addison-Wesley",
        "tags" : [
                "xp",
                "agile",
                "software engineering",
                "programming",
                "2007",
                "book - computer - software engineering",
                "kent beck",
                "mybooks",
                "software development",
                "thesis",
                "todo"
        ],
        "title" : "Planning Extreme Programming"
}
....


//3.- Buscar los libros que tengan el tag 'programming', 'agile' y "java" (5)
-------------------------------------------------------------------------------------------------------------------------------------------------------------
> 
{
        "_id" : ObjectId("4d59b410cad4987053000017"),
        "author" : [
                "Kent Beck"
        ],
        "isbn" : "0321413091",
        "price" : {
                "currency" : "USD",
                "discount" : 33.73,
                "msrp" : 39.99
        },
        "publicationYear" : 2007,
        "publisher" : "Addison-Wesley",
        "tags" : [
                "patterns",
                "programming",
                "java",
                "agile",
                "coding",
                "design patterns",
                "kent beck signature book",
                "object-oriented design",
                "development",
                "readable code",
                "rns",
                "signature series",
                "software development"
        ],
        "title" : "Implementation Patterns"
}


//4.- Buscar aquellos libros que han sido escritos por Martin Fowler y Kent Beck (2)
-------------------------------------------------------------------------------------------------------------------------------------------------------------
> 

{
        "_id" : ObjectId("4d59b40acad4987053000013"),
        "author" : [
                "Kent Beck",
                "Martin Fowler"
        ],
        "isbn" : "0201710919",
        "price" : {
                "currency" : "USD",
                "discount" : 26.58,
                "msrp" : 38.99
        },
        "publicationYear" : 2001,
        "publisher" : "Addison-Wesley",
        "tags" : [
                "xp",
                "agile",
                "software engineering",
                "programming",
                "2007",
                "book - computer - software engineering",
                "kent beck",
                "mybooks",
                "software development",
                "thesis",
                "todo"
        ],
        "title" : "Planning Extreme Programming"
}
...

//5.- Buscar los libros escritos por 3 autores (17)
-------------------------------------------------------------------------------------------------------------------------------------------------------------
> 

{
        "_id" : ObjectId("4d59b751cad49870530001c1"),
        "author" : [
                "James Snell",
                "Doug Tidwell",
                "Paul Kulchenko"
        ],
        "isbn" : "0596000952",
        "price" : {
                "currency" : "USD",
                "discount" : 22.83,
                "msrp" : 34.95
        },
        "publicationYear" : 2002,
        "publisher" : "O'Reilly & Associates, Inc",
        "tags" : [
                "web programming",
                "xml",
                "linux",
                "networking",
                "web services"
        ],
        "title" : "Programming Web Services with SOAP"
}
....


//6.- Buscar los libros escritos por mas de un autor (106)
-------------------------------------------------------------------------------------------------------------------------------------------------------------
> 



############################################################################################################################################################
############################################################################################################################################################
#####################  					D A T A B A S E: geo | C O L L E C T I O N: countries                          #####################
############################################################################################################################################################
############################################################################################################################################################

//1.- Buscar aquellos paises donde el español es lenguaje nativa (24)
-------------------------------------------------------------------------------------------------------------------------------------------------------------
> 

//2.- Buscar aquellos paises donde el español es lenguaje oficial (21)
-------------------------------------------------------------------------------------------------------------------------------------------------------------
> 

//3.- Mostrar aquellos paises donde sólo el español es lengua oficial (y no hay más)
-------------------------------------------------------------------------------------------------------------------------------------------------------------
> 
