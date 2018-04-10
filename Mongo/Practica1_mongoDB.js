
PRÀCTICA 1 : INTROCUCCIÓ AL MOGODB

1) Instal·lar MongoDB a Fedora 
	https://www.liquidweb.com/kb/how-to-install-mongodb-on-fedora-21/

2) Veure Rànkings de B.D.
	http://db-engines.com/en/ranking/document+store

3) Veure Curs MongoDB
	https://docs.mongodb.com/manual/tutorial/query-documents/

4) Des de la consola de mongo : 

	Entrar a la consola : mongo

		db -- B.D. en us
		show databases
		show collections
		use proves


	Insertar dades a la BD proves -- a la collection inventory:

		db.inventory.insert(
		   { item: "canvas", qty: 100, tags: ["cotton"], size: { h: 28, w: 35.5, uom: "cm" } }
		)

		show collections

		db.inventory.insert([
		   { item: "journal", qty: 25, tags: ["blank", "red"], size: { h: 14, w: 21, uom: "cm" } },
		   { item: "mat", qty: 85, tags: ["gray"], size: { h: 27.9, w: 35.5, uom: "cm" } },
		   { item: "mousepad", qty: 25, tags: ["gel", "blue"], size: { h: 19, w: 22.85, uom: "cm" } }
		])

		db.inventory.insert(
		   { item: "notebook", qty: 50, tags: ["red", "hard cover", "plain"], size: { h: 8.5, w: 11, uom: "in" } }
		)

		db.inventory.insert([
		   { item: "journal", qty: 25, size: { h: 14, w: 21, uom: "cm" }, status: "A" },
		   { item: "notebook", qty: 50, size: { h: 8.5, w: 11, uom: "in" }, status: "A" },
		   { item: "paper", qty: 100, size: { h: 8.5, w: 11, uom: "in" }, status: "D" },
		   { item: "planner", qty: 75, size: { h: 22.85, w: 30, uom: "cm" }, status: "D" },
		   { item: "postcard", qty: 45, size: { h: 10, w: 15.25, uom: "cm" }, status: "A" }
		]);

5) CONSULTES :

	SELECT * FROM inventory:

		db.inventory.find( {} )
		db.inventory.find()
		db.inventory.find().count()


	SELECT * FROM inventory WHERE status = "D"

		db.inventory.find( { status: "D" } )


	SELECT * FROM inventory WHERE status in ("A", "D")

		db.inventory.find( { status: { $in: [ "A", "D" ] } } )


	SELECT * FROM inventory WHERE status = "A" AND qty < 30

		db.inventory.find( { status: "A", qty: { $lt: 30 } } )


	SELECT * FROM inventory WHERE status = "A" OR qty < 30

		db.inventory.find( { $or: [ { status: "A" }, { qty: { $lt: 30 } } ] } )



	SELECT * FROM inventory WHERE status = "A" AND ( qty < 30 OR item LIKE "p%")

		db.inventory.find( {
		     status: "A",
		     $or: [ { qty: { $lt: 30 } }, { item: /^p/ } ]
		} )
		
		---> { item: /^p/ } 
				select * from users where name like '%m%' :
					db.users.find({"name": /.*m.*/}) // ilike '%m%' 
					db.users.find({"name": /m/}) // ilike '%m%' 
					db.users.find({ "name" : /m/i } ) // like '%m%' 
					db.users.find({name: /a/})  
					db.users.find({name: /^pa/}) // ilike 'pa%' 
					db.users.find({name: /ro$/}) // ilike '%ro'
					db.users.find({ name: { $regex: /.*m.*/i} })
 
		

6) OPERADORS PER CONSULTES:
	Operadors de comparació:

		Name	Description
		$eq	Matches values that are equal to a specified value.
		$gt	Matches values that are greater than a specified value.
		$gte	Matches values that are greater than or equal to a specified value.
		$lt	Matches values that are less than a specified value.
		$lte	Matches values that are less than or equal to a specified value.
		$ne	Matches all values that are not equal to a specified value.
		$in	Matches any of the values specified in an array.
		$nin	Matches none of the values specified in an array.

	Operadors lògics:
		Name	Description
		$or		Joins query clauses with a logical OR returns all documents that match the conditions of either clause.
		$and	Joins query clauses with a logical AND returns all documents that match the conditions of both clauses.
		$not	Inverts the effect of a query expression and returns documents that do not match the query expression.
		$nor	Joins query clauses with a logical NOR returns all documents that fail to match both clauses.

	Operadors de query:

		Name	Description
		$exists	Matches documents that have the specified field.
		$type	Selects documents if a field is of the specified type.

				db.records.find( { a: { $exists: true } } )
				db.records.find( { b: { $exists: false } } )


7) SUBCAMPS DELS CAMPS - CAMPS COMPOSTOS -  Documents dins de documents	
	Match an Embedded/Nested Document : documents dins de documents :

		db.inventory.find( { size: { h: 14, w: 21, uom: "cm" } } )
		
		Cal posar l''ordre dels sub-camps correctament!!!!

		db.inventory.find(  { size: { w: 21, h: 14, uom: "cm" } }  )

	Query on Nested Field
		db.inventory.find( { "size.uom": "in" } )

		db.inventory.find( { "size.h": { $lt: 15 } } )

		db.inventory.find( { "size.h": { $lt: 15 }, "size.uom": "in", status: "D" } )

