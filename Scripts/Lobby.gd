extends Node2D

var peer = null
var character_name = ""
const player_instance = preload("res://Instantiable/PlayerInstance.tscn")
const client_script = preload("res://Scripts/CharacterClient.gd")
const game_scene = preload("res://Scenes/Game.tscn")

func start_connection():
	character_name = $"Panel/Character Name".text
	
	peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_RANGE_CODER)
	peer.create_client($Panel/Address.text, int($Panel/Port.text))
	get_tree().network_peer = null
	get_tree().network_peer = peer
	
	get_tree().connect("network_peer_connected", self, "_on_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_on_player_disconnected")
	get_tree().connect("connected_to_server", self,"_connection_ok")
	get_tree().connect("connection_failed", self, "_connection_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
	var game = game_scene.instance()
	get_node("/root").add_child(game)
	get_node("/root/Lobby").visible = false

func _on_player_connected(id):
	print(">> " + str(id) )
	pass

func _on_player_disconnected(id):
	print("<< " + str(id) )
	destroy_player(id)
	pass

func _connection_ok():
	pass

func _connection_fail():
	pass

func _server_disconnected():
	print("-- end --")
	get_node('/root/Game').queue_free()
	get_tree().network_peer = null
	pass

func create_player(character_id : int, character_position : Vector2):
	var player = player_instance.instance()
	player.name = str(character_id)
	player.global_position = character_position
	player.set_network_master(character_id)
	get_node("/root/Game/PlayerList").add_child(player)
	return player

func destroy_player(character_id : int):
	var player = get_node("/root/Game/PlayerList/"+ str(character_id))
	if player:
		player.queue_free()

remote func create_character(character_id : int, character_position : Vector2):
	var player = create_player(character_id, character_position)
	if character_id == get_tree().get_network_unique_id():
		player.get_node("ColorRect").color = Color("#ffff00")
		player.get_node("Name").text = character_name
		player.set_script(client_script) # don't work
		rpc_id(1, "set_character_name", character_name)

remote func set_character_name(character_id : int, character_name):
	var player = get_node("/root/Game/PlayerList/"+ str(character_id))
	if player:
		player.get_node("Name").text = character_name

remote func set_charater_position(character_position : Vector2, character_direction : Vector2):
	var id = get_tree().get_rpc_sender_id()
	var player = get_node("/root/Game/PlayerList/"+ str(id))
	if player:
		player.global_positionn = character_position
		player.animate(character_direction, character_direction != Vector2.ZERO)
