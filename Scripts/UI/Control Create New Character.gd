extends Control

func _on_visibility_changed():
	$CharacterName.text = ''

func _on_CreateCharacterButton_pressed():
	var character_name : String = $CharacterName.text
	
	var pool_string = character_name.split(' ')
	character_name = pool_string.join(' ')
	
	config_panel_result("Please Wait", false)
	
	ConnectionManager.rpc_id(1, 'request_create_new_character', GameManager.token, character_name)

func _on_CancelCreateCharacterButton_pressed():
	get_node('/root/Lobby').character_list_to_create_character(false)
	GameManager.get_character_list()

func config_panel_result(message : String, confirm : bool):
	$PanelResult.visible = true
	$PanelResult/Error.text = message
	$PanelResult/Confirm.disabled = not confirm

func _on_PanelResult_Confirm_pressed():
	$PanelResult.visible = false
	$CancelCreateCharacterButton.emit_signal("pressed")

func _on_CharacterName_text_changed(new_text):
	$CreateCharacterButton.disabled = new_text == ''
