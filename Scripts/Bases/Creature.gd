extends KinematicBody2D

class_name Creature

var id : int
var creature_name : String

func _ready():
	$Name.text = creature_name

func animate(dir=Vector2.DOWN, is_walking=false):
	$AnimationTree['parameters/conditions/IsStoped'] = not is_walking
	$AnimationTree['parameters/conditions/IsWalking'] = is_walking
	if is_walking:
		$AnimationTree['parameters/IDLE/blend_position'] = dir
		$AnimationTree['parameters/Walk/blend_position'] = dir

