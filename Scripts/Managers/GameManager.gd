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
	for gateway in character_list.keys():
		get_node('/root/Game').add_character_from_game(int(gateway), character_list[gateway])

func destroy_character(gateway_id : int):
	get_node('/root/Game').add_character_from_game(gateway_id)

func exit_game():
	in_game = false
	get_node('/root/Lobby').lobby_to_game(false)
	get_node('/root/Game').remove_all()
	
	ConnectionManager.rpc_id(1, 'request_sign_out_character', token, int(my_character_id) )

func set_character_position(gateway_id : int, global_pos : Vector2, direction : Vector2):
	if in_game:
		var character = get_node('/root/Game/PlayerList').get_node( str(gateway_id) )
		if character:
			character.global_position = global_pos
			character._animate(direction, direction != Vector2.ZERO)

func get_character_name(gateway_id : int) -> String:
	var list = get_node("/root/Game/PlayerList")
	var character = list.get_node(str(gateway_id))
	if character:
		return (character as Creature).creature_name
	return ''

func get_message(gateway_id : int, message : String):
	if in_game:
		var list = get_node("/root/Game/PlayerList")
		
		var sender = get_character_name(gateway_id)
		var sender_position = list.get_node(str(gateway_id)).global_position + Vector2(0, -112)
		
		var character = list.get_node(my_character_id)
		
		var self_message = gateway_id == get_tree().get_network_unique_id()
		
		var text = character.get_node('CanvasLayer/Chat').receive_new_message(sender, message, self_message)
		
		get_node('/root/Game').create_text_in_map(text, sender_position)