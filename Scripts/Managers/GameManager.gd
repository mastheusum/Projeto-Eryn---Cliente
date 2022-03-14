extends Node

var my_character : KinematicBody2D

func _ready():
	var game = load("res://Scenes/Harbor.tscn").instance()
	get_node('/root').call_deferred( 'add_child', game )

func get_character(gateway_id : int) -> KinematicBody2D:
	var list = get_node("/root/Harbor/PlayerList")
	var character = list.get_node( str(gateway_id) )
	return character

# Called by ConnectionManager
func create_character(character_list : Dictionary):
	if SessionManager.signed_in or character_list.keys().has( str(get_tree().get_network_unique_id()) ):
		for gateway in character_list.keys():
			get_node('/root/Harbor').add_character_from_game(int(gateway), character_list[gateway])

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

func get_message(gateway_id : int, message : String):
	var sender = get_character(gateway_id)
		
	var sender_name = (sender as Creature).creature_name
	var sender_position = sender.global_position + Vector2(0, -80)
	
	var self_message = gateway_id == int(my_character.name)
	
	var text = my_character.get_node('CanvasLayer/Chat').receive_new_message(sender_name, message, self_message)
	
	get_node('/root/Harbor').create_text_in_map(text, sender_position)

func get_status_alert(gateway_id : int, message : String, type : int):
	var sender = get_character(gateway_id)
	var sender_position = sender.global_position
	get_node('/root/Harbor').create_alert_in_map(message, type, sender_position)

func set_player_target(gateway_id : int):
	my_character.start_attack(gateway_id)
