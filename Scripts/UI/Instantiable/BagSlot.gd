extends Panel

class_name BagSlot

onready var player : Character = GameManager.my_character as Character
onready var inventory = GameManager.my_character.get_node('CanvasLayer/Inventory') as Inventory
var amount : int = 0

func get_drag_data(position):
	if get_child(1):
		var dragged_item = TextureRect.new()
		dragged_item.texture = (get_child(1) as Item).texture
		
		set_drag_preview(dragged_item)
		
		return {'item':get_child(1),'amount':amount,'sender':'bag'}
	return {}

func can_drop_data(position, data):
	return not data.empty()

func drop_data(position, data):
	if not data.empty():
		var item : Item = data['item']
		var quantity = data['amount']
		var sender = data['sender']
		
		if sender == 'bag':
			if get_child_count() > 1:
				var my_child = get_child(1)
				var my_quantity = amount
				var item_parent = item.get_parent()
				
				remove_child( my_child )
				item_parent.remove_child( item )
				
				item_parent.add_child( my_child )
				item_parent.set_amount( my_quantity )
				
				add_child( item )
				set_amount( quantity )
			else:
				inventory.add_bag_item( item, quantity )
		else:
			print('> ',item.get_parent().name)
			inventory.add_bag_item( Item.new().set_from_dict(item.as_dict()), quantity )
			item.restart()
			player.set_equipment('_'+item.get_parent().name.to_lower())
		inventory.call_deferred("update_inventory")

func get_item_id():
	var child = get_child(1)
	if child:
		return (get_child(1) as Item).id
	return -1

func modify_amount(val : int):
	amount += val
	$Label.text = amount as String
	if amount <= 0:
		get_child(1).queue_free()
		$Label.hide()
	else:
		$Label.show()

func set_amount(val : int):
	amount = val
	$Label.text = amount as String
	if amount <= 0:
		get_child(1).queue_free()
		$Label.hide()
	else:
		$Label.show()

func as_dict():
	var dict = (get_child(1) as Item).as_dict()
	dict['amout'] = amount
	return dict
