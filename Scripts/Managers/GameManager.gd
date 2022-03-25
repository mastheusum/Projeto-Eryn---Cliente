extends Node

var my_character : KinematicBody2D

func _ready():
	var game = load("res://Scenes/Harbor.tscn").instance()
	get_node('/root').call_deferred( 'add_child', game )

func get_character(gateway_id : int):
	var character = null
	var list = get_node("/root/Harbor/PlayerList")
	for element in list.get_children():
		if element.name == str(gateway_id):
			character = list.get_node( str(gateway_id) )
	return character

func get_monster(monster_id : String):
	var monster = null
	var list = get_node("/root/Harbor/MonsterList")
	for element in list.get_children():
		if element.name == monster_id:
			monster = list.get_node( monster_id )
	return monster

# Called by ConnectionManager
func create_character(character_list : Dictionary):
	if SessionManager.signed_in or character_list.keys().has( str(get_tree().get_network_unique_id()) ):
		for gateway in character_list.keys():
			get_node('/root/Harbor').add_character_to_game(int(gateway), character_list[gateway])

func destroy_character(gateway_id : int):
	if SessionManager.signed_in:
		if (my_character as Character).target_gateway_id == gateway_id:
			set_player_target( -1 )
		get_node('/root/Harbor').remove_character_from_game(gateway_id)

func set_character_position(gateway_id : int, global_pos : Vector2, direction : Vector2):
	var character = get_character(gateway_id)
	if character:
		character.global_position = global_pos
		character._animate(direction, direction != Vector2.ZERO)

func create_monster(monster_info : Dictionary):
	if SessionManager.signed_in:
		get_node('/root/Harbor').add_monster_to_game(monster_info)

func destroy_monster(monster_id : String):
	if SessionManager.signed_in:
		set_monster_target( '' )
		get_node('/root/Harbor').remove_monster_from_game(monster_id)

func set_monster_position(monster_id, global_pos, direction):
	var monster = get_monster(monster_id)
	if monster:
		monster.global_position = global_pos
		monster._animate(direction, direction != Vector2.ZERO)

func get_message(gateway_id : int, message : String):
	var sender = get_character(gateway_id)
		
	var sender_name = (sender as Creature).creature_name
	var sender_position = sender.global_position + Vector2(0, -80)
	
	if GameManager.my_character.global_position.distance_to(sender_position) <= 2000:
		var self_message = gateway_id == int(my_character.name)
		var text = my_character.get_node('CanvasLayer/Chat').receive_new_message(sender_name, message, self_message)
		get_node('/root/Harbor').create_text_in_map(text, sender_position)

func get_status_alert(sender_position : Vector2, message : String, type : int):
	if GameManager.my_character.global_position.distance_to(sender_position) <= 2000:
		get_node('/root/Harbor').create_alert_in_map(message, type, sender_position)

func set_player_target(gateway_id : int):
	(my_character as Character).player_target_id = gateway_id
	(my_character as Character).monster_target_id = ''
	
	my_character.start_attack()

func set_monster_target(monster_id : String):
	(my_character as Character).player_target_id = -1
	(my_character as Character).monster_target_id = monster_id
	
	my_character.start_attack()
