extends Control

class_name Inventory

onready var player : Character = GameManager.my_character as Character

func add_bag_item(item : Item, amount : int):
	$Bag.add_item(item, amount)

func update_inventory():
	player.set_inventory( $Bag.get_bag() )

func _ready():
	connect("updated_inventory", self, "_update_inventory")
	
	if player._weapon1:
		$Equipments/Panel/Weapon1.add_child(player._weapon1)
	if player._weapon2:
		$Equipments/Panel/Weapon2 .add_child(player._weapon2)
	if player._ring1:
		$Equipments/Panel/Ring1.add_child(player._ring1)
	if player._ring2:
		$Equipments/Panel/Ring2.add_child(player._ring2)
	if player._helmet:
		$Equipments/Panel/Helmet.add_child(player._helmet)
	if player._armor:
		$Equipments/Panel/Armor .add_child(player._armor)
	if player._legs:
		$Equipments/Panel/Legs.add_child(player._legs)
	if player._boots:
		$Equipments/Panel/Boots.add_child(player._boots)
	
	if not player.inventory.empty():
		for dict in player.inventory:
			add_bag_item(Item.new().dict_to(dict), dict['amount'])
