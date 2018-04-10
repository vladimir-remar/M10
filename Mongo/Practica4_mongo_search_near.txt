
PRÀCTICA 4 : TEXT SEARCH i GEO QUERIES

1) Idexs creats automàticament:

	db.system.indexes.find()

2) Text Search : $text $search { $meta: "textScore" }

	MongoDB supports query operations that perform a text search of string content.
	To perform text search, MongoDB uses a text index and the $text operator.
	
	A collection can only have one text search index, but that index can cover multiple fields.

	
db.stores.insert(
   [
     { _id: 1, name: "Java Hut", description: "Coffee and cakes" },
     { _id: 2, name: "Burger Buns", description: "Gourmet hamburgers" },
     { _id: 3, name: "Coffee Shop", description: "Just coffee" },
     { _id: 4, name: "Clothes Clothes Clothes", description: "Discount clothing" },
     { _id: 5, name: "Java Shopping", description: "Indonesian goods" }
   ]
)

db.stores.createIndex( { name: "text", description: "text" } )

db.system.indexes.find()

Buscar coma a google:
db.stores.find( { $text: { $search: "java coffee shop" } } )

Buscar frases exactes : \"....\"
db.stores.find( { $text: { $search: "java \"coffee shop\"" } } )

Excloure :
db.stores.find( { $text: { $search: "java shop -coffee" } } )

(de la pràctica 3 -- Operadors de Projecció)
(
	$			Projects the first element in an array that matches the query condition.
	$elemMatch	Projects the first element in an array that matches the specified $elemMatch condition.
	$meta		Projects the document’s score assigned during $text operation.
	$slice		Limits the number of elements projected from an array. Supports skip and limit slices.
)
Puntuació de les coincidències : $meta
db.stores.find(
   { $text: { $search: "java coffee shop" } },
   { puntuacio: { $meta: "textScore" } }
).sort( { puntuacio: { $meta: "textScore" } } )

	-------------------------------------------------------------------------------------------
3)
> use twitter
switched to db twitter

> show collections
system.indexes
tweets

> db.tweets.findOne()
{
        "_id" : ObjectId("576921b12dc7e3054bb06d2a"),
        "text" : "eu preciso de terminar de fazer a minha tabela, está muito foda **", <------
        "in_reply_to_status_id" : null,
        "retweet_count" : null,
        "contributors" : null,
        "created_at" : "Thu Sep 02 18:11:23 +0000 2010",
        "geo" : null,
        "source" : "web",
		...
}


> db.tweets.createIndex( { "text": "text"}, { "name": "searchs_idx"} )
{
        "createdCollectionAutomatically" : false,
        "numIndexesBefore" : 1,
        "numIndexesAfter" : 2,
        "ok" : 1
}

> db.tweets.getIndexes()
[
        {
                "v" : 1,
                "key" : {
                        "_id" : 1
                },
                "name" : "_id_",
                "ns" : "twitter.tweets"
        },
        {
                "v" : 1,
                "key" : {
                        "_fts" : "text",
                        "_ftsx" : 1
                },
                "name" : "searchs_idx",
                "ns" : "twitter.tweets",
                "weights" : {
                        "text" : 1
                },
                "default_language" : "english",
                "language_override" : "language",
                "textIndexVersion" : 3
        }
]
3.1) Buscar quants twits tenim amb Obama President
3.2) Buscar le textScore de cada twit amb Obama President
3.3) Buscar quants twits tenim amb Islam terrorism

3.4) Buscar i mostrar puntuació:
- Messi
- Ronaldo
- frase exacta :"Yes we can"
- frase exacta :"Barack Obama"
- Madrid
- Madrid i no 'real' i no 'atletico' 

	-------------------------------------------------------------------------------------------
4)
> use geo
switched to db geo

> show collections
cities
countries
system.indexes

> db.cities.findOne()
{
        "_id" : ObjectId("54579597e9cd9f37d7fcacd2"),
        "name" : "Sant Julià de Lòria",
        "country" : "AD",
        "timezone" : "Europe/Andorra",
        "population" : 8022,
        "loc" : {
                "longitude" : 1.49129,
                "latitude" : 42.46372
        }
}

> db.system.indexes.find()
{ "v" : 1, "key" : { "_id" : 1 }, "name" : "_id_", "ns" : "geo.cities" }
{ "v" : 1, "key" : { "_id" : 1 }, "name" : "_id_", "ns" : "geo.countries"}


> db.cities.getIndexes()
[
        {
                "v" : 1,
                "key" : {
                        "_id" : 1
                },
                "name" : "_id_",
                "ns" : "geo.cities"
        }
]

> db.cities.dropIndexes()
{
        "nIndexesWas" : 1,
        "msg" : "non-_id indexes dropped for collection",
        "ok" : 1
}

