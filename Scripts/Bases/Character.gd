extends PlayableCharacter

class_name Character

enum Jobs {
	KNIGHT,
	ARCHER,
	SORCERER,
	DRUID
}

var account_id : int
var experience : int
var attribute_points : int # to distribute among attributes when leveling up
var job : int # Type ENUM Jobs

var full_recover_time : float = 750 # in secconds
var life_recovery_rate : float = 0
var mana_recovery_rate : float = 0

var player_target_id : int = -1
var monster_target_id : String = ''

var inventory = []

var _helmet : Item = Item.new()
var _armor : Item = Item.new()
var _legs : Item = Item.new()
var _boots : Item = Item.new()
var _weapon1 : Item = Item.new()
var _weapon2 : Item = Item.new()
var _ring1 : Item = Item.new()
var _ring2 : Item = Item.new()

signal update_attribute()

func _ready():
	$CanvasLayer/Sign_out.connect("pressed", SessionManager, "exit_game")
	
	$CanvasLayer/Status/CharacterName.bbcode_text = '[b][i]' + creature_name
	$CanvasLayer/Status/LifeBar.max_value = max_life
	$CanvasLayer/Status/LifeBar.value = life
	$CanvasLayer/Status/ManaBar.max_value = max_mana
	$CanvasLayer/Status/ManaBar.value = mana
	
	call_deferred( "set_attribute", "level", level )
	call_deferred( "set_attribute", "experience", experience )
	
	$AnimatedSprite.frames = load("res://Resources/Animations/Characters/"+str(sprite_index)+".tres")
	def_life_recovery()
	def_mana_recovery()

# Player need recovery your status based in time
func def_life_recovery():
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
func def_mana_recovery():
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
		# Attribute Controle
		if event.is_pressed() and event.scancode == KEY_C:
			$CanvasLayer/Attributes.visible = not $CanvasLayer/Attributes.visible
		if event.is_pressed() and event.scancode == KEY_V:
			$CanvasLayer/Inventory.visible = not $CanvasLayer/Inventory.visible
		# Movement
		if event.is_action("ui_right") or event.is_action("ui_left"):
			_direction.x = event.get_action_strength("ui_right") - event.get_action_strength("ui_left")
		if event.is_action("ui_down") or event.is_action("ui_up"):
			_direction.y = event.get_action_strength("ui_down") - event.get_action_strength("ui_up")
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

func set_attribute(attribute : String, value : int):
	var attribute_accessor : PoolStringArray = [
		"strength",
		"constitution",
		"dexterity",
		"agility",
		"intelligence",
		"willpower",
		"perception",
		"wisdom",
		"life",
		"mana",
		"max_life",
		"max_mana",
		"experience",
		"level",
		"attribute_points"
	]
	if attribute in attribute_accessor:
		set(attribute, value)
		if attribute == 'life':
			$CanvasLayer/Status/LifeBar.value = life
		elif attribute == 'mana':
			$CanvasLayer/Status/ManaBar.value = mana
		elif attribute == 'level':
			$CanvasLayer/Status/Level.bbcode_text = "[center][b]" + str(level)
			$CanvasLayer/Status/ExperienceBar.min_value = pow(10 * (level - 1), 2)
			$CanvasLayer/Status/ExperienceBar.max_value = 100 * (pow(level, 2) - pow(level - 1, 2))
		elif attribute == 'experience':
			$CanvasLayer/Status/ExperienceBar.value = experience
		elif attribute == "max_life":
			def_life_recovery()
			$CanvasLayer/Status/LifeBar.max_value = max_life
		elif attribute == "max_mana":
			def_mana_recovery()
			$CanvasLayer/Status/ManaBar.max_value = max_mana
		emit_signal("update_attribute")

func set_equipment(equipment_name : String):
	ConnectionManager.rpc_id(1, "set_character_equipment", equipment_name, self[equipment_name].as_dict() if self[equipment_name].id > 0 else {})
#	print('> ',equipment_name)

func set_inventory(item_list : Array):
	inventory = item_list
	ConnectionManager.rpc_id(1, "set_character_inventory", inventory)

func start_attack():
	if not $AttackInterval.time_left > 0:
		$AttackInterval.emit_signal("timeout")

# type will be implemented
func receive_damage(value : int, type : int):
	var max_damage = 1 + ( value if value < life else life )
	randomize()
	var damage = (randi() % max_damage)
	life -= damage
	
	$CanvasLayer/Status/LifeBar.value = life
	ConnectionManager.rpc('update_status', get_tree().get_network_unique_id(), "life", life)
	ConnectionManager.rpc('get_status_alert', global_position, str(damage), 1)

func _on_RecoveryLife_timeout():
	if not (life + life_recovery_rate > max_life):
		life += int(life_recovery_rate)
	else:
		life = max_life
	
	$CanvasLayer/Status/LifeBar.value = life
	ConnectionManager.rpc('update_status', get_tree().get_network_unique_id(), "life", life)

func _on_RecoveryMana_timeout():
	if not (mana + mana_recovery_rate > max_mana):
		mana += int(mana_recovery_rate)
	else:
		mana = max_mana
	
	$CanvasLayer/Status/ManaBar.value = mana
	ConnectionManager.rpc('update_status', get_tree().get_network_unique_id(), "mana", mana)

func _on_AttackInterval_timeout():
	var max_distance = 0
	var power = strength
	var critical = dexterity
	if _weapon1.id > 0:
		power += _weapon1.attack
		critical += _weapon1.critical
		max_distance = _weapon1.attack_range
	if _weapon2.id > 0:
		power += _weapon2.attack
		critical += _weapon2.critical
		if _weapon2.attack_range > max_distance:
			max_distance = _weapon2.attack_range
	randomize()
	power *= 1.5 if randi() % 100 < critical else 1
	if monster_target_id == '' and player_target_id != -1:
		if max_distance > 0 and global_position.distance_to( GameManager.get_character(player_target_id).global_position ) <= max_distance:
			ConnectionManager.rpc_id(player_target_id, 'attack_character', power, 1)
	elif monster_target_id != '' and player_target_id == -1:
		if max_distance > 0 and global_position.distance_to( GameManager.get_monster(monster_target_id).global_position ) <= max_distance:
			ConnectionManager.rpc_id(1, 'attack_monster', monster_target_id, power, 1)
	$AttackInterval.start(1.5)


