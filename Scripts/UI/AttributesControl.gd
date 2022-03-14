extends Control

onready var character : Character = get_parent().get_parent() as Character

func _ready():
	character.connect("update_attribute", self, "_update_attribute")
	_update_attribute()

func _update_attribute():
	$AttributePoints.bbcode_text = "\n[center]Points: " + str(character.attribute_points)
	$Strength/Text.bbcode_text = "[center]Strength " + str(character.strength)
	$Constitution/Text.bbcode_text = "[center]Constitution " + str(character.constitution)
	$Dexterity/Text.bbcode_text = "[center]Dexterity " + str(character.dexterity)
	$Agility/Text.bbcode_text = "[center]agility " + str(character.agility)
	$Intelligence/Text.bbcode_text = "[center]Intelligence " + str(character.intelligence)
	$Willpower/Text.bbcode_text = "[center]Willpower " + str(character.willpower)
	$Perception/Text.bbcode_text = "[center]Perception " + str(character.perception)
	$Wisdom/Text.bbcode_text = "[center]Wisdom " + str(character.wisdom)
	for i in range(2, get_child_count()):
		(get_child(i).get_node("Button") as Button).disabled = not character.attribute_points > 0

func _on_Strength_pressed():
	ConnectionManager.rpc_id(1, "update_status", int(character.name), "strength", character.strength)

func _on_Constitution_pressed():
	ConnectionManager.rpc_id(1, "update_status", int(character.name), "constitution", character.constitution)

func _on_Dexterity_pressed():
	ConnectionManager.rpc_id(1, "update_status", int(character.name), "dexterity", character.dexterity)

func _on_Agility_pressed():
	ConnectionManager.rpc_id(1, "update_status", int(character.name), "agility", character.agility)

func _on_Intelligence_pressed():
	ConnectionManager.rpc_id(1, "update_status", int(character.name), "intelligence", character.intelligence)

func _on_Willpower_pressed():
	ConnectionManager.rpc_id(1, "update_status", int(character.name), "willpower", character.willpower)

func _on_Perception_pressed():
	ConnectionManager.rpc_id(1, "update_status", int(character.name), "perception", character.perception)

func _on_Wisdom_pressed():
	ConnectionManager.rpc_id(1, "update_status", int(character.name), "wisdom", character.wisdom)
