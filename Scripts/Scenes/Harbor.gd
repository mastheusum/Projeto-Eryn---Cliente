extends Node2D

var character_node = preload("res://Instantiable/Character.tscn")
var character_proxy_node = preload("res://Instantiable/CharacterProxy.tscn")
var monster_node = preload("res://Instantiable/Monster.tscn")

var map_message_node = preload("res://Instantiable/UI/MapMessage.tscn")
var map_alert_node = preload("res://Instantiable/UI/MessageAlert.tscn")

func add_character_to_game(gateway_id : int, character : Dictionary):
	var player
	if gateway_id == get_tree().get_network_unique_id():
		player = character_node.instance()
		player.experience = character['experience']
		player.attribute_points = character['attribute_points']
		SessionManager.signed_in = true
		GameManager.my_character = player
		get_node('/root/Lobby').lobby_to_game(true)
		if not character['weapon1'].empty():
			player._weapon1 = player._weapon1.set_from_dict(character['weapon1'])
		if not character['weapon2'].empty():
			player._weapon2 = player._weapon2.set_from_dict(character['weapon2'])
		if not character['helmet'].empty():
			player._helmet = player._helmet.set_from_dict(character['helmet'])
		if not character['armor'].empty():
			player._armor = player._armor.set_from_dict(character['armor'])
		if not character['legs'].empty():
			player._legs = player._legs.set_from_dict(character['legs'])
		if not character['boots'].empty():
			player._boots = player._boots.set_from_dict(character['boots'])
		if not character['ring1'].empty():
			player._ring1 = player._ring1.set_from_dict(character['ring1'])
		if not character['ring2'].empty():
			player._ring2 = player._ring2.set_from_dict(character['ring2'])
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
	player.strength = character['strength']
	player.constitution = character['constitution']
	player.dexterity = character['dexterity']
	player.agility = character['agility']
	player.intelligence = character['intelligence']
	player.willpower = character['willpower']
	player.perception = character['perception']
	player.wisdom = character['wisdom']
	player.set_max_life()
	player.life = character['life']
	player.set_max_mana()
	player.mana = character['mana']
	
	$PlayerList.call_deferred( 'add_child', player )

func remove_character_from_game(gateway_id : int):
	var character = $PlayerList.get_node( str( gateway_id ) )
	if character:
		character.queue_free()

func remove_all():
	for child in $PlayerList.get_children():
		child.queue_free()
	for child in $MonsterList.get_children():
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

func add_monster_to_game(dict : Dictionary):
	var monster = monster_node.instance()
	
	monster.set_network_master(1)
	monster.name = dict['world_id']
	monster.creature_name = dict['name']
	monster.sprite_index = dict['skin']
	monster.global_position.x = dict['global_position_x']
	monster.global_position.y = dict['global_position_y']
	monster.level = dict['level']
	monster.constitution = dict['constitution'] 
	monster.intelligence = dict['intelligence']
	
	monster.set_max_life()
	monster.set_max_mana()
	monster.life = dict['life']
	monster.mana = dict['mana']
	print(monster)
	$MonsterList.call_deferred( 'add_child', monster )
	
func remove_monster_from_game(monster_id : String):
	var monster = $MonsterList.get_node(monster_id)
	if monster:
		monster.queue_free()