> db.cities.dropIndex("_id_")
{
        "nIndexesWas" : 1,
        "ok" : 0,
        "errmsg" : "cannot drop _id index",
        "code" : 72
}

---------------------------------------------------------
Consultes per proximitat: $near
---------------------------------------------------------
Specifies a point for which a geospatial query returns the 
documents from nearest to farthest.
$near requires a geospatial index:

IMPORTANT
Cal especificar les coordenades amb aquest ordre: “longitude, latitude.”
coordinates: [ <longitude> , <latitude> ]

{
  $near: {
     $geometry: {
        type: "Point" ,
        coordinates: [ <longitude> , <latitude> ]
     },
     $maxDistance: <distance in meters>,
     $minDistance: <distance in meters>
  }
}

Palma de Mallorca: [long: 2.6536742000000686, lat: 39.5751584]
Johannesburg: [long: 28.047305100000017000, lat: -26.2041028]
Pekin: [long: 116.40752599999996000, lat: 39.90403]
Barcelona: [long: 2.0787282, lat: 41.3948975]

> db.cities.createIndex({"loc": "2dsphere"} , {"name": "loc.geoidx"})
{
        "createdCollectionAutomatically" : false,
        "numIndexesBefore" : 2,
        "numIndexesAfter" : 3,
        "ok" : 1
}

> db.cities.getIndexes()

[
        {
                "v" : 1,
                "key" : {
                        "_id" : 1
                },
                "name" : "_id_",
                "ns" : "geo.cities"
        },
        {
                "v" : 1,
                "key" : {
                        "loc" : "2dsphere"
                },
                "name" : "loc.geoidx",
                "ns" : "geo.cities",
                "2dsphereIndexVersion" : 3
        }
]

//Pekin: [116.40752599999996000, 39.90403]
> db.cities.find({"loc": {
                     "$near": {
					     "$geometry": {
						     type: "Point" ,
						     coordinates: [116.40752599999996000, 39.90403]
					     },
					     "$maxDistance": 20000,
					     "$minDistance": 0
					  }
				   }
                })

{
        "_id" : ObjectId("54579598e9cd9f37d7fcdaa2"),
        "name" : "Beijing",
        "country" : "CN",
        "timezone" : "Asia/Harbin",
        "population" : 7480601,
        "loc" : {
                "longitude" : 116.39723,
                "latitude" : 39.9075
        }
}

{
        "_id" : ObjectId("54579598e9cd9f37d7fcd263"),
        "name" : "Tongzhou",
        "country" : "CN",
        "timezone" : "Asia/Harbin",
        "population" : 163326,
        "loc" : {
                "longitude" : 116.59944,
                "latitude" : 39.90528
        }
}


				
//Barcelona: [long: 2.0787282, lat: 41.3948975]				
> db.cities.find({"loc": {
                     "$near": {
					     "$geometry": { type: "Point" , coordinates: [2.0787282, 41.3948975] },
					     "$maxDistance": 20000,
					     "$minDistance": 0
					  }
				   }
                })
				
//Palma de Mallorca: [long: 2.6536742000000686, lat: 39.5751584]		
> db.cities.find({"loc": {
                     "$near": {
					     "$geometry": { type: "Point" , coordinates: [2.6536742000000686, 39.5751584] },
					     "$maxDistance": 20000,
					     "$minDistance": 0
					  }
				   }
                })


---------------------------------------------------------
Consultes per proximitat: runCommand geoNear
---------------------------------------------------------
Returns documents in order of proximity to a specified point, from the nearest to farthest.

limit: Optional. The maximum number of documents to return. The default value is 100.
				
//Palma de Mallorca: [long: 2.6536742000000686, lat: 39.5751584]				
> db.runCommand({
          "geoNear": "cities",
          "near": {"type": "Point", "coordinates": [2.6536742000000686, 39.5751584]},
	      "spherical": true,
          "maxDistance": 40000,
          "minDistance": 10000,
	      "distanceMultiplier": 0.001,
	      "limit": 10
})

