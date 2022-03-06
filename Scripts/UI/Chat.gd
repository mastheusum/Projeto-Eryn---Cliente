extends Control

onready var edit_message = get_node("VBoxContainer/HBoxContainer/EditMessage")
onready var send_message = get_node("VBoxContainer/HBoxContainer/SendMessage")
onready var message_log = get_node("VBoxContainer/RichTextLabel")

func _ready():
	pass

func _input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ENTER:
			if not edit_message.has_focus():
				edit_message.grab_focus()
			else:
				send_message.emit_signal("pressed")
		if event.pressed and event.scancode == KEY_ESCAPE:
			edit_message.release_focus()

func _on_SendMessage_pressed():
	var message : String = edit_message.text
	if message != '':
#		receive_new_message(int(GameManager.my_character_id), message)
		ConnectionManager.rpc('get_message', message)
		edit_message.text = ''
	
func receive_new_message(sender : String, message : String, self_message : bool):
	var text = '['+sender+']: '+message
	message_log.bbcode_text += "\n"
	message_log.bbcode_text += '[color='
	message_log.bbcode_text += '#00e3ff' if self_message else '#ffffff'
	message_log.bbcode_text += ']'
	message_log.bbcode_text += text
	message_log.bbcode_text += '[/color]'
	return text
