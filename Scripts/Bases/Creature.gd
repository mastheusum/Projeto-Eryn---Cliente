extends KinematicBody2D

class_name Creature

var id : int
var creature_name : String

var _direction : Vector2 = Vector2.ZERO
var _move_speed : int = 200
var _path : PoolVector2Array

func _animate(dir=Vector2.DOWN, is_walking=false):
	$AnimationTree['parameters/conditions/IsStoped'] = not is_walking
	$AnimationTree['parameters/conditions/IsWalking'] = is_walking
	if is_walking:
		$AnimationTree['parameters/IDLE/blend_position'] = dir
		$AnimationTree['parameters/Walk/blend_position'] = dir

