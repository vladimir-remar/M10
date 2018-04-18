PRÀCTICA 5 - MONGODB
CRUD : Create + Read + Update + Delete

1) insert / insertMany
db.inventory.insertMany([
   { item: "journal", qty: 25, tags: ["blank", "red"], size: { h: 14, w: 21, uom: "cm" } },
   { item: "mat", qty: 85, tags: ["gray"], size: { h: 27.9, w: 35.5, uom: "cm" } },
   { item: "mousepad", qty: 25, tags: ["gel", "blue"], size: { h: 19, w: 22.85, uom: "cm" } }
])

2) update

	db.collection.update(

		<query>,

		<update>,

		{

		upsert: <boolean>,

		multi: <boolean>


		}

	))
	

Parameter	Type	Description
query		document    The selection criteria for the update.
update		document	The modifications to apply. For details see Update Parameter.
upsert		boolean	Optional. If set to true, creates a new document when no document matches the query criteria. The default value is false, which does not insert a new document when no match is found.
multi		boolean	Optional. If set to true, updates multiple documents that meet the query criteria. If set to false, updates one document. The default value is false. For additional information, see Multi Parameter.

Update Operators
Name	Description
$inc	Increments the value of the field by the specified amount.
$mul	Multiplies the value of the field by the specified amount.
$rename	Renames a field.
$setOnInsert	Sets the value of a field if an update results in an insert of a document. Has no effect on update operations that modify existing documents.
$set	Sets the value of a field in a document.
$unset	Removes the specified field from a document.
$min	Only updates the field if the specified value is less than the existing field value.
$max	Only updates the field if the specified value is greater than the existing field value.
$currentDate	Sets the value of a field to current date, either as a Date or a Timestamp.

3)
db.inventory.insertMany( [
   { item: "canvas", qty: 100, size: { h: 28, w: 35.5, uom: "cm" }, status: "A" },
   { item: "journal", qty: 25, size: { h: 14, w: 21, uom: "cm" }, status: "A" },
   { item: "mat", qty: 85, size: { h: 27.9, w: 35.5, uom: "cm" }, status: "A" },
   { item: "mousepad", qty: 25, size: { h: 19, w: 22.85, uom: "cm" }, status: "P" },
   { item: "notebook", qty: 50, size: { h: 8.5, w: 11, uom: "in" }, status: "P" },
   { item: "paper", qty: 100, size: { h: 8.5, w: 11, uom: "in" }, status: "D" },
   { item: "planner", qty: 75, size: { h: 22.85, w: 30, uom: "cm" }, status: "D" },
   { item: "postcard", qty: 45, size: { h: 10, w: 15.25, uom: "cm" }, status: "A" },
   { item: "sketchbook", qty: 80, size: { h: 14, w: 21, uom: "cm" }, status: "A" },
   { item: "sketch pad", qty: 95, size: { h: 22.85, w: 30.5, uom: "cm" }, status: "A" }
]);

---update the first document 
db.inventory.updateOne(
   { item: "paper" },
   {
     $set: { "size.uom": "cm", status: "P" },
     $currentDate: { lastModified: true }
   }
)

---update all documents
db.inventory.updateMany(
   { "qty": { $lt: 50 } },
   {
     $set: { "size.uom": "in", status: "P" },
     $currentDate: { lastModified: true }
   }
)

---replace the first document 
db.inventory.replaceOne(
   { item: "paper" },
   { item: "paper", instock: [ { warehouse: "A", qty: 60 }, { warehouse: "B", qty: 40 } ] }
)

4) DELETE:
Delete All Documents that Match a Condition:
db.collection.deleteMany()
db.inventory.deleteMany({ status : "A" })

Delete the first document 
db.collection.deleteOne()
db.inventory.deleteOne( { status: "D" } )

Exercicis
1) Canviar els noms dels estudiants que es diuen "Mikel" per "Miky"

db.students.updateOne({ "name": "Mikel" },{$set: { "name": "Miky"},$currentDate: { lastModified: true }})
db.students.updateMany({ "name": "Mikel" },{$set: { "name": "Miky"},$currentDate: { lastModified: true }})

2) Incrementar, a tweets, en un el número de followers dels usuaris que tenen més de 50000 amics (12). Mirar $inc.
db.tweets.find({"user.friends_count":{$gt:50000}}).count()
db.tweets.updateMany({ "user.friends_count":{$gt:50000} },{$inc: {"user.followers_count":1},$currentDate: { lastModified: true }})


3) Decrementar, a tweets, en un el número de followers dels usuaris que tenen més de 50000 amics (12).
db.tweets.updateMany({ "user.friends_count":{$gt:50000} },{$inc: {"user.followers_count":-1},$currentDate: { lastModified: true }})

4) Mofificar, a tweets, el número d'amics dels usuaris : si el número de seguidors és més alt que el número 
d'amics, posar com a número d'amics el número de seguidors. Mirar $max.

test1 = function(){
	return typeof(this.user) == "object" && this.user != null && this.user.followers_count > this.user.friends_count;
}
db.books.find(test1)

5) Crear la B.D. INSTA a MongoDB : 
5.1) Una Collection o dues?
5.2) Quins atributs tindran els documents
5.3) Escriu exemples de 3 usuaris amb 2 posts cadascú (cada psots amb 2 likes), amb 2 seguidors i amb 2 usuaris seguits.
