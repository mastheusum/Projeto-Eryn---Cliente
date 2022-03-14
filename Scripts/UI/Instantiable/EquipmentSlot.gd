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
		
		if sender == 'bag':
			var child = get_child(1)
			if child:
				remove_child(child)
				inventory.add_bag_item(child, 1)
			item.get_parent().modify_amount( -1 )
			var new_item = Item.new()
			new_item.dict_to(item.as_dict())
			add_child( new_item )
		else:
			var child = get_child(1)
			if child:
				remove_child(child)
				item.get_parent().add_child( child )
			item.get_parent().remove_child( item )
			add_child( item )
		player.set('_'+self.name.to_lower(), item)
