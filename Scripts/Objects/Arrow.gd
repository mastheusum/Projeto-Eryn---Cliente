extends KinematicBody2D

var target : KinematicBody2D
var speed = 600

func _ready():
	target = KinematicBody2D.new()
	target.global_position = Vector2(600,600)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	look_at(target.global_position)
	var direction = target.global_position - global_position
	move_and_collide(direction.normalized() * speed * delta)
	var distance = global_position.distance_to(target.global_position)
	if abs(distance) < 36:
		queue_free()
