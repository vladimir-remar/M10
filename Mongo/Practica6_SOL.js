PRÀCTICA 6 - MONGODB
Aggregation

1) .count() i .distinct()

2) Aggregation Pipeline - GROUP BY : .aggregate + $group

{ "_id" : 1, "item" : "abc", "price" : 10, "quantity" : 2, "date" : ISODate("2014-03-01T08:00:00Z") }
{ "_id" : 2, "item" : "jkl", "price" : 20, "quantity" : 1, "date" : ISODate("2014-03-01T09:00:00Z") }
{ "_id" : 3, "item" : "xyz", "price" : 5, "quantity" : 10, "date" : ISODate("2014-03-15T09:00:00Z") }
{ "_id" : 4, "item" : "xyz", "price" : 5, "quantity" : 20, "date" : ISODate("2014-04-04T11:21:39.736Z") }
{ "_id" : 5, "item" : "abc", "price" : 10, "quantity" : 10, "date" : ISODate("2014-04-04T21:23:13.331Z") }

db.sales.aggregate(
   [
      {
        $group : {
           _id : { month: { $month: "$date" }, day: { $dayOfMonth: "$date" }, year: { $year: "$date" } },
           totalPrice: { $sum: { $multiply: [ "$price", "$quantity" ] } },
           averageQuantity: { $avg: "$quantity" },
           count: { $sum: 1 }
        }
      }
   ]
)

{ "_id" : { "month" : 3, "day" : 15, "year" : 2014 }, "totalPrice" : 50, "averageQuantity" : 10, "count" : 1 }
{ "_id" : { "month" : 4, "day" : 4, "year" : 2014 }, "totalPrice" : 200, "averageQuantity" : 15, "count" : 2 }
{ "_id" : { "month" : 3, "day" : 1, "year" : 2014 }, "totalPrice" : 40, "averageQuantity" : 1.5, "count" : 2 }

GROUP BY de tota la collection:
db.sales.aggregate(
   [
      {
        $group : {
           _id : null,
           totalPrice: { $sum: { $multiply: [ "$price", "$quantity" ] } },
           averageQuantity: { $avg: "$quantity" },
           count: { $sum: 1 }
        }
      }
   ]
)

{ "_id" : null, "totalPrice" : 290, "averageQuantity" : 8.6, "count" : 5 } 

3) Aggregation Pipeline DISTINCT amb $group i $push
{ "_id" : 8751, "title" : "The Banquet", "author" :		"Dante", "copies" : 2 }
{ "_id" : 8752, "title" : "Divine Comedy", "author" :	"Dante", "copies" : 1 }
{ "_id" : 8645, "title" : "Eclogues", "author" : 		"Dante", "copies" : 2 }
{ "_id" : 7000, "title" : "The Odyssey", "author" : 	"Homer", "copies" : 10 }
{ "_id" : 7020, "title" : "Iliad", "author" : 			"Homer", "copies" : 10 }

db.books.aggregate(
   [
     { $group : { _id : "$author", books: { $push: "$title" } } }
   ]
)

{ "_id" : "Homer", "books" : [ "The Odyssey", "Iliad" ] }
{ "_id" : "Dante", "books" : [ "The Banquet", "Divine Comedy", "Eclogues" ] }

4)Aggregation Pipeline DISTINCT amb $group i $push i { $push: "$$ROOT" }
db.books.aggregate(
   [
     { $group : { _id : "$author", books: { $push: "$$ROOT" } } }
   ]
)

{
  "_id" : "Homer",
  "books" :
     [
       { "_id" : 7000, "title" : "The Odyssey", "author" : "Homer", "copies" : 10 },
       { "_id" : 7020, "title" : "Iliad", "author" : "Homer", "copies" : 10 }
     ]
}

{
  "_id" : "Dante",
  "books" :
     [
       { "_id" : 8751, "title" : "The Banquet", "author" : "Dante", "copies" : 2 },
       { "_id" : 8752, "title" : "Divine Comedy", "author" : "Dante", "copies" : 1 },
       { "_id" : 8645, "title" : "Eclogues", "author" : "Dante", "copies" : 2 }
     ]
}

5) Aggregation Pipeline : .aggregate + $group + $match

{ "_id" : ObjectId("512bc95fe835e68f199c8686"), "author" : "dave", "score" : 80, "views" : 100 }
{ "_id" : ObjectId("512bc962e835e68f199c8687"), "author" : "dave", "score" : 85, "views" : 521 }
{ "_id" : ObjectId("55f5a192d4bede9ac365b257"), "author" : "ahn", "score" : 60, "views" : 1000 }
{ "_id" : ObjectId("55f5a192d4bede9ac365b258"), "author" : "li", "score" : 55, "views" : 5000 }
{ "_id" : ObjectId("55f5a1d3d4bede9ac365b259"), "author" : "annT", "score" : 60, "views" : 50 }
{ "_id" : ObjectId("55f5a1d3d4bede9ac365b25a"), "author" : "li", "score" : 94, "views" : 999 }
{ "_id" : ObjectId("55f5a1d3d4bede9ac365b25b"), "author" : "ty", "score" : 95, "views" : 1000 }

db.articles.aggregate( [
  { $match: { $or: [ { score: { $gt: 70, $lt: 90 } }, { views: { $gte: 1000 } } ] } },
  { $group: { _id: null, count: { $sum: 1 } } }
] );

{ "_id" : null, "count" : 5 }

6) Aggregation Pipeline : .aggregate + $group + $match + $project
{
  "_id" : 1,
  title: "abc123",
  isbn: "0001122223334",
  author: { last: "zzz", first: "aaa" },
  copies: 5
}

db.books.aggregate(
   [
      {
         $project: {
            title: 1,
            isbn: {
               prefix: { $substr: [ "$isbn", 0, 3 ] },
               group: { $substr: [ "$isbn", 3, 2 ] },
               publisher: { $substr: [ "$isbn", 5, 4 ] },
               title: { $substr: [ "$isbn", 9, 3 ] },
               checkDigit: { $substr: [ "$isbn", 12, 1] }
            },
            lastName: "$author.last",
            copiesSold: "$copies"
         }
      }
   ]
)

{
   "_id" : 1,
   "title" : "abc123",
   "isbn" : {
      "prefix" : "000",
      "group" : "11",
      "publisher" : "2222",
      "title" : "333",
      "checkDigit" : "4"
   },
   "lastName" : "zzz",
   "copiesSold" : 5
}

7) Aggregation Pipeline : .aggregate + $group + $match + $project + $unwind

{ "_id" : 1, "item" : "ABC1", sizes: [ "S", "M", "L"] }

db.inventory.aggregate( [ { $unwind : "$sizes" } ] )

{ "_id" : 1, "item" : "ABC1", "sizes" : "S" }
{ "_id" : 1, "item" : "ABC1", "sizes" : "M" }
{ "_id" : 1, "item" : "ABC1", "sizes" : "L" }

