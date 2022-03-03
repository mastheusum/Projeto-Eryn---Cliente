extends Node

var account_id : int = -1
var token : String = ""
var in_game : bool = false

var my_character_id : String

func _ready():
	var game = load("res://Scenes/Game.tscn").instance()
	get_node('/root').call_deferred( 'add_child', game)

func set_account_logged(account_id : int, token : String):
	self.account_id = account_id
	if self.account_id != -1:
		self.token = token
		get_node("/root/Lobby").login_to_character_list(true)
		get_character_list()

func get_character_list():
	ConnectionManager.rpc_id(1, 'request_character_list', token)

func logout():
	account_id = -1
	ConnectionManager.rpc_id(1, 'request_logout', token)

# Call by ConnectionManager
func create_character(character_list : Dictionary):
	if GameManager.in_game or character_list.keys().has( str(get_tree().get_network_unique_id()) ):
		for gateway in character_list.keys():
			get_node('/root/Game').add_character_from_game(int(gateway), character_list[gateway])

func destroy_character(gateway_id : int):
	get_node('/root/Game').add_character_from_game(gateway_id)

func exit_game():
	in_game = false
	get_node('/root/Lobby').lobby_to_game(false)
	get_node('/root/Game').remove_all()
	
	ConnectionManager.rpc_id(1, 'request_sign_out_character', token, int(my_character_id) )
	get_character_list()

func set_character_position(gateway_id : int, global_pos : Vector2, direction : Vector2):
	if in_game:
		var character = get_node('/root/Game/PlayerList').get_node( str(gateway_id) )
		if character:
			character.global_position = global_pos
			character._animate(direction, direction != Vector2.ZERO)

func get_character(gateway_id : int) -> KinematicBody2D:
	var list = get_node("/root/Game/PlayerList")
	var character = list.get_node(str(gateway_id))
	return character

func get_message(gateway_id : int, message : String):
	if in_game:
		var sender = get_character(gateway_id)
		var my_character = get_character( int(my_character_id) )
		
		var sender_name = (sender as Creature).creature_name
		var sender_position = sender.global_position + Vector2(0, -80)
		
		var self_message = gateway_id == int(my_character_id)
		
		var text = my_character.get_node('CanvasLayer/Chat').receive_new_message(sender_name, message, self_message)
		
		get_node('/root/Game').create_text_in_map(text, sender_position)

func get_status_alert(gateway_id : int, message : String, type : int):
	var sender = get_character(gateway_id)
	var sender_position = sender.global_position
	get_node('/root/Game').create_alert_in_map(message, type, sender_position)

func set_player_target(gateway_id : int):
	var my_character = get_character( int(my_character_id) )
	my_character.start_attack(gateway_id)
