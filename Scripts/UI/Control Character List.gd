extends Control

var button_character = preload("res://Instantiable/UI/CharacterListButton.tscn")
var button_group = preload("res://Config/CharSelectionGroup.tres")

func _on_visibility_changed():
	for child in $ScrollContainer/VBoxContainer.get_children():
		child.queue_free()

func _on_SelectCharacterButton_pressed():
	var btnGroup : ButtonGroup = $ScrollContainer/VBoxContainer.get_child(0).group
	var btnSelected = btnGroup.get_pressed_button() as CharacterListButton
	var character_id = btnSelected.character_id
	
	ConnectionManager.rpc_id(1, 'request_sign_in_character', GameManager.token, character_id)

func _on_NewCharacterButton_pressed():
	get_node("/root/Lobby").character_list_to_create_character(true)

func _on_LogoutButton_pressed():
	ConnectionManager.request_logout(GameManager.token)
	get_node("/root/Lobby").login_to_character_list(false)

func configure_character_list(character_list : Array):
	var first = true
	for character in character_list:
		var new_button = button_character.instance()
		new_button.character_id = character['id']
		new_button.character_name = character['name']
		new_button.character_level = character['level']
		new_button.group = button_group
		if first:
			new_button.pressed = true
			first = false
		$ScrollContainer/VBoxContainer.add_child(new_button)
	$SelectCharacterButton.disabled = first

