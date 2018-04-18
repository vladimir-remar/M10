//INSERT, UPDATE, DELETE
//1) insert / insertMany
db.x.insertMany([...])
//UPDATE
//
//Parameter	Type	Description:
//query		document    The selection criteria for the update.
//update		document	The modifications to apply. For details see Update Parameter.
//upsert		boolean	Optional. If set to true, creates a new document when no document matches the query criteria. The default value is false, which does not insert a new document when no match is found.
//multi		boolean	Optional. If set to true, updates multiple documents that meet the query criteria. If set to false, updates one document. The default value is false. For additional information, see Multi Parameter.
//
//Update Operators
//$inc	Increments the value of the field by the specified amount.
//$mul	Multiplies the value of the field by the specified amount.
//$rename	Renames a field.
//$setOnInsert	Sets the value of a field if an update results in an insert of a document. Has no effect on update operations that modify existing documents.
//$set	Sets the value of a field in a document.
//$unset	Removes the specified field from a document.
//$min	Only updates the field if the specified value is less than the existing field value.
//$max	Only updates the field if the specified value is greater than the existing field value.
//$currentDate	Sets the value of a field to current date, either as a Date or a Timestamp.

//---update the first document 
db.inventory.updateOne(
   { item: "paper" },
   {
     $set: { "size.uom": "cm", status: "P" },
     $currentDate: { lastModified: true }
   }
)
//---update all documents
db.inventory.updateMany(
   { "qty": { $lt: 50 } },
   {
     $set: { "size.uom": "in", status: "P" },
     $currentDate: { lastModified: true }
   }
)
//---replace the first document 
db.inventory.replaceOne(
   { item: "paper" },
   { item: "paper", instock: [ { warehouse: "A", qty: 60 }, { warehouse: "B", qty: 40 } ] }
)

//4) DELETE:
//Delete All Documents that Match a Condition:
db.collection.deleteMany()
db.inventory.deleteMany({ status : "A" })

//Delete the first document
db.collection.deleteOne()
db.inventory.deleteOne( { status: "D" } )
//AGREEGATE
//PLANTILLA AGGREGATE
db.students.aggregate([
  {"$group":{}
  
  },
  {"$project":{}

  },
  {"$sort":{}

  }
])
//PLANTILLA UNWIND
db.books.aggregate([
  {"$unwind":},
  {"$group":{}
  },
  {"$project":{}
  },
  {"$sort":{}
  }
])
//3
db.students.aggregate([
	{$group:{
			"_id":"$birth_year",
			"nstudents":{"$sum":1}
		}
	},
	{"$project":{
		"_id":0,
		"year":"$_id",
		"students":"$nstudents"
		}	
	},
	{"$sort": {"year":-1}
		
	}
])

//4
db.students.aggregate([
	{"$group":{
		"_id":{
				"year":"$birth_year",
				"gender":"$gender"
			},
		"nstudents":{"$sum":1}
		}
	},
	{"$project":{
			"_id":0,
			"year":"$_id.year",
			"gender":"$_id.gender",
			"students":"$nstudents"
		}
	},
	{"$sort":{"year":-1}
	}
])
//5
db.students.aggregate([
	{"$group":{
		"_id":"$birth_year",
		"ntotales":{"$sum":1},
		"nmales":{"$sum":{"$cond":[{"$eq":["$gender","H"]},1,0]}},
		"nfemales":{"$sum":{"$cond":[{"$eq":["$gender","M"]},1,0]}}
		}
	},
	{"$project":{
		"_id":0,
		"year":"$_id",
		"total":"$ntotales",
		"males":"$nmales",
		"females":"$mfemales",
		"malesper":{"$multiply":[{"$divide":["$nmales","$ntotales" ]},100]},
		"femalesper":{"$multiply":[{"$divide":["$nfemales","$ntotales"]},100] }
		}
	},
	{"$sort":{"year":-1 }
	
	}
])
//6.1

