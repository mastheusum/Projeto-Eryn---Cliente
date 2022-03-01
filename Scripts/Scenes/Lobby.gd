extends Node2D

var button_character_preload = preload("res://Instantiable/UI/CharacterListButton.tscn")

func _ready():
	get_tree().connect("connected_to_server", self,"_connection_ok")
	get_tree().connect("connection_failed", self, "_connection_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# SIGNALS
func _connection_ok():
	$"CanvasLayer/Control/Control Connect Server".visible = false
	$"CanvasLayer/Control/Control Login".visible = true

func _connection_fail():
	$"CanvasLayer/Control/Control Connect Server".visible = true
	$"CanvasLayer/Control/Control Login".visible = false

func _server_disconnected():
	$"CanvasLayer/Control/Control Connect Server".visible = true
	$"CanvasLayer/Control/Control Login".visible = false
	$"CanvasLayer/Control/Control Create New Account".visible = false
	$"CanvasLayer/Control/Control Character List".visible = false
	$"CanvasLayer/Control/Control Create New Character".visible = false

# Control Connect Server
func _on_Start_Connection_pressed():
	var address = $"CanvasLayer/Control/Control Connect Server/Address".text
	var port = int( $"CanvasLayer/Control/Control Connect Server/Port".text )
	
	ConnectionManager.start_connection(address, port)

# This function will control transition beteween login and create_new_account
# if parameters go is TRUE then it will go to create_new_account
# unless go is FALSSE then it will go to login
func login_to_create_new_account(go : bool):
	$"CanvasLayer/Control/Control Login".visible = not go
	$"CanvasLayer/Control/Control Create New Account".visible = go

# This function will control transition beteween login and chharacter_list
# if parameters go is TRUE then it will go to chharacter_list
# unless go is FALSSE then it will go to login
func login_to_character_list(go : bool):
	$"CanvasLayer/Control/Control Login".visible = not go
	$"CanvasLayer/Control/Control Character List".visible = go

func character_list_to_create_character(go : bool):
	$"CanvasLayer/Control/Control Character List".visible = not go
	$"CanvasLayer/Control/Control Create New Character".visible = go

func lobby_to_game(go : bool):
	if go:
		$CanvasLayer/Control.visible = false
	else:
		$CanvasLayer/Control.visible = true
		