8) CAMPS ARRAY
	Arrays a dins els documents:
		db.inventory.insert([
		   { item: "journal", qty: 25, tags: ["blank", "red"], dim_cm: [ 14, 21 ] },
		   { item: "notebook", qty: 50, tags: ["red", "blank"], dim_cm: [ 14, 21 ] },
		   { item: "paper", qty: 100, tags: ["red", "blank", "plain"], dim_cm: [ 14, 21 ] },
		   { item: "planner", qty: 75, tags: ["blank", "red"], dim_cm: [ 22.85, 30 ] },
		   { item: "postcard", qty: 45, tags: ["blue"], dim_cm: [ 10, 15.25 ] }
		]);

	queries for all documents where the field tags value is an array with exactly two elements, "red" and "blank", in the specified order:
		db.inventory.find( { tags: ["red", "blank"] } )

		db.inventory.find( { tags: ["blank", "red"] } )
		
	without regard to order or other elements in the array, use the $all operator:
		db.inventory.find( { tags: { $all: ["red", "blank"] } } )

	The following example queries for all documents where tags is an array that contains the string "red" as one of its elements:
		db.inventory.find( { tags: "red" } )

	Busquem documents amb un element de l'array dim_cm que cumpleixi la condició:
	db.inventory.find( { dim_cm: { $gt: 25 } } )
	
	Busquem documents amb un element de l'array dim_cm que cumpleixi la primera condició i
	amb un element de l'array dim_cm que cumpleixi la primera condició:
	db.inventory.find( { dim_cm: { $gt: 15, $lt: 20 } } ) ****************************Atenció
	db.inventory.find( { dim_cm: { $gt: 15, $lt: 16 } } ) ****************************Atenció
	db.inventory.find( { dim_cm: { $gt: 16, $lt: 16 } } ) ****************************Atenció
	
	The following example queries for documents where the dim_cm array contains at least
	one element that is both greater than ($gt) 22 and less than ($lt) 30:
	db.inventory.find( { dim_cm: { $elemMatch: { $gt: 22, $lt: 30 } } } )

	The following example queries for all documents where the second element
	in the array dim_cm is greater than 25:
	db.inventory.find( { "dim_cm.1": { $gt: 25 } } )
	
	db.inventory.find( { "tags": { $size: 3 } } )

	
9) CAMPS ARRAY DE CAMPS COMPOSTOS - ARRAYS DE DOCUMENTS
	Arrays de documents a dins els documents:
		db.inventory.insert( [
		   { item: "journal", instock: [ { warehouse: "A", qty: 5 }, { warehouse: "C", qty: 15 } ] },
		   { item: "notebook", instock: [ { warehouse: "C", qty: 5 } ] },
		   { item: "paper", instock: [ { warehouse: "A", qty: 60 }, { warehouse: "B", qty: 15 } ] },
		   { item: "planner", instock: [ { warehouse: "A", qty: 40 }, { warehouse: "B", qty: 5 } ] },
		   { item: "postcard", instock: [ { warehouse: "B", qty: 15 }, { warehouse: "C", qty: 35 } ] }
		]);


		Cal posar tot l'element que busquem :
		db.inventory.find( { "instock": { warehouse: "A", qty: 5 } } )

		Cal posar ordre correcte:
		db.inventory.find( { "instock": { qty: 5, warehouse: "A" } } )

		db.inventory.find( { 'instock.0.qty': { $lte: 20 } } )
		db.inventory.find( { 'instock.qty': { $lte: 14 } } )
		db.inventory.find( { "instock": { $elemMatch: { qty: 5, warehouse: "A" } } } )
		
		The following example queries for documents where the instock array has at least
		one embedded document that contains the field qty that is greater than 10 and less 
		than or equal to 20:
		
		db.inventory.find( { "instock": { $elemMatch: { qty: { $gt: 10, $lte: 20 } } } } ) --> 3 regs
		
		db.inventory.find( { "instock.qty": { $gt: 10, $lte: 20 } }  ) --> 4 regs ****************************Atenció
		
		db.inventory.find( {$and:	 [{ "instock.qty": {  $gt: 10  }}, { "instock.qty": {  $lte: 20 }} ]} ) -> 4 regs ****************************Atenció
		
		db.inventory.find( {$or:	 [{ "instock.qty": {  $gt: 10  }}, { "instock.qty": {  $lte: 20 }} ]} ) -> 5 regs 
		
		db.inventory.find( { "instock.qty": 5, "instock.warehouse": "A" } )

			{ "_id" : ObjectId("58c115b46d52fd77e4e8e147"), "item" : "journal", "instock" : [ { "warehouse" : "A", "qty" : 5 }, { "warehouse" : "C", "qty" : 15 } ] }
			{ "_id" : ObjectId("58c115b46d52fd77e4e8e14a"), "item" : "planner", "instock" : [ { "warehouse" : "A", "qty" : 40 }, { "warehouse" : "B", "qty" : 5 } ] }
 
		db.inventory.find( { "instock": { $elemMatch: { qty: 5, warehouse: 'A'  } } } )
			{ "_id" : ObjectId("58c115b46d52fd77e4e8e147"), "item" : "journal", "instock" : [ { "warehouse" : "A", "qty" : 5 }, { "warehouse" : "C", "qty" : 15 } ] }