db.stories.aggregate([
  {"$group":{
		"_id":"$user.name",
		"num_post":{"$sum":1},
		"total_diggs":{"$sum":"$diggs"},
		"avg_diggs":{"$avg":"$diggs"},
		"max_diggs":{"$max":"$diggs"},
		"min_diggs":{"$min":"$diggs"},
		"total_comments":{"$sum":"$comments"},
		"avg_comments":{"$avg":"$comments"},
		"max_comments":{"$max":"$comments"},
		"min_comments":{"$min":"$comments"},
		"posts":{
			"$push":{
					"title":"$title",
					"link":"$link",
					"diggs":"$diggs",
					"comments":"$comments"
				}
			}
		}
  },
  {"$sort":{"num_post":-1,"total_diggs":-1}
  }
])
//6.2
db.stories.aggregate([
  {"$group":{
		"_id":"$container.name",
		"nposts":{"$sum":1},
		"ndiggs":{"$sum":"$diggs"}
	}
  },
  {"$project":{
		"_id":0,
		"topic":"$_id",
		"posts":"$nposts",
		"diggs":"$ndiggs"
	}
  },
  {"$sort":{"topic":-1}
  }
])
//7
db.stories.aggregate([
  {"$group":{
    "_id":"$media",
    "nposts":{"$sum":1},
    "ndiggs":{"$sum":"$diggs"}
  }
  },
  {"$project":{
    "_id":0,
    "topic":"$_id",
    "posts":"$nposts",
    "diggs":"$ndiggs"
  }
  },
  {"$sort":{"topic":-1}
  }
])
//8
//PLANTILLA AGGREGATE
db.books.aggregate([
	{"$unwind":"$author"},
  {"$group":{
			"_id":"$author",
			"nbooks":{"$sum":1}
		}
  },
  {"$project":{
		"_id":0,
		"author":"$_id",
		"books":"$nbooks"
	}
  },
  {"$sort":{"books":-1}
  }
])
//9
db.movies.aggregate([
  {"$unwind":"$actors"},
  {"$group":{
			"_id":"$actors.name",
			"npelis":{"$sum":1},
			"lpelis":{"$push":"$name"}		
		}
  },
  {"$project":{
			"_id":0,
			"actor":"$_id",
			"movies":"$npelis",
			"catalog":"$lpelis"
		}
  },
  {"$sort":{"movies":-1}
  }
])
//10 NO CONCAT
db.movies.aggregate([
  {"$unwind":"$actors"},
  {"$group":{
			"_id":"$actors.name",
			"npelis":{"$sum":1},
			"last_peli":{"$max":"$year"},
			"first_peli":{"$min":"$year"},
			"duration":{"$sum":"$runtime"},
			"npelis":{"$push":"$name"}		
		}
  },
  {"$sort":{"npelis":-1}
  }
])
// 10 CONCAT
db.movies.aggregate([
	{"$sort": {"year": -1}},
	{"$unwind": "$actors"},
	{"$group": {
    "_id": "$actors.name",
    "nmovies": {"$sum": 1},
    "lyear": {"$max": "$year"},
    "fyear": {"$min": "$year"},
    "tduration": {"$sum": "$runtime"},
    "lmovies": {
				"$push": {
					"$concat": ["$name", " (", {"$substr": ["$year", 0, -1]}, ")"]
				}
			}
		}    
	},
	{"$sort": { "nmovies": -1}
	}		
])
//11
db.movies.aggregate([
  {"$unwind":"$directors"},
  {"$group":{
      "_id":"$directors.name",
      "npelis":{"$sum":1},
      "lpelis":{"$push":"$name"}
    }
  },
  {"$project":{
      "_id":0,
      "actor":"$_id",
      "movies":"$npelis",
      "catalog":"$lpelis"
    }
  },
  {"$sort":{"movies":-1}
  }
])
//12
db.movies.aggregate([
  {"$unwind":"$directors"},
  {"$group":{
      "_id":"$directors.name",
      "npelis":{"$sum":1},
      "last_peli":{"$max":"$year"},
      "first_peli":{"$min":"$year"},
      "duration":{"$sum":"$runtime"},
      "npelis":{"$push":"$name"}
    }
  },
  {"$sort":{"npelis":-1}
  }
]).pretty()
//13


