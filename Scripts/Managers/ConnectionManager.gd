extends Node2D

var peer = null

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
		SessionManager.set_account_logged(account_id, token)
	else:
		get_node('/root/Lobby/CanvasLayer/Control/Control Login').configure_panel_wait("Invalid Credentials", 2.0)

remote func response_logout():
	SessionManager.set_account_logged(-1, "")

remote func response_new_account( error : String ):
	get_node('/root/Lobby/CanvasLayer/Control/Control Create New Account').configure_panel_wait(error)

remote func response_character_list(character_list : Array):
	get_node('/root/Lobby/CanvasLayer/Control/Control Character List').configure_character_list(character_list)

remote func response_create_new_character(error : String):
	get_node('/root/Lobby/CanvasLayer/Control/Control Create New Character').config_panel_result(error, true)

# This function will receive a dictionary with gateways as keys
# every key has another dictionary with contains the character info
remote func response_sign_in(character_list : Dictionary):
	GameManager.create_character( character_list )

# This funcion will receive a list of geteways that will need destroy
# if the in the list have your own gateway then this client are leaving the game
remote func response_sign_out(character_list : Array):
	if character_list.has( get_tree().get_network_unique_id() ):
		SessionManager.exit_game()
	else:
		for gateway in character_list:
			GameManager.destroy_character( int(gateway) )

# ----
# Game Play
# ----

remote func set_charater_position(global_pos, direction):
	if SessionManager.signed_in:
		var id = get_tree().get_rpc_sender_id()
		GameManager.set_character_position(id, global_pos, direction)

remotesync func get_message(message : String):
	if SessionManager.signed_in:
		var gateway_id = get_tree().get_rpc_sender_id()
		GameManager.get_message(gateway_id, message)

# This function is called when player receive a damage
# then this damage is send to al another players connecteds
remotesync func get_status_alert(sender_position : Vector2, message : String, type : int):
	if SessionManager.signed_in:
		GameManager.get_status_alert(sender_position, message, type)

# used by player to receive damage by other players
remote func attack_character(power : int, type : int):
	var gateway_id = get_tree().get_rpc_sender_id()
#	GameManager.my_character.set_aggressor_list(gateway_id)
	ConnectionManager.rpc_id(1, 'set_aggressor_list', gateway_id)
	GameManager.my_character.receive_damage(power, type)

remote func set_aggressor_list(aggressor_id : int):
	pass

remote func update_status(gateway_id : int, status : String, value : int):
	if gateway_id == get_tree().get_network_unique_id():
		(GameManager.get_character(gateway_id) as Character).set_attribute(status, value)
	else:
		(GameManager.get_character(gateway_id) as CharacterProxy).set_attribute(status, value)

remote func update_level(gateway_id : int, experience : int, level : int):
	if SessionManager.signed_in:
		if gateway_id == get_tree().get_network_unique_id():
			GameManager.my_character.set_attribute("level", level)
			GameManager.my_character.set_attribute("experience", experience)
		else:
			GameManager.get_character(gateway_id).set_attribute("level", level)

remote func set_character_equipment(equipment : String, item : Dictionary):
	pass

remote func set_character_inventory(equipment_list : Array):
	pass

remote func create_monster(monster : Dictionary):
	if SessionManager.signed_in:
		GameManager.create_monster(monster)
		print('>>>>>> create_monster')

remote func update_monster(monster_id : String, attribute : String, value):
	if SessionManager.signed_in:
		(GameManager.get_monster(monster_id) as Monster).set_attribute(attribute, value)

remote func destroy_monster(monster_id : String):
	if SessionManager.signed_in:
		GameManager.destroy_monster(monster_id)

remote func attack_monster(monster_id : String, power : int, type : int):
	pass

remote func set_monster_position(monster_id : String, character_position : Vector2, character_direction : Vector2):
	if SessionManager.signed_in:
		GameManager.set_monster_position(monster_id, character_position, character_direction)
