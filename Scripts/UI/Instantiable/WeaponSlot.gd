extends Panel

class_name WeaponSlot

onready var player : Character = GameManager.my_character as Character
onready var inventory : Inventory = GameManager.my_character.get_node('CanvasLayer/Inventory') as Inventory
export (Item.Types) var accepted_item_type
export var slot2 : NodePath

func get_drag_data(position):
	if get_child(0):
		var dragged_item = TextureRect.new()
		dragged_item.texture = (get_child(0) as Item).texture
		
		set_drag_preview(dragged_item)
		
		return {'item':get_child(0),'amount':1,'sender':'equipment'}
	return {}

func can_drop_data(position, data):
	if not data.empty():
		var result : bool = get_node(slot2).get_child_count() == 0 || get_node(slot2).get_child(0).two_handed == 0
		return data['item'].type == accepted_item_type and result
	return false

func drop_data(position, data):
	if not data.empty():
		var weapon1 : Item = null if get_child_count() == 0 else get_child(0)
		var weapon2 : Item = null if get_node(slot2).get_child_count() == 0 else get_node(slot2).get_child(0)
		
		var item : Item = data['item']
		var quantity = data['amount']
		var sender = data['sender']
		
		if sender == 'bag':
			if int(item.two_handed) == 1:
				if weapon2:
					get_node(slot2).remove_child(weapon2)
					inventory.add_bag_item(weapon2, 1)
			if weapon1:
				remove_child(weapon1)
				inventory.add_bag_item(weapon1, 1)
			item.get_parent().modify_amount( -1 )
			var new_item = Item.new()
			new_item.dict_to(item.as_dict())
			add_child( new_item )
		else:
			if weapon1:
				remove_child(weapon1)
				item.get_parent().add_child( weapon1 )
			item.get_parent().remove_child( item )
			add_child( item )
		
		weapon1 = null if get_child_count() == 0 else get_child(0)
		weapon2 = null if get_node(slot2).get_child_count() == 0 else get_node(slot2).get_child(0)
		
		player.set_equipment('_'+self.name.to_lower(), weapon1)
		player.set_equipment('_'+get_node(slot2).name.to_lower(), weapon2)
		inventory.call_deferred("update_inventory")

