extends Node2D

var peer = null
var character_name : String = ""
const player_instance = preload("res://Instantiable/PlayerInstance.tscn")
const client_script = preload("res://Scripts/CharacterClient.gd")
const game_scene = preload("res://Scenes/Game.tscn")

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")

func start_connection(address : String, port : int):
	peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	var err = peer.create_client(address, port)
	if err != OK:
		return
	get_tree().network_peer = null
	get_tree().network_peer = peer
	

func _on_player_connected(id):
	pass

func _on_player_disconnected(id):
	pass

# REQUESTS
remote func request_login(username : String, password : String):
	pass

remote func request_logout(token : String):
	pass

remote func request_new_account(username : String, password : String ):
	pass

remote func request_character_list(token : String):
	pass

remote func request_create_new_character(token : String, character_name : String):
	pass

remote func request_sign_in_character(token : String, character_id : int):
	pass

remote func request_sign_out_character(token : String):
	pass

# RESPONSES
remote func response_login(account_id : int, token : String):
	if account_id > 0 and token != "":
		GameManager.set_account_logged(account_id, token)
	else:
		get_node('/root/Lobby/CanvasLayer/Control/Control Login').configure_panel_wait("Invalid Credentials", 2.0)

remote func response_logout():
	GameManager.set_account_logged(-1, "")

remote func response_new_account( error : String ):
	get_node('/root/Lobby/CanvasLayer/Control/Control Create New Account').configure_panel_wait(error)

remote func response_character_list(character_list : Array):
	get_node('/root/Lobby/CanvasLayer/Control/Control Character List').configure_character_list(character_list)

remote func response_create_new_character(error : String):
	get_node('/root/Lobby/CanvasLayer/Control/Control Create New Character').config_panel_result(error, true)

remote func response_sign_in(character_list : Dictionary):
	GameManager.create_character( character_list )

remote func response_sign_out(character_list : Array):
	if character_list.has( str( get_tree().get_network_unique_id() ) ):
		GameManager.exit_game()
	else:
		for gateway in character_list:
			GameManager.destroy_character( int(gateway) )

# ---------------------

remote func set_charater_position(global_pos, direction):
	var id = get_tree().get_rpc_sender_id()
	GameManager.set_character_position(id, global_pos, direction)
