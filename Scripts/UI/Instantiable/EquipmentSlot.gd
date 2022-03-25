extends Panel

class_name EquipmentSlot

onready var player : Character = GameManager.my_character as Character
onready var inventory : Inventory = GameManager.my_character.get_node('CanvasLayer/Inventory') as Inventory
export (Item.Types) var accepted_item_type

func get_drag_data(position):
	if get_child(0):
		var dragged_item = TextureRect.new()
		dragged_item.texture = (get_child(0) as Item).texture
		
		set_drag_preview(dragged_item)
		
		return {'item':get_child(0),'amount':1,'sender':'equipment'}
	return {}

func can_drop_data(position, data):
	if not data.empty():
		return data['item'].type == accepted_item_type
	return false

func drop_data(position, data):
	if not data.empty():
		var item : Item = data['item']
		var quantity = data['amount']
		var sender = data['sender']
		
		var equi_ref : Item = player['_'+self.name.to_lower()]
		
		if equi_ref.id > 0:
			inventory.add_bag_item(Item.new().set_from_dict(equi_ref.as_dict()) , 1)
			equi_ref.restart()
		
		player['_'+self.name.to_lower()].set_from_dict(item.as_dict())
		(player['_'+self.name.to_lower()] as Item).texture = load( (player['_'+self.name.to_lower()] as Item).texture_path )
		
		inventory.call_deferred("update_inventory")
		player.set_equipment('_'+self.name.to_lower())
