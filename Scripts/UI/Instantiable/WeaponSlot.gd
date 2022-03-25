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
		var item : Item = data['item']
		var quantity = data['amount']
		var sender = data['sender']
		
		if sender == 'bag':
			if int(item.two_handed) == 1:
				if player['_'+get_node(slot2).name.to_lower()].id > 0:
					player['_'+get_node(slot2).name.to_lower()].restart()
					inventory.add_bag_item(player['_'+get_node(slot2).name.to_lower()], 1)
			if player['_'+name.to_lower()].id > 0:
				player['_'+name.to_lower()].restart()
				inventory.add_bag_item(player['_'+name.to_lower()], 1)
			item.get_parent().modify_amount( -1 )
			player['_'+name.to_lower()] = player['_'+name.to_lower()].set_from_dict(item.as_dict())
		else:
			if player['_'+name.to_lower()].id > 0:
				var tmp : Item = player['_'+name.to_lower()]
				player['_'+name.to_lower()] = player['_'+get_node(slot2).name.to_lower()]
				player['_'+get_node(slot2).name.to_lower()] = tmp
		
		remove_child(get_child(0))
		get_node(slot2).remove_child(get_node(slot2).get_child(0))
		
		add_child(player['_'+name.to_lower()])
		get_node(slot2).add_child(player['_'+get_node(slot2).name.to_lower()])
		
		if player['_weapon1'].id > 0:
			player['_weapon1'].texture = load(player['_weapon1'].texture_path)
		if player['_weapon2'].id > 0:
			player['_weapon2'].texture = load(player['_weapon2'].texture_path)
		
		inventory.call_deferred("update_inventory")
		player.set_equipment('_weapon1')
		player.set_equipment('_weapon2')

