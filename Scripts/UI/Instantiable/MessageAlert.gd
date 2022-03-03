extends Node2D

var pos : Vector2 = Vector2.ZERO

func config(message : String = '100', type : int = 1):
	$log.bbcode_text += '[center]'
	$log.bbcode_text += '[color='
	$log.bbcode_text += '#ff3c3c' if type == 1 else '#00ff81'
	$log.bbcode_text += ']'
	$log.bbcode_text += '' + message + ''
	$log.bbcode_text += '[/color]'
	$log.bbcode_text += '[/center]'

func _ready():
	$Tween.interpolate_property(
		$log, 'rect_global_position',
		$log.rect_global_position, $log.rect_global_position + Vector2(0, -100), 3,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
	)
	$Tween.start()

func _on_Tween_tween_all_completed():
	queue_free()
