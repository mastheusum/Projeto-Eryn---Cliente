extends CheckBox

var character_id : int
var character_name : String = ""
var character_level : int

func _ready():
	$GridContainer/Name.text = character_name
	$GridContainer/Level.text = str(character_level)