8) Aggregation Pipeline : .aggregate + $group + $match + $project + $unwind + $cond

db.inventory.aggregate(
   [
      {
         $project:
           {
             item: 1,
             discount:
               {
                 $cond: [ { $gte: [ "$qty", 250 ] }, 30, 20 ]
               }
           }
      }
   ]
)

9) Mètode GROUP BY : Map-Reduce

Exercicis :
C O L L E C T I O N: students
1) Quants homes i quantes dones
	{ "gender" : "H", "students" : 2895 }
	{ "gender" : "M", "students" : 348 }

					db.students.aggregate([
					  {
						  "$group": {
							   "_id": "$gender",
							   "num": {"$sum": 1}
						   }
					  },
					  {
						  "$project": {
							   "_id": false,
							   "gender": "$_id",
							   "students": "$num"
						   }
					  },
					  {
						  "$sort": { "students": -1}
					  }
					])
					
2) Quants homes i quantes dones + description

	{ "gender" : "H", "description": "Hombre", "students" : 2895 }
	{ "gender" : "M", "description" : "Mujer", "students" : 348 }
	
	
			db.students.aggregate([
			  {
				  "$group": {
					   "_id": "$gender",
					   "num": {"$sum": 1}
				   }
			  },
			  {
				  "$project": {
					   "_id": false,
					   "gender": "$_id",
					   "description": {"$cond": [ { $eq: [ "$_id", "H" ]} , "Hombre", "Mujer"]},
					   "students": "$num"
				   }
			  },
			  {
				  "$sort": { "students": -1}
			  }
			])
			
3)
{ "year" : 1993, "students" : 97 }
{ "year" : 1992, "students" : 100 }
{ "year" : 1991, "students" : 92 }
{ "year" : 1990, "students" : 98 }
{ "year" : 1989, "students" : 69 }
{ "year" : 1988, "students" : 87 }

db.students.aggregate([
   {
       "$group": {
              "_id": "$birth_year",
             "num": {"$sum": 1}
         }
    },
    {
       "$project": {
              "_id": false,
              "year": "$_id",
              "students": "$num"
        }
    },
    {
        "$sort": { "year": -1}
    }
])
4)
{ "year" : 1993, "gender" : "M", "students" : 16 }
{ "year" : 1993, "gender" : "H", "students" : 81 }
{ "year" : 1992, "gender" : "M", "students" : 13 }
{ "year" : 1992, "gender" : "H", "students" : 87 }
{ "year" : 1991, "gender" : "M", "students" : 9 }


db.students.aggregate([
  {
     "$group": {
        "_id": { "year": "$birth_year",
                 "gender": "$gender"
               },
        "num": {"$sum": 1}
     }
  },
  {
    "$project": {
        "_id": false,
        "year": "$_id.year",
        "gender": "$_id.gender",
        "students": "$num"
     }
  },
  {
    "$sort": { "year": -1, "gender": -1}
  }
])
5)
{
        "year" : 1993,
        "total" : 97,
        "males" : 81,
        "females" : 16,
        "malesper" : 83.50515463917526,
        "femalesper" : 16.49484536082474
}
{
        "year" : 1992,
        "total" : 100,
        "males" : 87,
        "females" : 13, 
        "malesper" : 87,
        "femalesper" : 13
}

db.students.aggregate([
{
   "$group": {
      "_id": "$birth_year",
      "ntotal": {"$sum": 1},
      "nmales": {"$sum": {"$cond": [ {"$eq": ["$gender","H"]}, 1, 0]}},
      "nfemales": {"$sum": {"$cond": [ {"$eq": ["$gender","M"]}, 1, 0]}}
  
   }
},
{
  "$project": {
      "_id": false,
      "year": "$_id",
      "total": "$ntotal",
      "males": "$nmales",
      "females": "$nfemales",
      "malesper": {"$multiply": [{"$divide": ["$nmales", "$ntotal"]} , 100]},
      "femalesper": {"$multiply": [{"$divide": ["$nfemales", "$ntotal"]}, 100]}
   }
},
{
  "$sort": { "year": -1}
}
]).pretty()

D A T A B A S E: digg | C O L L E C T I O N: stories
6.1)
{ 
    "_id" : "duphregne79",
    "num_posts" : 22.0,
    "total_diggs" : 9714.0,
    "avg_diggs" : 441.545454545455,
    "max_diggs" : 1560.0,
    "min_diggs" : 255.0,
    "total_comments" : 1523.0,
    "avg_comments" : 69.2272727272727,
    "max_comments" : 374.0,
    "min_comments" : 9.0,
    "posts" : [ 
           { 
                "title" : "\"I Am The Hero That Gotham Deserves!\"",
                "link" : "http://digg.com/people/I_Am_The_Hero_That_Gotham_Deserves",
                "diggs" : 1284.0,
                "comments" : 80.0
           }, 
           ….
}

db.stories.aggregate([
                   {"$sort": {"comments": -1}},
                   {                      
		      "$group":  {
                               "_id": "$user.name",
                               "num_posts": {"$sum": 1},
                               "total_diggs": {"$sum": "$diggs"},
                               "avg_diggs": {"$avg": "$diggs"},
                               "max_diggs": {"$max": "$diggs"},
                               "min_diggs": {"$min": "$diggs"},
                              "total_comments": {"$sum": "$comments"},
                               "avg_comments": {"$avg": "$comments"},
                               "max_comments": {"$max": "$comments"},
                               "min_comments": {"$min": "$comments"},
                               "posts": {
                                     "$push": {
                                           "title": "$title",
                                           "link": "$href",
                                           "diggs": "$diggs",
                                            "comments": "$comments"
                                      }
                                }
                           }
                      },
                      {"$sort": {"num_posts": -1, "total_diggs": -1}} 
]).pretty()
6.2)
{ "topic" : "World & Business", "posts" : 1352, "diggs" : 705218 }
{ "topic" : "Technology", "posts" : 950, "diggs" : 538823 }
{ "topic" : "Sports", "posts" : 512, "diggs" : 189717 }
{ "topic" : "Science", "posts" : 744, "diggs" : 364793 }
{ "topic" : "Offbeat", "posts" : 1229, "diggs" : 1224387 }
{ "topic" : "Lifestyle", "posts" : 854, "diggs" : 423166 }
{ "topic" : "Gaming", "posts" : 355, "diggs" : 213795 }
{ "topic" : "Entertainment", "posts" : 907, "diggs" : 573872 }

db.stories.aggregate([
                      {
                        "$group": {
                            "_id": "$container.name", 
                            "nposts": {"$sum": 1},
                            "ndiggs": {"$sum": "$diggs"}
                        }
                      },
                      {
                        "$project": {
                           "_id": false, 
                           "topic": "$_id", 
                           "posts": "$nposts",
                           "diggs": "$ndiggs"
                        }
                      },
                      {
                        "$sort": {"topic": -1}
                      }
])


