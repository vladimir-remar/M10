more_than_2 = function(){
	return typeof(this.awards) == "object" && this.awards != null && this.awards.length > 2;
}
db.bios.find(more_than_2);
