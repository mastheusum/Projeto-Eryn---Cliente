extends Node2D

var character_node = preload("res://Instantiable/Character.tscn")
var character_proxy_node = preload("res://Instantiable/CharacterProxy.tscn")

var map_message_node = preload("res://Instantiable/UI/MapMessage.tscn")
var map_alert_node = preload("res://Instantiable/UI/MessageAlert.tscn")

func add_character_from_game(gateway_id : int, character : Dictionary):
	var player
	if gateway_id == get_tree().get_network_unique_id():
		player = character_node.instance()
		player.experience = character['experience']
		GameManager.in_game = true
		GameManager.my_character_id = str( gateway_id )
		get_node('/root/Lobby').lobby_to_game(true)
	else:
		player = character_proxy_node.instance()
	
	player.name = str(gateway_id)
	player.set_network_master(gateway_id)
	player.id = character['id']
	player.creature_name = character['name']
	player.global_position = Vector2(character['global_position_x'],character['global_position_y'])
	player.max_life = character['max_life']
	player.life = character['life']
	player.max_mana = character['max_mana']
	player.mana = character['mana']
	player.level = character['level']
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
