extends KinematicBody2D

class_name CharacterBase

var character_name = ""
var max_life = 100
var life = 100

func _ready():
	$Name.text = character_name

func animate(dir=Vector2.DOWN, is_walking=false):
	$AnimationTree['parameters/conditions/IsStoped'] = not is_walking
	$AnimationTree['parameters/conditions/IsWalking'] = is_walking
	if is_walking:
		$AnimationTree['parameters/IDLE/blend_position'] = dir
		$AnimationTree['parameters/Walk/blend_position'] = dir