7){ "topic" : "videos", "posts" : 705, "diggs" : 475874 }
{ "topic" : "news", "posts" : 5005, "diggs" : 2383442 }
{ "topic" : "images", "posts" : 1193, "diggs" : 1374455 }

db.stories.aggregate([
                      {
                        "$group": {
                            "_id": "$media", 
                            "nposts": {"$sum": 1},
                            "ndiggs": {"$sum": "$diggs"}
                        }
                      },
                      {
                        "$project": {
                           "_id": false, 
                           "topic": "$_id", 
                           "posts": "$nposts",
                           "diggs": "$ndiggs"
                        }
                      },
                      {
                        "$sort": {"topic": -1}
                      }
])


D A T A B A S E: edx | C O L L E C T I O N: books
8) 
{ "author" : "Andrew Hunt", "books" : 6 }
{ "author" : "David Thomas", "books" : 6 }
{ "author" : "Kent Beck", "books" : 5 }
{ "author" : "Martin Fowler", "books" : 4 }
{ "author" : "Chad Fowler", "books" : 4 }
{ "author" : "Venkat Subramaniam", "books" : 4 }
{ "author" : "Brian W. Kernighan", "books" : 4 }
{ "author" : "Donald Ervin Knuth", "books" : 4 }
{ "author" : "James A. Whittaker", "books" : 3 }
{ "author" : "Alistair Cockburn", "books" : 3 }
{ "author" : "Bruce Schneier", "books" : 3 }
{ "author" : "David Heinemeier Hansson", "books" : 3 }
{ "author" : "Malcolm Gladwell", "books" : 3 }
{ "author" : "Johanna Rothman", "books" : 3 }
{ "author" : "Robert C. Martin", "books" : 3 }
{ "author" : "Gerald M. Weinberg", "books" : 3 }
{ "author" : "Brian P. Hogan", "books" : 2 }
{ "author" : "Mary Poppendieck", "books" : 2 }
{ "author" : "Christian Heilmann", "books" : 2 }
{ "author" : "Bill Dudney", "books" : 2 }

db.books.aggregate([
                 {"$unwind": "$author"}, 
                 {"$group": {"_id": "$author", "nbooks": {"$sum": 1}}}, 
                 {"$project": {"_id": false, "author": "$_id", "books": "$nbooks"}}, 
                 {"$sort": {"books": -1}}
])

D A T A B A S E: imdb | C O L L E C T I O N: movies 
9)
{ "actor" : "Tom Cruise", "movies" : 13, "catalog" : [ "Color of Money, The", "Top Gun", "Rain Man", "Born on the Fourth of July", "Few Good Men, A", "Firm, The", "Jerry Maguire", "Mission: Impossible", "Mission: Impossible II", "Minority Report", "Mission: Impossible III", "War of the Worlds", "Mission: Impossible - Ghost Protocol" ] }
{ "actor" : "Tom Hanks", "movies" : 11, "catalog" : [ "Philadelphia", "Forrest Gump", "Apollo 13", "Toy Story", "Toy Story 2", "Green Mile, The", "Saving Private Ryan", "Catch Me If You Can", "The Polar Express", "The Da Vinci Code", "Toy Story 3" ] }
{ "actor" : "Harrison Ford", "movies" : 10, "catalog" : [ "Star Wars", "Star Wars: Episode V - The Empire Strikes Back", "Raiders of the Lost Ark", "Star Wars: Episode VI - Return of the Jedi", "Indiana Jones and the Temple of Doom", "Indiana Jones and the Last Crusade", "Fugitive, The", "Air Force One", "What Lies Beneath", "Indiana Jones and the Kingdom of the Crystal Skull" ] }
{ "actor" : "Will Smith", "movies" : 10, "catalog" : [ "Men in Black", "Men in Black II", "Bad Boys II", "Shark Tale", "I, Robot", "Hitch", "Hancock", "The Pursuit of Happyness", "I Am Legend", "Men in Black 3" ] }
{ "actor" : "Robert De Niro", "movies" : 9, "catalog" : [ "Godfather: Part II, The", "Deer Hunter, The", "Raging Bull", "Untouchables, The", "Goodfellas", "Meet the Parents", "Meet the Fockers", "Shark Tale", "Silver Linings Playbook" ] }
{ "actor" : "Jack Nicholson", "movies" : 9, "catalog" : [ "One Flew Over the Cuckoo's Nest", "Reds", "Terms of Endearment", "Prizzi's Honor", "Batman", "Few Good Men, A", "As Good As It Gets", "Anger Management", "The Departed" ] }
{ "actor" : "Dustin Hoffman", "movies" : 9, "catalog" : [ "Graduate, The", "Midnight Cowboy", "All the President's Men", "Kramer vs. Kramer", "Tootsie", "Rain Man", "Meet the Fockers", "Kung Fu Panda", "Kung Fu Panda 2" ] }
{ "actor" : "Tommy Lee Jones", "movies" : 9, "catalog" : [ "Coal Miner's Daughter", "Fugitive, The", "Blue Sky", "Batman Forever", "Men in Black", "Men in Black II", "Captain America: The First Avenger", "No Country for Old Men", "Men in Black 3" ] }
{ "actor" : "Mel Gibson", "movies" : 9, "catalog" : [ "Year of Living Dangerously, The", "Lethal Weapon 2", "Lethal Weapon 3", "Braveheart", "Pocahontas", "Ransom", "Lethal Weapon 4", "What Women Want", "Signs" ] }
{ "actor" : "Joe Pesci", "movies" : 8, "catalog" : [ "Raging Bull", "Lethal Weapon 2", "Goodfellas", "Home Alone", "Home Alone 2: Lost in New York", "Lethal Weapon 3", "My Cousin Vinny", "Lethal Weapon 4" ] }
{ "actor" : "Ben Stiller", "movies" : 8, "catalog" : [ "There's Something About Mary", "Meet the Parents", "Meet the Fockers", "Madagascar", "Night at the Museum", "Madagascar: Escape 2 Africa", "Night at the Museum: Battle of the Smithsonian", "Madagascar 3: Europe's Most Wanted" ] }
{ "actor" : "Eddie Murphy", "movies" : 8, "catalog" : [ "Beverly Hills Cop", "Beverly Hills Cop II", "Doctor Dolittle", "Shrek", "Shrek 2", "Shrek the Third", "Dreamgirls", "Shrek Forever After" ] }
{ "actor" : "Ralph Fiennes", "movies" : 8, "catalog" : [ "Schindler's List", "English Patient, The", "The Constant Gardener", "Clash of the Titans", "The Hurt Locker", "The Reader", "Skyfall", "Harry Potter and the Deathly Hallows: Part 2" ] }
{ "actor" : "Daniel Radcliffe", "movies" : 8, "catalog" : [ "Harry Potter and the Sorcerer's Stone", "Harry Potter and the Chamber of Secrets", "Harry Potter and the Prisoner of Azkaban", "Harry Potter and the Goblet of Fire", "Harry Potter and the Order of the Phoenix", "Harry Potter and the Half-Blood Prince", "Harry Potter and the Deathly Hallows: Part 1", "Harry Potter and the Deathly Hallows: Part 2" ] }
{ "actor" : "Robert Duvall", "movies" : 7, "catalog" : [ "To Kill a Mockingbird", "True Grit", "Godfather, The", "Godfather: Part II, The", "Network", "Tender Mercies", "Deep Impact" ] }
{ "actor" : "Jon Voight", "movies" : 7, "catalog" : [ "Midnight Cowboy", "Coming Home", "Mission: Impossible", "Lara Croft: Tomb Raider", "Pearl Harbor", "National Treasure", "National Treasure: Book of Secrets" ] }
{ "actor" : "Meryl Streep", "movies" : 7, "catalog" : [ "Deer Hunter, The", "Kramer vs. Kramer", "Sophie's Choice", "Out of Africa", "Adaptation.", "Hours, The", "The Iron Lady" ] }
{ "actor" : "Burt Lancaster", "movies" : 7, "catalog" : [ "Come Back, Little Sheba", "From Here to Eternity", "Rose Tattoo, The", "Separate Tables", "Elmer Gantry", "Judgment at Nuremberg", "Airport" ] }
{ "actor" : "Jane Fonda", "movies" : 7, "catalog" : [ "Cat Ballou", "They Shoot Horses, Don't They?", "Klute", "Julia", "California Suite", "Coming Home", "On Golden Pond" ] }
{ "actor" : "Morgan Freeman", "movies" : 7, "catalog" : [ "Driving Miss Daisy", "Glory", "Robin Hood: Prince of Thieves", "Unforgiven", "Deep Impact", "Bruce Almighty", "Million Dollar Baby" ] }

