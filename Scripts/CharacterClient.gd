extends CharacterBase

var move_speed = 200
var direction : Vector2 = Vector2.DOWN
var path : PoolVector2Array

func _ready():
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var start = self.global_position
			var end = get_global_mouse_position()
			path = get_node("/root/Game/Navigation2D").get_simple_path( start, end )
			path.remove(0)
	elif event is InputEventKey:
		if event.is_pressed():
			path = []

func _physics_process(delta):
	if path.empty():
		direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	else:
		if direction == Vector2.ZERO:
			direction = path[0] - global_position
		else:
			if global_position.distance_to(path[0]) <= move_speed * delta:
				path.remove(0)
				direction = Vector2.ZERO
	
	direction = direction.normalized()
	
	move_and_collide( direction * move_speed * delta )
	animate(direction, direction != Vector2.ZERO)
	get_node('/root/Lobby').update_position(global_position, direction)

