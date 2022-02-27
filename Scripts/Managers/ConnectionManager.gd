extends Node2D

var peer = null
var character_name : String = ""
const player_instance = preload("res://Instantiable/PlayerInstance.tscn")
const client_script = preload("res://Scripts/CharacterClient.gd")
const game_scene = preload("res://Scenes/Game.tscn")

func _ready():
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("connected_to_server", self,"_connection_ok")
	get_tree().connect("connection_failed", self, "_connection_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

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

func _connection_ok():
	pass

func _connection_fail():
	pass

func _server_disconnected():
	print("-- end --")

remote func create_new_account(username : String, password : String):
	pass

remote func result_new_account(err : int):
	var result = "Conta Criada com Sucesso!"
	if err == 2:
		result = "Usuário já cadastrado..."
	get_node("/root/Lobby").new_account_result(result)

remote func authenticate_account(username : String, password : String):
	pass

remote func authentication_result(result : bool, account_id : int, token : String):
	if result:
		GameManager.set_account_logged(account_id, token)
	else:
		print("Invalid Credentials")

remote func sign_out(token : String):
	pass

remote func get_characters_list(account_id : int, token : String):
	pass

remote func set_characters_list(character_list : Array):
	get_node('/root/Lobby').set_character_list( character_list )
	pass

remote func character_selected(character_id : int):
	pass

remote func create_new_character(account_id : int, token : String, character : Dictionary):
	pass

remote func result_new_character(err : int):
	var result = "Personagem Criado com Sucesso!"
	if err == 2:
		result = "Nome já cadastrado..."
	get_node("/root/Lobby").new_character_result(result)

remote func set_charater_position(character_position : Vector2, character_direction : Vector2):
	pass
