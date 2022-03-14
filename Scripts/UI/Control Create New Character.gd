extends Control

enum Jobs {
	KNIGHT,
	ARCHER,
	SORCERER,
	DRUID
}

var sprite_index : int = 0
var sprite_list = [
	preload("res://Sprites/Character/Pipoya/Male/Male 14-1.png"),
	preload("res://Sprites/Character/Pipoya/Female/Female 17-1.png"),
]

func _ready():
#	print(Jobs)
	pass

func _on_visibility_changed():
	$CharacterName.text = ''

func _on_CreateCharacterButton_pressed():
	var character_name : String = $CharacterName.text
	var jobs_group = $Jobs/Archer.group
	
	var pool_string = character_name.split(' ')
	character_name = pool_string.join(' ')

	var character = {}
	character['name'] = character_name
	character['skin'] = sprite_index
	character['job'] = Jobs[jobs_group.get_pressed_button().name.to_upper()]
	
	config_panel_result("Please Wait", false)
	
	ConnectionManager.rpc_id(1, 'request_create_new_character', SessionManager.token, character)

func _on_CancelCreateCharacterButton_pressed():
	get_node('/root/Lobby').character_list_to_create_character(false)

func config_panel_result(message : String, confirm : bool):
	$PanelResult.visible = true
	$PanelResult/Error.text = message
	$PanelResult/Confirm.disabled = not confirm

func _on_PanelResult_Confirm_pressed():
	$PanelResult.visible = false
	$CancelCreateCharacterButton.emit_signal("pressed")

func _on_CharacterName_text_changed(new_text):
	$CreateCharacterButton.disabled = new_text == ''

# Carroussel
func _on_RightButton_pressed():
	sprite_index += 1
	sprite_index %= sprite_list.size()
	change_sprite()

func _on_LeftButton_pressed():
	sprite_index -= 1
	if sprite_index < 0:
		sprite_index = sprite_list.size() - 1
	change_sprite()

func change_sprite():
	($Carroussel/TextureRect.texture as AtlasTexture).atlas = sprite_list[sprite_index]
