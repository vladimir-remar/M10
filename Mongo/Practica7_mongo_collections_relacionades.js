Document Usuari amb adreces incloses (embbedded)
{
   "_id":ObjectId("52ffc33cd85242f436000001") ,
   "contact" : "987654321" ,
   "dob" : "01-01-1991" ,
   "name" : "Tom Benzamin" ,
   "address" : [
      {
         "building" : "22 A, Indiana Apt" ,
         "pincode" : 123456,
         "city" : "Los Angeles" ,
         "state" : "California"
      },
      {
         "building" : "170 A, Acropolis Apt" ,
         "pincode" : 456789,
         "city" : "Chicago" ,
         "state" : "Illinois"
      }
   ]
} 

Document Usuari :
{
   "_id":ObjectId("52ffc33cd85242f436000001") ,
   "name" : "Tom Hanks" ,
   "contact" : "987654321" ,
   "dob" : "01-01-1991"
}

Document adreça :
db.address.insert({
   "_id":ObjectId("52ffc4a5d85242602e000000") ,
   "building" : "22 A, Indiana Apt" ,
   "pincode" : 123456,
   "city" : "Los Angeles" ,
   "state" : "California"
})

Document Usuari relacionat amb adreces
db.users.insert({
   "_id":ObjectId("52ffc33cd85242f436000001") ,
   "contact" : "987654321" ,
   "dob" : "01-01-1991" ,
   "name" : "Tom Benzamin" ,
   "address_ids" : [
      ObjectId("52ffc4a5d85242602e000000") ,
      ObjectId("52ffc4a5d85242602e000001")
   ]
})

>var result = db.users.findOne({"name":"Tom Benzamin"},{"address_ids":1})
>result
>var addresses = db.address.find({"_id":{"$in":result["address_ids"]}})
>addressses
