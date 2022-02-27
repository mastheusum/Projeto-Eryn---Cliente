extends Node2D

var button_character_preload = preload("res://Instantiable/CharacterListButton.tscn")

func _ready():
	get_tree().connect("connected_to_server", self,"_connection_ok")
	get_tree().connect("connection_failed", self, "_connection_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _connection_ok():
	$CanvasLayer/ConnectServer.visible = false
	$CanvasLayer/Login.visible = true

# ConnectServer node
func connect_server():
	var address = $CanvasLayer/ConnectServer/Panel/Address.text
	var port = int( $CanvasLayer/ConnectServer/Panel/Port.text )
	
	ConnectionManager.start_connection(address, port)

# Login node
func authenticate_account():
	var username = $CanvasLayer/Login/Panel/Username.text
	var password = $CanvasLayer/Login/Panel/Password.text.sha256_text()
	
	$CanvasLayer/Login/Panel.visible = false
	$CanvasLayer/Login/PanelWait.visible = true
	$CanvasLayer/Login/PanelWait/PanelWait.start(3)
	ConnectionManager.rpc_id(1, "authenticate_account", username, password)

func _on_PanelWait_timeout():
	$CanvasLayer/Login/Panel.visible = true
	$CanvasLayer/Login/PanelWait.visible = false

# CharacterList node
func prepare_character_list():
	$CanvasLayer/Login.visible = false
	$CanvasLayer/Login/PanelWait/PanelWait.emit_signal("timeout")
	$CanvasLayer/CharacterList.visible = true
	ConnectionManager.rpc_id(1, "get_characters_list", GameManager.account_id, GameManager.token)

func set_character_list(character_list : Array):
	# Destroy all container children to clear all existing radio buttons
	var vbox = $CanvasLayer/CharacterList/Panel/ScrollContainer/VBoxContainer
	for child in vbox.get_children():
		child.queue_free()
	# Disable select character button if not have characters to select
	if not character_list.size() > 0:
		$CanvasLayer/CharacterList/Panel/SelectCharacterButton.disabled = true
	# Create buttons and setup in group to select if have any character to select
	else:
		$CanvasLayer/CharacterList/Panel/SelectCharacterButton.disabled = false
		var btn_group = load("res://Config/CharSelectionGroup.tres")
		var char_button
		var first = true
		for element in character_list:
			char_button = button_character_preload.instance()
			char_button.group = btn_group
			char_button.character_id    = int( element['id'] )
			char_button.character_name  = str( element['name'] )
			char_button.character_level = int( element['level'] )
			if first:
				char_button.pressed = true
				first = false
			vbox.call_deferred( 'add_child', char_button)

func _on_SelectCharacterButton_pressed():
	var vbox_child = $CanvasLayer/CharacterList/Panel/ScrollContainer/VBoxContainer.get_child(0)
	var id = vbox_child.group.get_pressed_button().character_id
	ConnectionManager.rpc_id(1, 'character_selected', id)

func _on_NewCharacterButton_pressed():
	$CanvasLayer/CharacterList.visible = false
	$CanvasLayer/CreateNewCharacter.visible = true

func _on_LogoutButton_pressed():
	$CanvasLayer/Login.visible = true
	$CanvasLayer/CharacterList.visible = false
	GameManager.logout()

# CreateNewCharacter node
func _on_CreateCharacterButton_pressed():
	var char_name = $CanvasLayer/CreateNewCharacter/Panel/CharacterName.text
	if char_name != '':
		var names = char_name.rsplit(' ')
		char_name = names.join(" ")
		var dict = { 'name' : char_name }
		ConnectionManager.rpc_id(1, 'create_new_character', GameManager.account_id, GameManager.token, dict)

func _on_CharacterName_text_changed(new_text):
	$CanvasLayer/CreateNewCharacter/Panel/CreateCharacterButton.disabled = new_text == ''

func _on_NewCharacterConfirm_pressed():
	$CanvasLayer/CreateNewCharacter/Panel/CharacterName.text = ''
	$CanvasLayer/CreateNewCharacter/PanelResult.visible = false
	$CanvasLayer/CreateNewCharacter.visible = false
	prepare_character_list()

func new_character_result(error : String):
	$CanvasLayer/CreateNewCharacter/PanelResult/Error.text = error
	$CanvasLayer/CreateNewCharacter/PanelResult.visible = true

func _on_Button_CreateAccount_pressed():
	$CanvasLayer/CreateAccount/Panel/Username.text = ''
	$CanvasLayer/CreateAccount/Panel/Password.text = ''
	$CanvasLayer/CreateAccount/Panel/Password2.text = ''
	$CanvasLayer/CreateAccount/PanelResult.visible = false
	$CanvasLayer/CreateAccount.visible = true
	$CanvasLayer/Login.visible = false

# CreateAccount node
func _on_CreateNewAccountButton_pressed():
	var username = $CanvasLayer/CreateAccount/Panel/Username.text
	var password1 = $CanvasLayer/CreateAccount/Panel/Password.text
	var password2 = $CanvasLayer/CreateAccount/Panel/Password2.text
	
	if username != '' and password1 != '' and password2 != '':
		if password1 == password2:
			ConnectionManager.rpc_id(1, 'create_new_account', username, password1.sha256_text())
		

func _on_CancelNewAccountButton_pressed():
	$CanvasLayer/CreateAccount.visible = false
	$CanvasLayer/Login.visible = true
	
	$CanvasLayer/CreateAccount/Panel/Username.text = ''
	$CanvasLayer/CreateAccount/Panel/Password .text = ''
	$CanvasLayer/CreateAccount/Panel/Password2.text = ''

func _on_CreateAccountCheckBox_pressed():
	$CanvasLayer/CreateAccount/Panel/Password.secret = $CanvasLayer/CreateAccount/Panel/VisiblePassword.pressed

func new_account_result(error : String):
	$CanvasLayer/CreateAccount/PanelResult/Error.text = error
	$CanvasLayer/CreateAccount/PanelResult.visible = true

func _on_NewAccountConfirm_pressed():
	$CanvasLayer/CreateAccount/Panel/Username.text = ''
	$CanvasLayer/CreateAccount/Panel/Password.text = ''
	$CanvasLayer/CreateAccount/Panel/Password2.text = ''
	$CanvasLayer/CreateAccount/PanelResult.visible = false
	$CanvasLayer/CreateAccount.visible = false
	$CanvasLayer/Login.visible = true