> db.movies.aggregate([
              {"$unwind": "$actors"},
              {"$group": {"_id": "$actors.name", "nmovies": {"$sum": 1}, "lmovies": {"$push": "$name"}}}, 
              {"$project": {"_id": 0, "actor": "$_id", "movies": "$nmovies", "catalog" : "$lmovies"}}, 
              {"$sort": {"movies": -1}}
])

10)

"_id" : "Tom Cruise",
    "nmovies" : 13.0,
    "lyear" : 2011,
    "fyear" : 1986,
    "tduration" : 1690,
    "lmovies" : [ 
        "Mission: Impossible - Ghost Protocol (2011)", 
        "Mission: Impossible III (2006)", 
        "War of the Worlds (2005)", 
        "Minority Report (2002)", 
        "Mission: Impossible II (2000)", 
        "Jerry Maguire (1996)", 
        "Mission: Impossible (1996)", 
        "Firm, The (1993)", 
        "Few Good Men, A (1992)", 
        "Born on the Fourth of July (1989)", 
        "Rain Man (1988)", 
        "Color of Money, The (1986)", 
        "Top Gun (1986)"
    ]

db.movies.aggregate([
   {"$sort": {"year": -1}},
   {"$unwind": "$actors"},
   {"$group": {
        "_id": "$actors.name",
        "nmovies": {"$sum": 1},
        "lyear": {"$max": "$year"},
        "fyear": {"$min": "$year"},
        "tduration": {"$sum": "$runtime"},
        "lmovies": {"$push": {"$concat": ["$name", " (", {"$substr": ["$year", 0, -1]}, ")"]}}
      }    
   },
   {
       "$sort": { "nmovies": -1}
   }
])
	
11)

{ "director" : "Steven Spielberg", "movies" : 14, "catalog" : [ "Jaws", "Raiders of the Lost Ark", "E.T. the Extra-Terrestrial", "Indiana Jones and the Temple of Doom", "Indiana Jones and the Last Crusade", "Jurassic Park", "Schindler's List", "Lost World: Jurassic Park, The", "Saving Private Ryan", "Minority Report", "Catch Me If You Can", "Indiana Jones and the Kingdom of the Crystal Skull", "War of the Worlds", "Lincoln" ] }
{ "director" : "William Wyler", "movies" : 9, "catalog" : [ "Jezebel", "Westerner, The", "Mrs. Miniver", "Best Years of Our Lives, The", "Heiress, The", "Roman Holiday", "Big Country, The", "Ben-Hur", "Funny Girl" ] }
{ "director" : "Michael Bay", "movies" : 7, "catalog" : [ "Rock, The", "Armageddon", "Bad Boys II", "Pearl Harbor", "Transformers", "Transformers: Revenge of the Fallen", "Transformers: Dark of the Moon" ] }
{ "director" : "John Ford", "movies" : 6, "catalog" : [ "Informer, The", "Stagecoach", "Grapes of Wrath, The", "How Green Was My Valley", "Quiet Man, The", "Mister Roberts" ] }
{ "director" : "Elia Kazan", "movies" : 6, "catalog" : [ "Tree Grows in Brooklyn, A", "Gentleman's Agreement", "Streetcar Named Desire, A", "Viva Zapata!", "On the Waterfront", "East of Eden" ] }
{ "director" : "Martin Scorsese", "movies" : 6, "catalog" : [ "Alice Doesn't Live Here Anymore", "Raging Bull", "Color of Money, The", "Goodfellas", "The Aviator", "The Departed" ] }
{ "director" : "Robert Zemeckis", "movies" : 6, "catalog" : [ "Back to the Future", "Who Framed Roger Rabbit", "Forrest Gump", "What Lies Beneath", "Cast Away", "The Polar Express" ] }
{ "director" : "Ron Howard", "movies" : 6, "catalog" : [ "Cocoon", "Apollo 13", "Ransom", "How the Grinch Stole Christmas", "Beautiful Mind, A", "The Da Vinci Code" ] }
{ "director" : "Tim Burton", "movies" : 6, "catalog" : [ "Batman", "Batman Returns", "Ed Wood", "Planet of the Apes", "Charlie and the Chocolate Factory", "Alice in Wonderland" ] }
{ "director" : "George Cukor", "movies" : 5, "catalog" : [ "Philadelphia Story, The", "Gaslight", "Double Life, A", "Born Yesterday", "My Fair Lady" ] }
{ "director" : "Woody Allen", "movies" : 5, "catalog" : [ "Annie Hall", "Hannah and Her Sisters", "Bullets Over Broadway", "Mighty Aphrodite", "Vicky Cristina Barcelona" ] }
{ "director" : "Chris Columbus", "movies" : 5, "catalog" : [ "Home Alone", "Home Alone 2: Lost in New York", "Mrs. Doubtfire", "Harry Potter and the Sorcerer's Stone", "Harry Potter and the Chamber of Secrets" ] }
{ "director" : "Peter Jackson", "movies" : 5, "catalog" : [ "Lord of the Rings: The Fellowship of the Ring, The", "Lord of the Rings: The Return of the King, The", "Lord of the Rings: The Two Towers, The", "King Kong", "The Hobbit: An Unexpected Journey" ] }
{ "director" : "Vincente Minnelli", "movies" : 4, "catalog" : [ "American in Paris, An", "Bad and the Beautiful, The", "Lust for Life", "Gigi" ] }
{ "director" : "Sydney Pollack", "movies" : 4, "catalog" : [ "They Shoot Horses, Don't They?", "Tootsie", "Out of Africa", "Firm, The" ] }
{ "director" : "Bryan Singer", "movies" : 4, "catalog" : [ "Usual Suspects, The", "X-Men", "X2", "Superman Returns" ] }
{ "director" : "George Stevens", "movies" : 4, "catalog" : [ "More the Merrier, The", "Place in the Sun, A", "Giant", "Diary of Anne Frank, The" ] }
{ "director" : "Billy Wilder", "movies" : 4, "catalog" : [ "Lost Weekend, The", "Stalag 17", "Apartment, The", "Fortune Cookie, The" ] }
{ "director" : "John Huston", "movies" : 4, "catalog" : [ "Key Largo", "Treasure of the Sierra Madre, The", "African Queen, The", "Prizzi's Honor" ] }
{ "director" : "Fred Zinnemann", "movies" : 4, "catalog" : [ "High Noon", "From Here to Eternity", "Man for All Seasons, A", "Julia" ] }

 db.movies.aggregate([
              {"$unwind": "$directors"},
              {"$group": {"_id": "$directors.name", "nmovies": {"$sum": 1}, "lmovies": {"$push": "$name"}}}, 
              {"$project": {"_id": 0, "director": "$_id", "movies": "$nmovies", "catalog" : "$lmovies"}}, 
              {"$sort": {"movies": -1}}
])

