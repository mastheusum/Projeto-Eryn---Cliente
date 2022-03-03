extends PlayableCharacter

class_name Character

var account_id : int
var experience : int

var full_recover_time : float = 750 # in secconds
var life_recovery_rate : float = 0
var mana_recovery_rate : float = 0

var target_gateway_id : int = -1

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

func _ready():
	$CanvasLayer/Sign_out.connect("pressed", GameManager, "exit_game")
	
	$CanvasLayer/Status/CharacterName.text = creature_name
	$CanvasLayer/Status/LifeBar.max_value = max_life
	$CanvasLayer/Status/LifeBar.value = life
	$CanvasLayer/Status/ManaBar.max_value = max_mana
	$CanvasLayer/Status/ManaBar.value = mana
	
	# Player need recovery your status based in time
	life_recovery_rate = max_life / full_recover_time
	# if the recovery is too small then the time to recovery is bigger
	if life_recovery_rate < 1.0:
		$RecoveryLife.start(1.0/life_recovery_rate)
		life_recovery_rate = 1
	# if no the recovery receive a adjustment
	else:
		life_recovery_rate *= 2
		$RecoveryLife.start(2)
	$RecoveryLife.autostart = true
	
	# the same logic applied in life recovery
	mana_recovery_rate = max_mana / full_recover_time
	if mana_recovery_rate < 1.0:
		$RecoveryMana.start(1/mana_recovery_rate)
		mana_recovery_rate = 1
	else:
		mana_recovery_rate *= 2
		$RecoveryMana.start(2)
	$RecoveryMana.autostart = true

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var start_pos = global_position
			var end_pos = get_global_mouse_position()
			_path = get_parent().get_parent().get_node("Navigation2D").get_simple_path(start_pos, end_pos)
#			get_parent().get_parent().get_node("Navigation2D/Line2D").points = _path
			_path.remove(0)
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
		if event.is_pressed() and event.scancode == KEY_SPACE:
			print(global_position)
		# if the player start a movement by keyboard then the path must be forgotten
		if _direction != Vector2.ZERO:
			_path = []

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

func start_attack(gateway_id : int):
	target_gateway_id = gateway_id
	if not $AttackInterval.time_left > 0:
		$AttackInterval.emit_signal("timeout")

# type will be implemented
func receive_damage(value : int, type : int):
	var max_damage = value if value < life else life
	randomize()
	var damage = (randi() % max_damage)
	life -= damage
	$CanvasLayer/Status/LifeBar.value = life
	ConnectionManager.rpc('update_status', get_tree().get_network_unique_id(), life, mana)
	ConnectionManager.rpc('get_status_alert', str(damage), 1)

func _on_RecoveryLife_timeout():
	if not (life + life_recovery_rate > max_life):
		life += int(life_recovery_rate)
	else:
		life = max_life
	$CanvasLayer/Status/LifeBar.value = life
	ConnectionManager.rpc('update_status', get_tree().get_network_unique_id(), life, mana)

func _on_RecoveryMana_timeout():
	if not (mana + mana_recovery_rate > max_mana):
		mana += int(mana_recovery_rate)
	else:
		mana = max_mana
	$CanvasLayer/Status/ManaBar.value = mana
	ConnectionManager.rpc('update_status', get_tree().get_network_unique_id(), life, mana)

func _on_AttackInterval_timeout():
	if target_gateway_id > 1:
		if global_position.distance_to( GameManager.get_character(target_gateway_id).global_position ) <= attack_range:
			ConnectionManager.rpc_id(target_gateway_id, 'attack_character', 10, 1)
		$AttackInterval.start(1.5)
