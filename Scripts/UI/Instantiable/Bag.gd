extends Control

func add_item(item : Item, amount : int):
	var added = false
	var index = 0
	for slot in $ScrollContainer/GridContainer.get_children():
		if slot.get_child(1):
			index += 1
			if (slot as BagSlot).get_item_id() == item.id and item.name != slot.get_child(1).name:
				if item.get_parent():
					item.queue_free()
				(slot as BagSlot).modify_amount(amount)
				added = true
				break
		else:
			break
		
	if not added:
		if item.get_parent():
			item.get_parent().remove_child(item)
		$ScrollContainer/GridContainer.get_child(index).add_child(item)
		$ScrollContainer/GridContainer.get_child(index).set_amount(amount)

func get_bag():
	var inventory = []
	for slot in $ScrollContainer/GridContainer.get_children():
		if slot.get_child(1):
			var dict = (slot as BagSlot).as_dict()
			inventory.append(dict)
		else:
			break
	return inventory
