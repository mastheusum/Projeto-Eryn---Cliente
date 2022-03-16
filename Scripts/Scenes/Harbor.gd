extends Node2D

var character_node = preload("res://Instantiable/Character.tscn")
var character_proxy_node = preload("res://Instantiable/CharacterProxy.tscn")

var map_message_node = preload("res://Instantiable/UI/MapMessage.tscn")
var map_alert_node = preload("res://Instantiable/UI/MessageAlert.tscn")

func add_character_from_game(gateway_id : int, character : Dictionary):
#	print(character)
	var player
	if gateway_id == get_tree().get_network_unique_id():
		player = character_node.instance()
		player.experience = character['experience']
		SessionManager.signed_in = true
		GameManager.my_character = player
		get_node('/root/Lobby').lobby_to_game(true)
		if not character['weapon1'].empty():
			player._weapon1 = Item.new().dict_to(character['weapon1'])
		if not character['weapon2'].empty():
			player._weapon2 = Item.new().dict_to(character['weapon2'])
		if not character['helmet'].empty():
			player._helmet = Item.new().dict_to(character['helmet'])
		if not character['armor'].empty():
			player._armor = Item.new().dict_to(character['armor'])
		if not character['legs'].empty():
			player._legs = Item.new().dict_to(character['legs'])
		if not character['boots'].empty():
			player._boots = Item.new().dict_to(character['boots'])
		if not character['ring1'].empty():
			player._ring1 = Item.new().dict_to(character['ring1'])
		if not character['ring2'].empty():
			player._ring2 = Item.new().dict_to(character['ring2'])
		player.inventory = character['inventory']
	else:
		player = character_proxy_node.instance()
	
	player.name = str(gateway_id)
	player.set_network_master(gateway_id)
	player.id = character['id']
	player.creature_name = character['name']
	player.sprite_index = character['skin']
	player.job = character['job']
	player.global_position = Vector2(character['global_position_x'],character['global_position_y'])
	player.level = character['level']
	player.attribute_points = character['attribute_points']
	player.strength = character['strength']
	player.constitution = character['constitution']
	player.dexterity = character['dexterity']
	player.agility = character['agility']
	player.intelligence = character['intelligence']
	player.willpower = character['willpower']
	player.perception = character['perception']
	player.wisdom = character['wisdom']
	player.max_life = 5 * player.constitution
	player.life = character['life']
	player.max_mana = 5 * player.intelligence
	player.mana = character['mana']
	
	$PlayerList.call_deferred( 'add_child', player )

func remove_character_from_game(gateway_id : int):
	var character = $PlayerList.get_node( str( gateway_id ) )
	if character:
		character.queue_free()

func remove_all():
	for child in $PlayerList.get_children():
		child.queue_free()

func create_text_in_map(text : String, global_pos : Vector2):
	var new_message = map_message_node.instance()
	new_message.set_text(text)
	new_message.global_position = global_pos
	$Messages.add_child(new_message)

func create_alert_in_map(message : String, type: int, global_pos : Vector2):
	var new_alert = map_alert_node.instance()
	new_alert.config(message, type)
	new_alert.global_position = global_pos
	$Messages.add_child(new_alert)