12)

{
    "_id" : "Steven Spielberg",
    "nmovies" : 14.0,
    "lyear" : 2012,
    "fyear" : 1975,
    "tduration" : 1896,
    "lmovies" : [ 
        "Lincoln (2012)", 
        "Indiana Jones and the Kingdom of the Crystal Skull (2008)", 
        "War of the Worlds (2005)", 
        "Minority Report (2002)", 
        "Catch Me If You Can (2002)", 
        "Saving Private Ryan (1998)", 
        "Lost World: Jurassic Park, The (1997)", 
        "Jurassic Park (1993)", 
        "Schindler's List (1993)", 
        "Indiana Jones and the Last Crusade (1989)", 
        "Indiana Jones and the Temple of Doom (1984)", 
        "E.T. the Extra-Terrestrial (1982)", 
        "Raiders of the Lost Ark (1981)", 
        "Jaws (1975)"
    ]
}

db.movies.aggregate([
   {"$sort": {"year": -1}},
   {"$unwind": "$directors"},
   {"$group": {
        "_id": "$directors.name",
        "nmovies": {"$sum": 1},
        "lyear": {"$max": "$year"},
        "fyear": {"$min": "$year"},
        "tduration": {"$sum": "$runtime"},
        "lmovies": {"$push": {"$concat": ["$name", " (", {"$substr": ["$year", 0, -1]}, ")"]}}
      }    
   },
   {
       "$sort": { "nmovies": -1}
   }
])

############################################################################################################################################################
############################################################################################################################################################
#####################  					D A T A B A S E: digg | C O L L E C T I O N: stories                           #####################
############################################################################################################################################################
############################################################################################################################################################

{ "gender" : "H", "students" : 2895 }
{ "gender" : "M", "students" : 348 }


db.students.aggregate([
  {
      "$group": {
           "_id": "$gender",
           "num": {"$sum": 1}
       }
  },
  {
      "$project": {
           "_id": false,
           "gender": "$_id",
           "students": "$num"
       }
  },
  {
      "$sort": { "students": -1}
  }
])


############################################################################################################################################################
############################################################################################################################################################


{ "gender" : "H", "description": "Hombre", "students" : 2895 }
{ "gender" : "M", "description" : "Mujer", "students" : 348 }

db.students.aggregate([
  {
      "$group": {
           "_id": "$gender",
           "num": {"$sum": 1}
       }
  },
  {
      "$project": {
           "_id": false,
           "gender": "$_id",
           "description": {"$cond": [ { $eq: [ "$_id", "H" ]} , "Hombre", "Mujer"]},
           "students": "$num"
       }
  },
  {
      "$sort": { "students": -1}
  }
])

############################################################################################################################################################
############################################################################################################################################################

{ "year" : 1993, "students" : 97 }
{ "year" : 1992, "students" : 100 }
{ "year" : 1991, "students" : 92 }
{ "year" : 1990, "students" : 98 }
{ "year" : 1989, "students" : 69 }
{ "year" : 1988, "students" : 87 }

db.students.aggregate([
   {
       "$group": {
              "_id": "$birth_year",
             "num": {"$sum": 1}
         }
    },
    {
       "$project": {
              "_id": false,
              "year": "$_id",
              "students": "$num"
        }
    },
    {
        "$sort": { "year": -1}
    }
])

############################################################################################################################################################
############################################################################################################################################################

{ "year" : 1993, "gender" : "M", "students" : 16 }
{ "year" : 1993, "gender" : "H", "students" : 81 }
{ "year" : 1992, "gender" : "M", "students" : 13 }
{ "year" : 1992, "gender" : "H", "students" : 87 }
{ "year" : 1991, "gender" : "M", "students" : 9 }

db.students.aggregate([
  {
     "$group": {
        "_id": { "year": "$birth_year",
                 "gender": "$gender"
               },
        "num": {"$sum": 1}
     }
  },
  {
    "$project": {
        "_id": false,
        "year": "$_id.year",
        "gender": "$_id.gender",
        "students": "$num"
     }
  },
  {
    "$sort": { "year": -1, "gender": -1}
  }
])

############################################################################################################################################################
############################################################################################################################################################

{
        "year" : 1993,
        "total" : 97,
        "males" : 81,
        "females" : 16,
        "malesper" : 83.50515463917526,
        "femalesper" : 16.49484536082474
}
{
        "year" : 1992,
        "total" : 100,
        "males" : 87,
        "females" : 13, 
        "malesper" : 87,
        "femalesper" : 13
}

db.students.aggregate([
  {
     "$group": {
        "_id": "$birth_year",
        "ntotal": {"$sum": 1},
        "nmales": {"$sum": {"$cond": [ {"$eq": ["$gender","H"]}, 1, 0]}},
        "nfemales": {"$sum": {"$cond": [ {"$eq": ["$gender","M"]}, 1, 0]}},
     }
  },
  {
    "$project": {
        "_id": false,
        "year": "$_id",
        "total": "$ntotal",
        "males": "$nmales",
        "females": "$nfemales",
        "malesper": {"$multiply": [{"$divide": ["$nmales", "$ntotal"]} , 100]},
        "femalesper": {"$multiply": [{"$divide": ["$nfemales", "$ntotal"]}, 100]}
     }
  },
  {
    "$sort": { "year": -1}
  }
]).pretty()


