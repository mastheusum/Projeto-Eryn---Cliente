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
	$HUD/CharacterName.text = creature_name
	$HUD/LifeBar.max_value = max_life
	$HUD/LifeBar.value = life
	$HUD/ManaBar.max_value = max_mana
	$HUD/ManaBar.value = mana

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var start_pos = global_position
			var end_pos = get_global_mouse_position()
			_path = get_parent().get_node("Navigation2D").get_simple_path(start_pos, end_pos)
			get_parent().get_node("Navigation2D/Line2D").points = _path
			_path.remove(0)

func _physics_process(delta):
	if _path.empty():
		_direction.x = Input.get_action_raw_strength("ui_right") - Input.get_action_raw_strength("ui_left")
		_direction.y = Input.get_action_raw_strength("ui_down") - Input.get_action_raw_strength("ui_up")
	else:
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
