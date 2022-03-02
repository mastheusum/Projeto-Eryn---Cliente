extends PlayableCharacter

class_name Character

var account_id : int
var experience : int

func send_message(message : String):
	pass

func gain_experience(value : int):
	experience += value
	calculate_current_level()
	pass

# based on character's experience calculates his level
func calculate_current_level():
	if experience >= 1000:
		level += 1
		gain_experience( -1000 )

# need remake. This will recover a percent of max life over time
func recover_life():
	life = max_life

# need remake. This will recover a percent of max man over time
func recover_mana():
	mana = max_mana

func _ready():
	$CanvasLayer/Status/CharacterName.text = creature_name
	$CanvasLayer/Status/LifeBar.max_value = max_life
	$CanvasLayer/Status/LifeBar.value = life
	$CanvasLayer/Status/ManaBar.max_value = max_mana
	$CanvasLayer/Status/ManaBar.value = mana

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var start_pos = global_position
			var end_pos = get_global_mouse_position()
#			_path = get_parent().get_node("Navigation2D").get_simple_path(start_pos, end_pos)
#			get_parent().get_node("Navigation2D/Line2D").points = _path
#			_path.remove(0)
	elif event is InputEventKey:
		if event.is_action_pressed("ui_up"):
			_direction.y = - event.get_action_strength("ui_up")
		elif event.is_action_pressed("ui_down"):
			_direction.y = event.get_action_strength("ui_down")
		elif event.is_action_released("ui_up") or event.is_action_released("ui_down"):
			_direction.y = 0
		if event.is_action_pressed("ui_left"):
			_direction.x = - event.get_action_strength("ui_left")
		elif event.is_action_pressed("ui_right"):
			_direction.x = event.get_action_strength("ui_right")
		elif event.is_action_released("ui_left") or event.is_action_released("ui_right"):
			_direction.x = 0

func _physics_process(delta):
	if not _path.empty():
		if _direction == Vector2.ZERO:
			_direction = _path[0] - global_position
		else:
			_direction.normalized()
			if global_position.distance_to(_path[0]) <= _move_speed * delta:
				_path.remove(0)
				_direction = Vector2.ZERO
	
	_animate(_direction, _direction != Vector2.ZERO)
	move_and_collide(_direction.normalized() * _move_speed * delta)
	ConnectionManager.rpc('set_charater_position', global_position, _direction)
