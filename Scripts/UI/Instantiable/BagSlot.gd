extends Panel

class_name BagSlot

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
		var item = data['item']
		var quantity = data['amount']
		var sender = data['sender']
		if sender == 'bag':
			var child = get_child(1)
			if child:
				var tmp = amount
				remove_child( child )
				item.get_parent().add_child( child )
				item.get_parent().remove_child( item )
				item.get_parent().set_amount( tmp )
				add_child( item )
				set_amount( quantity )
			else:
				inventory.add_bag_item( data['item'], data['amount'] )
		else:
			inventory.add_bag_item( data['item'], data['amount'] )
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