{
        "waitedMS" : NumberLong(0),
        "results" : [
                {
                        "dis" : 11.373268344023979,
                        "obj" : {
                                "_id" : ObjectId("54579599e9cd9f37d7fd0ff6"),
                                "name" : "Marratxí",
                                "country" : "ES",
                                "timezone" : "Europe/Madrid",
                                "population" : 33348,
                                "loc" : {
                                        "longitude" : 2.75388,
                                        "latitude" : 39.64208
                                }
                        }
                },
                {
                        "dis" : 11.763701972717122,
                        "obj" : {
                                "_id" : ObjectId("54579599e9cd9f37d7fd1145"),
                                "name" : "s'Arenal",
                                "country" : "ES",
                                "timezone" : "Europe/Madrid",
                                "population" : 10207,
                                "loc" : {
                                        "longitude" : 2.75,
                                        "latitude" : 39.5
                                }
                        }
                },
                {
                        "dis" : 12.161883407867021,
                        "obj" : {
                                "_id" : ObjectId("54579599e9cd9f37d7fd0f23"),
                                "name" : "Puigpunyent",
                                "country" : "ES",
                                "timezone" : "Europe/Madrid",
                                "population" : 1513,
                                "loc" : {
                                        "longitude" : 2.52759,
                                        "latitude" : 39.62514
                                }
                        }
                },
                {
                        "dis" : 12.339985930577622,
                        "obj" : {
                                "_id" : ObjectId("54579599e9cd9f37d7fd111f"),
                                "name" : "Esporles",
                                "country" : "ES",
                                "timezone" : "Europe/Madrid",
                                "population" : 4457,
                                "loc" : {
                                        "longitude" : 2.57853,
                                        "latitude" : 39.6697
                                }
                        }
                },
                {
                        "dis" : 12.414020712119816,
                        "obj" : {
                                "_id" : ObjectId("54579599e9cd9f37d7fd1859"),
                                "name" : "Magaluf",
                                "country" : "ES",
                                "timezone" : "Europe/Madrid",
                                "population" : 4346,
                                "loc" : {
                                        "longitude" : 2.5353,
                                        "latitude" : 39.5111
                                }
                        }
                },
                {
                        "dis" : 12.697520875586857,
                        "obj" : {
                                "_id" : ObjectId("54579599e9cd9f37d7fd11e3"),
                                "name" : "Calvià",
                                "country" : "ES",
                                "timezone" : "Europe/Madrid",
                                "population" : 51774,
                                "loc" : {
                                        "longitude" : 2.50621,
                                        "latitude" : 39.5657
                                }
                        }
                },
                {
                        "dis" : 14.051403286680461,
                        "obj" : {
                                "_id" : ObjectId("54579599e9cd9f37d7fd11fa"),
                                "name" : "Bunyola",
                                "country" : "ES",
                                "timezone" : "Europe/Madrid",
                                "population" : 5475,
                                "loc" : {
                                        "longitude" : 2.69955,
                                        "latitude" : 39.69634
                                }
                        }
                },
                {
                        "dis" : 15.295456860483062,
                        "obj" : {
                                "_id" : ObjectId("54579599e9cd9f37d7fd0e46"),
                                "name" : "Valldemossa",
                                "country" : "ES",
                                "timezone" : "Europe/Madrid",
                                "population" : 1910,
                                "loc" : {
                                        "longitude" : 2.6223,
                                        "latitude" : 39.71042
                                }
                        }
                },
                {
                        "dis" : 16.75689150210545,
                        "obj" : {
                                "_id" : ObjectId("54579599e9cd9f37d7fd0ecc"),
                                "name" : "Santa Eugènia",
                                "country" : "ES",
                                "timezone" : "Europe/Madrid",
                                "population" : 1420,
                                "loc" : {
                                        "longitude" : 2.83864,
                                        "latitude" : 39.62361
                                }
                        }
                },
                {
                        "dis" : 16.906512097313147,
                        "obj" : {
                                "_id" : ObjectId("54579599e9cd9f37d7fd1854"),
                                "name" : "Santa Ponça",
                                "country" : "ES",
                                "timezone" : "Europe/Madrid",
                                "population" : 10736,
                                "loc" : {
                                        "longitude" : 2.4766,
                                        "latitude" : 39.50868
                                }
                        }
                }
        ],
        "stats" : {
                "nscanned" : 61,
                "objectsLoaded" : 34,
                "avgDistance" : 13.576064498947451,
                "maxDistance" : 16.906512097313147,
                "time" : 39
        },
        "ok" : 1
}
				
				
function findCities(long, lat, maxDist, minDist) {
  return db.runCommand({
			  "geoNear": "cities",
			  "near": {"type": "Point", "coordinates": [long, lat]},
			  "spherical": true,
			  "maxDistance": maxDist,
			  "minDistance": minDist,
			  "distanceMultiplier": 0.001,
			  "limit": 10
		})
}

findCities(-5.53888900000004, 38.639167, 40000, 0)
findCities(28.047305100000017000, -26.2041028, 40000, 0)
findCities(116.40752599999996000, 39.90403, 40000, 0)	
	
				
#######################################################################################
#######################################################################################
#######################################################################################
				

---------------------------------------------------------
Consultes por zona: "$geoWithin"
---------------------------------------------------------

p1: [long: 1.4084163, lat: 42.6604899]
p2: [long: 1.833985, lat: 42.434998]

> db.cities.find({"loc": {
                  "$geoWithin": {
                      "$box": [ 
					            [1.4084163, 42.6604899], 
					            [1.833985, 42.434998]
							  ]
				     }
				 }
			   })

