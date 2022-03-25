extends Control

class_name Inventory

onready var player : Character = GameManager.my_character as Character

func add_bag_item(item : Item, amount : int):
	$Bag.add_item(item, amount)

func update_inventory():
	player.set_inventory( $Bag.get_bag() )

func _ready():
	var equipement_list = [
		'Weapon1',
		'Weapon2',
		'Ring1',
		'Ring2',
		'Helmet',
		'Armor',
		'Legs',
		'Boots'
	]
	var attr : String = ''
	for equip in equipement_list:
		attr = '_'+equip.to_lower()
		get_node("Equipments/Panel/"+equip).add_child(player[attr])
		if player[attr].id > 0:
			player[attr].texture = load(player[attr].texture_path)
	
	if not player.inventory.empty():
		for dict in player.inventory:
			add_bag_item(Item.new().set_from_dict(dict), dict['amount'])