############################################################################################################################################################
############################################################################################################################################################

{ 
    "_id" : "duphregne79",
    "num_posts" : 22.0,
    "total_diggs" : 9714.0,
    "avg_diggs" : 441.545454545455,
    "max_diggs" : 1560.0,
    "min_diggs" : 255.0,
    "total_comments" : 1523.0,
    "avg_comments" : 69.2272727272727,
    "max_comments" : 374.0,
    "min_comments" : 9.0,
    "posts" : [ 
           { 
                "title" : "\"I Am The Hero That Gotham Deserves!\"",
                "link" : "http://digg.com/people/I_Am_The_Hero_That_Gotham_Deserves",
                "diggs" : 1284.0,
                "comments" : 80.0
           }, 
           ….
}

db.stories.aggregate([
                   {"$sort": {"comments": -1}},
                   {                      
		      "$group":  {
                               "_id": "$user.name",
                               "num_posts": {"$sum": 1},
                               "total_diggs": {"$sum": "$diggs"},
                               "avg_diggs": {"$avg": "$diggs"},
                               "max_diggs": {"$max": "$diggs"},
                               "min_diggs": {"$min": "$diggs"},
                              "total_comments": {"$sum": "$comments"},
                               "avg_comments": {"$avg": "$comments"},
                               "max_comments": {"$max": "$comments"},
                               "min_comments": {"$min": "$comments"},
                               "posts": {
                                     "$push": {
                                           "title": "$title",
                                           "link": "$href",
                                           "diggs": "$diggs",
                                            "comments": "$comments"
                                      }
                                }
                           }
                      },
                      {"$sort": {"num_posts": -1, "total_diggs": -1}} 
]).pretty()

############################################################################################################################################################
############################################################################################################################################################


{ "topic" : "World & Business", "posts" : 1352, "diggs" : 705218 }
{ "topic" : "Technology", "posts" : 950, "diggs" : 538823 }
{ "topic" : "Sports", "posts" : 512, "diggs" : 189717 }
{ "topic" : "Science", "posts" : 744, "diggs" : 364793 }
{ "topic" : "Offbeat", "posts" : 1229, "diggs" : 1224387 }
{ "topic" : "Lifestyle", "posts" : 854, "diggs" : 423166 }
{ "topic" : "Gaming", "posts" : 355, "diggs" : 213795 }
{ "topic" : "Entertainment", "posts" : 907, "diggs" : 573872 }

db.stories.aggregate([
                      {
                        "$group": {
                            "_id": "$container.name", 
                            "nposts": {"$sum": 1},
                            "ndiggs": {"$sum": "$diggs"}
                        }
                      },
                      {
                        "$project": {
                           "_id": false, 
                           "topic": "$_id", 
                           "posts": "$nposts",
                           "diggs": "$ndiggs"
                        }
                      },
                      {
                        "$sort": {"topic": -1}
                      }
])

############################################################################################################################################################
############################################################################################################################################################

{ "topic" : "videos", "posts" : 705, "diggs" : 475874 }
{ "topic" : "news", "posts" : 5005, "diggs" : 2383442 }
{ "topic" : "images", "posts" : 1193, "diggs" : 1374455 }

db.stories.aggregate([
                      {
                        "$group": {
                            "_id": "$media", 
                            "nposts": {"$sum": 1},
                            "ndiggs": {"$sum": "$diggs"}
                        }
                      },
                      {
                        "$project": {
                           "_id": false, 
                           "topic": "$_id", 
                           "posts": "$nposts",
                           "diggs": "$ndiggs"
                        }
                      },
                      {
                        "$sort": {"topic": -1}
                      }
])


############################################################################################################################################################
############################################################################################################################################################
#####################  					D A T A B A S E: edx | C O L L E C T I O N: books                              #####################
############################################################################################################################################################
############################################################################################################################################################

{ "author" : "Andrew Hunt", "books" : 6 }
{ "author" : "David Thomas", "books" : 6 }
{ "author" : "Kent Beck", "books" : 5 }
{ "author" : "Martin Fowler", "books" : 4 }
{ "author" : "Chad Fowler", "books" : 4 }
{ "author" : "Venkat Subramaniam", "books" : 4 }
{ "author" : "Brian W. Kernighan", "books" : 4 }
{ "author" : "Donald Ervin Knuth", "books" : 4 }
{ "author" : "James A. Whittaker", "books" : 3 }
{ "author" : "Alistair Cockburn", "books" : 3 }
{ "author" : "Bruce Schneier", "books" : 3 }
{ "author" : "David Heinemeier Hansson", "books" : 3 }
{ "author" : "Malcolm Gladwell", "books" : 3 }
{ "author" : "Johanna Rothman", "books" : 3 }
{ "author" : "Robert C. Martin", "books" : 3 }
{ "author" : "Gerald M. Weinberg", "books" : 3 }
{ "author" : "Brian P. Hogan", "books" : 2 }
{ "author" : "Mary Poppendieck", "books" : 2 }
{ "author" : "Christian Heilmann", "books" : 2 }
{ "author" : "Bill Dudney", "books" : 2 }

> db.books.aggregate([
                 {"$unwind": "$author"}, 
                 {"$group": {"_id": "$author", "nbooks": {"$sum": 1}}}, 
                 {"$project": {"_id": false, "author": "$_id", "books": "$nbooks"}}, 
                 {"$sort": {"books": -1}}
])


############################################################################################################################################################
############################################################################################################################################################
#####################  					D A T A B A S E: imdb | C O L L E C T I O N: movies                            #####################
############################################################################################################################################################
############################################################################################################################################################


{ "actor" : "Tom Cruise", "movies" : 13, "catalog" : [ "Color of Money, The", "Top Gun", "Rain Man", "Born on the Fourth of July", "Few Good Men, A", "Firm, The", "Jerry Maguire", "Mission: Impossible", "Mission: Impossible II", "Minority Report", "Mission: Impossible III", "War of the Worlds", "Mission: Impossible - Ghost Protocol" ] }
{ "actor" : "Tom Hanks", "movies" : 11, "catalog" : [ "Philadelphia", "Forrest Gump", "Apollo 13", "Toy Story", "Toy Story 2", "Green Mile, The", "Saving Private Ryan", "Catch Me If You Can", "The Polar Express", "The Da Vinci Code", "Toy Story 3" ] }
{ "actor" : "Harrison Ford", "movies" : 10, "catalog" : [ "Star Wars", "Star Wars: Episode V - The Empire Strikes Back", "Raiders of the Lost Ark", "Star Wars: Episode VI - Return of the Jedi", "Indiana Jones and the Temple of Doom", "Indiana Jones and the Last Crusade", "Fugitive, The", "Air Force One", "What Lies Beneath", "Indiana Jones and the Kingdom of the Crystal Skull" ] }
{ "actor" : "Will Smith", "movies" : 10, "catalog" : [ "Men in Black", "Men in Black II", "Bad Boys II", "Shark Tale", "I, Robot", "Hitch", "Hancock", "The Pursuit of Happyness", "I Am Legend", "Men in Black 3" ] }
{ "actor" : "Robert De Niro", "movies" : 9, "catalog" : [ "Godfather: Part II, The", "Deer Hunter, The", "Raging Bull", "Untouchables, The", "Goodfellas", "Meet the Parents", "Meet the Fockers", "Shark Tale", "Silver Linings Playbook" ] }
{ "actor" : "Jack Nicholson", "movies" : 9, "catalog" : [ "One Flew Over the Cuckoo's Nest", "Reds", "Terms of Endearment", "Prizzi's Honor", "Batman", "Few Good Men, A", "As Good As It Gets", "Anger Management", "The Departed" ] }
{ "actor" : "Dustin Hoffman", "movies" : 9, "catalog" : [ "Graduate, The", "Midnight Cowboy", "All the President's Men", "Kramer vs. Kramer", "Tootsie", "Rain Man", "Meet the Fockers", "Kung Fu Panda", "Kung Fu Panda 2" ] }
{ "actor" : "Tommy Lee Jones", "movies" : 9, "catalog" : [ "Coal Miner's Daughter", "Fugitive, The", "Blue Sky", "Batman Forever", "Men in Black", "Men in Black II", "Captain America: The First Avenger", "No Country for Old Men", "Men in Black 3" ] }
{ "actor" : "Mel Gibson", "movies" : 9, "catalog" : [ "Year of Living Dangerously, The", "Lethal Weapon 2", "Lethal Weapon 3", "Braveheart", "Pocahontas", "Ransom", "Lethal Weapon 4", "What Women Want", "Signs" ] }
{ "actor" : "Joe Pesci", "movies" : 8, "catalog" : [ "Raging Bull", "Lethal Weapon 2", "Goodfellas", "Home Alone", "Home Alone 2: Lost in New York", "Lethal Weapon 3", "My Cousin Vinny", "Lethal Weapon 4" ] }
{ "actor" : "Ben Stiller", "movies" : 8, "catalog" : [ "There's Something About Mary", "Meet the Parents", "Meet the Fockers", "Madagascar", "Night at the Museum", "Madagascar: Escape 2 Africa", "Night at the Museum: Battle of the Smithsonian", "Madagascar 3: Europe's Most Wanted" ] }
{ "actor" : "Eddie Murphy", "movies" : 8, "catalog" : [ "Beverly Hills Cop", "Beverly Hills Cop II", "Doctor Dolittle", "Shrek", "Shrek 2", "Shrek the Third", "Dreamgirls", "Shrek Forever After" ] }
{ "actor" : "Ralph Fiennes", "movies" : 8, "catalog" : [ "Schindler's List", "English Patient, The", "The Constant Gardener", "Clash of the Titans", "The Hurt Locker", "The Reader", "Skyfall", "Harry Potter and the Deathly Hallows: Part 2" ] }
{ "actor" : "Daniel Radcliffe", "movies" : 8, "catalog" : [ "Harry Potter and the Sorcerer's Stone", "Harry Potter and the Chamber of Secrets", "Harry Potter and the Prisoner of Azkaban", "Harry Potter and the Goblet of Fire", "Harry Potter and the Order of the Phoenix", "Harry Potter and the Half-Blood Prince", "Harry Potter and the Deathly Hallows: Part 1", "Harry Potter and the Deathly Hallows: Part 2" ] }
{ "actor" : "Robert Duvall", "movies" : 7, "catalog" : [ "To Kill a Mockingbird", "True Grit", "Godfather, The", "Godfather: Part II, The", "Network", "Tender Mercies", "Deep Impact" ] }
{ "actor" : "Jon Voight", "movies" : 7, "catalog" : [ "Midnight Cowboy", "Coming Home", "Mission: Impossible", "Lara Croft: Tomb Raider", "Pearl Harbor", "National Treasure", "National Treasure: Book of Secrets" ] }
{ "actor" : "Meryl Streep", "movies" : 7, "catalog" : [ "Deer Hunter, The", "Kramer vs. Kramer", "Sophie's Choice", "Out of Africa", "Adaptation.", "Hours, The", "The Iron Lady" ] }
{ "actor" : "Burt Lancaster", "movies" : 7, "catalog" : [ "Come Back, Little Sheba", "From Here to Eternity", "Rose Tattoo, The", "Separate Tables", "Elmer Gantry", "Judgment at Nuremberg", "Airport" ] }
{ "actor" : "Jane Fonda", "movies" : 7, "catalog" : [ "Cat Ballou", "They Shoot Horses, Don't They?", "Klute", "Julia", "California Suite", "Coming Home", "On Golden Pond" ] }
{ "actor" : "Morgan Freeman", "movies" : 7, "catalog" : [ "Driving Miss Daisy", "Glory", "Robin Hood: Prince of Thieves", "Unforgiven", "Deep Impact", "Bruce Almighty", "Million Dollar Baby" ] }

> db.movies.aggregate([
              {"$unwind": "$actors"},
              {"$group": {"_id": "$actors.name", "nmovies": {"$sum": 1}, "lmovies": {"$push": "$name"}}}, 
              {"$project": {"_id": 0, "actor": "$_id", "movies": "$nmovies", "catalog" : "$lmovies"}}, 
              {"$sort": {"movies": -1}}
])

############################################################################################################################################################
############################################################################################################################################################

"_id" : "Tom Cruise",
    "nmovies" : 13.0,
    "lyear" : 2011,
    "fyear" : 1986,
    "tduration" : 1690,
    "lmovies" : [ 
        "Mission: Impossible - Ghost Protocol (2011)", 
        "Mission: Impossible III (2006)", 
        "War of the Worlds (2005)", 
        "Minority Report (2002)", 
        "Mission: Impossible II (2000)", 
        "Jerry Maguire (1996)", 
        "Mission: Impossible (1996)", 
        "Firm, The (1993)", 
        "Few Good Men, A (1992)", 
        "Born on the Fourth of July (1989)", 
        "Rain Man (1988)", 
        "Color of Money, The (1986)", 
        "Top Gun (1986)"
    ]


db.movies.aggregate([
   {"$sort": {"year": -1}},
   {"$unwind": "$actors"},
   {"$group": {
        "_id": "$actors.name",
        "nmovies": {"$sum": 1},
        "lyear": {"$max": "$year"},
        "fyear": {"$min": "$year"},
        "tduration": {"$sum": "$runtime"},
        "lmovies": {"$push": {"$concat": ["$name", " (", {"$substr": ["$year", 0, -1]}, ")"]}}
      }    
   },
   {
       "$sort": { "nmovies": -1}
   }
])

############################################################################################################################################################
############################################################################################################################################################

{ "director" : "Steven Spielberg", "movies" : 14, "catalog" : [ "Jaws", "Raiders of the Lost Ark", "E.T. the Extra-Terrestrial", "Indiana Jones and the Temple of Doom", "Indiana Jones and the Last Crusade", "Jurassic Park", "Schindler's List", "Lost World: Jurassic Park, The", "Saving Private Ryan", "Minority Report", "Catch Me If You Can", "Indiana Jones and the Kingdom of the Crystal Skull", "War of the Worlds", "Lincoln" ] }
{ "director" : "William Wyler", "movies" : 9, "catalog" : [ "Jezebel", "Westerner, The", "Mrs. Miniver", "Best Years of Our Lives, The", "Heiress, The", "Roman Holiday", "Big Country, The", "Ben-Hur", "Funny Girl" ] }
{ "director" : "Michael Bay", "movies" : 7, "catalog" : [ "Rock, The", "Armageddon", "Bad Boys II", "Pearl Harbor", "Transformers", "Transformers: Revenge of the Fallen", "Transformers: Dark of the Moon" ] }
{ "director" : "John Ford", "movies" : 6, "catalog" : [ "Informer, The", "Stagecoach", "Grapes of Wrath, The", "How Green Was My Valley", "Quiet Man, The", "Mister Roberts" ] }
{ "director" : "Elia Kazan", "movies" : 6, "catalog" : [ "Tree Grows in Brooklyn, A", "Gentleman's Agreement", "Streetcar Named Desire, A", "Viva Zapata!", "On the Waterfront", "East of Eden" ] }
{ "director" : "Martin Scorsese", "movies" : 6, "catalog" : [ "Alice Doesn't Live Here Anymore", "Raging Bull", "Color of Money, The", "Goodfellas", "The Aviator", "The Departed" ] }
{ "director" : "Robert Zemeckis", "movies" : 6, "catalog" : [ "Back to the Future", "Who Framed Roger Rabbit", "Forrest Gump", "What Lies Beneath", "Cast Away", "The Polar Express" ] }
{ "director" : "Ron Howard", "movies" : 6, "catalog" : [ "Cocoon", "Apollo 13", "Ransom", "How the Grinch Stole Christmas", "Beautiful Mind, A", "The Da Vinci Code" ] }
{ "director" : "Tim Burton", "movies" : 6, "catalog" : [ "Batman", "Batman Returns", "Ed Wood", "Planet of the Apes", "Charlie and the Chocolate Factory", "Alice in Wonderland" ] }
{ "director" : "George Cukor", "movies" : 5, "catalog" : [ "Philadelphia Story, The", "Gaslight", "Double Life, A", "Born Yesterday", "My Fair Lady" ] }
{ "director" : "Woody Allen", "movies" : 5, "catalog" : [ "Annie Hall", "Hannah and Her Sisters", "Bullets Over Broadway", "Mighty Aphrodite", "Vicky Cristina Barcelona" ] }
{ "director" : "Chris Columbus", "movies" : 5, "catalog" : [ "Home Alone", "Home Alone 2: Lost in New York", "Mrs. Doubtfire", "Harry Potter and the Sorcerer's Stone", "Harry Potter and the Chamber of Secrets" ] }
{ "director" : "Peter Jackson", "movies" : 5, "catalog" : [ "Lord of the Rings: The Fellowship of the Ring, The", "Lord of the Rings: The Return of the King, The", "Lord of the Rings: The Two Towers, The", "King Kong", "The Hobbit: An Unexpected Journey" ] }
{ "director" : "Vincente Minnelli", "movies" : 4, "catalog" : [ "American in Paris, An", "Bad and the Beautiful, The", "Lust for Life", "Gigi" ] }
{ "director" : "Sydney Pollack", "movies" : 4, "catalog" : [ "They Shoot Horses, Don't They?", "Tootsie", "Out of Africa", "Firm, The" ] }
{ "director" : "Bryan Singer", "movies" : 4, "catalog" : [ "Usual Suspects, The", "X-Men", "X2", "Superman Returns" ] }
{ "director" : "George Stevens", "movies" : 4, "catalog" : [ "More the Merrier, The", "Place in the Sun, A", "Giant", "Diary of Anne Frank, The" ] }
{ "director" : "Billy Wilder", "movies" : 4, "catalog" : [ "Lost Weekend, The", "Stalag 17", "Apartment, The", "Fortune Cookie, The" ] }
{ "director" : "John Huston", "movies" : 4, "catalog" : [ "Key Largo", "Treasure of the Sierra Madre, The", "African Queen, The", "Prizzi's Honor" ] }
{ "director" : "Fred Zinnemann", "movies" : 4, "catalog" : [ "High Noon", "From Here to Eternity", "Man for All Seasons, A", "Julia" ] }

> db.movies.aggregate([
              {"$unwind": "$directors"},
              {"$group": {"_id": "$directors.name", "nmovies": {"$sum": 1}, "lmovies": {"$push": "$name"}}}, 
              {"$project": {"_id": 0, "director": "$_id", "movies": "$nmovies", "catalog" : "$lmovies"}}, 
              {"$sort": {"movies": -1}}
])

############################################################################################################################################################
############################################################################################################################################################

{
    "_id" : "Steven Spielberg",
    "nmovies" : 14.0,
    "lyear" : 2012,
    "fyear" : 1975,
    "tduration" : 1896,
    "lmovies" : [ 
        "Lincoln (2012)", 
        "Indiana Jones and the Kingdom of the Crystal Skull (2008)", 
        "War of the Worlds (2005)", 
        "Minority Report (2002)", 
        "Catch Me If You Can (2002)", 
        "Saving Private Ryan (1998)", 
        "Lost World: Jurassic Park, The (1997)", 
        "Jurassic Park (1993)", 
        "Schindler's List (1993)", 
        "Indiana Jones and the Last Crusade (1989)", 
        "Indiana Jones and the Temple of Doom (1984)", 
        "E.T. the Extra-Terrestrial (1982)", 
        "Raiders of the Lost Ark (1981)", 
        "Jaws (1975)"
    ]
}

db.movies.aggregate([
   {"$sort": {"year": -1}},
   {"$unwind": "$directors"},
   {"$group": {
        "_id": "$directors.name",
        "nmovies": {"$sum": 1},
        "lyear": {"$max": "$year"},
        "fyear": {"$min": "$year"},
        "tduration": {"$sum": "$runtime"},
        "lmovies": {"$push": {"$concat": ["$name", " (", {"$substr": ["$year", 0, -1]}, ")"]}}
      }    
   },
   {
       "$sort": { "nmovies": -1}
   }
])