{
        "_id" : ObjectId("54579597e9cd9f37d7fcacd2"),
        "name" : "Sant Julià de Lòria",
        "country" : "AD",
        "timezone" : "Europe/Andorra",
        "population" : 8022,
        "loc" : {
                "longitude" : 1.49129,
                "latitude" : 42.46372
        }
}
{
        "_id" : ObjectId("54579597e9cd9f37d7fcacd3"),
        "name" : "Pas de la Casa",
        "country" : "AD",
        "timezone" : "Europe/Andorra",
        "population" : 2363,
        "loc" : {
                "longitude" : 1.73361,
                "latitude" : 42.54277
        }
}	

Polígons:
---------------------
Bahamas: [-77.53466,23.75975],[-77.78,23.71],[-78.03405,24.28615],[-78.40848,24.57564],[-78.19087,25.2103],[-77.89,25.17],[-77.54,24.34],[-77.53466,23.75975],[-77.82,26.58],[-78.91,26.42],[-78.98,26.79],[-78.51,26.87],[-77.85,26.84],[-77.82,26.58],[-77,26.59],[-77.17255,25.87918],[-77.35641,26.00735],[-77.34,26.53],[-77.78802,26.92516],[-77.79,27.04],[-77,26.59]
Cuba: [-82.268151,23.188611],[-81.404457,23.117271],[-80.618769,23.10598],[-79.679524,22.765303],[-79.281486,22.399202],[-78.347434,22.512166],[-77.993296,22.277194],[-77.146422,21.657851],[-76.523825,21.20682],[-76.19462,21.220565],[-75.598222,21.016624],[-75.67106,20.735091],[-74.933896,20.693905],[-74.178025,20.284628],[-74.296648,20.050379],[-74.961595,19.923435],[-75.63468,19.873774],[-76.323656,19.952891],[-77.755481,19.855481],[-77.085108,20.413354],[-77.492655,20.673105],[-78.137292,20.739949],[-78.482827,21.028613],[-78.719867,21.598114],[-79.285,21.559175],[-80.217475,21.827324],[-80.517535,22.037079],[-81.820943,22.192057],[-82.169992,22.387109],[-81.795002,22.636965],[-82.775898,22.68815],[-83.494459,22.168518],[-83.9088,22.154565],[-84.052151,21.910575],[-84.54703,21.801228],[-84.974911,21.896028],[-84.447062,22.20495],[-84.230357,22.565755],[-83.77824,22.788118],[-83.267548,22.983042],[-82.510436,23.078747],[-82.268151,23.188611]

db.cities.find({"loc": {
                  "$geoWithin": {
                      "$polygon": [
					     [-77.53466,23.75975],[-77.78,23.71],[-78.03405,24.28615],[-78.40848,24.57564],[-78.19087,25.2103],[-77.89,25.17],[-77.54,24.34],[-77.53466,23.75975],[-77.82,26.58],[-78.91,26.42],[-78.98,26.79],[-78.51,26.87],[-77.85,26.84],[-77.82,26.58],[-77,26.59],[-77.17255,25.87918],[-77.35641,26.00735],[-77.34,26.53],[-77.78802,26.92516],[-77.79,27.04],[-77,26.59]
					  ]
				  }
				}
			   })
			   
db.cities.find({"loc": {
                  "$geoWithin": {
                      "$polygon": [
					     [-82.268151,23.188611],[-81.404457,23.117271],[-80.618769,23.10598],[-79.679524,22.765303],[-79.281486,22.399202],[-78.347434,22.512166],[-77.993296,22.277194],[-77.146422,21.657851],[-76.523825,21.20682],[-76.19462,21.220565],[-75.598222,21.016624],[-75.67106,20.735091],[-74.933896,20.693905],[-74.178025,20.284628],[-74.296648,20.050379],[-74.961595,19.923435],[-75.63468,19.873774],[-76.323656,19.952891],[-77.755481,19.855481],[-77.085108,20.413354],[-77.492655,20.673105],[-78.137292,20.739949],[-78.482827,21.028613],[-78.719867,21.598114],[-79.285,21.559175],[-80.217475,21.827324],[-80.517535,22.037079],[-81.820943,22.192057],[-82.169992,22.387109],[-81.795002,22.636965],[-82.775898,22.68815],[-83.494459,22.168518],[-83.9088,22.154565],[-84.052151,21.910575],[-84.54703,21.801228],[-84.974911,21.896028],[-84.447062,22.20495],[-84.230357,22.565755],[-83.77824,22.788118],[-83.267548,22.983042],[-82.510436,23.078747],[-82.268151,23.188611]
					  ]
				  }
				}
			   })

	   

	-------------------------------------------------------------------------------------------
