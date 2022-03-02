extends Node2D

func set_text(text : String):
	$Message.bbcode_text = '[center][b]' + text + '[/b][/center]'

func _ready():
	$Timer.connect("timeout", self, "_on_message_timeout")
	$Timer.start(3)

func _on_message_timeout():
	queue_free()
