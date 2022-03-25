extends PlayableCharacter

class_name Monster

func _ready():
	$HUD/CharacterName.text = creature_name
	$HUD/LifeBar.max_value = max_life
	$HUD/LifeBar.value = life
	$HUD/ManaBar.max_value = max_mana
	$HUD/ManaBar.value = mana
	
	$AnimatedSprite.frames = load("res://Resources/Animations/Monsters/"+str(sprite_index)+".tres")

func _on_TargetArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_RIGHT:
			$Mark.visible = ! $Mark.visible

func _on_Mark_visibility_changed():
	if $Mark.visible:
		GameManager.set_monster_target( name )
		$Tween.interpolate_property(
				$Mark, 'rotation_degrees',
				0, 360, 3, 
				Tween.TRANS_LINEAR, Tween.EASE_IN
			)
		$Tween.start()
	else:
		GameManager.set_monster_target( '' )
		$Tween.stop_all()

func _on_Tween_tween_all_completed():
	if $Mark.visible:
		$Tween.interpolate_property(
				$Mark, 'rotation_degrees',
				0, 360, 3, 
				Tween.TRANS_LINEAR, Tween.EASE_IN
			)
		$Tween.start()

func set_attribute(attribute : String, value : int):
	var attribute_accessor : PoolStringArray = [
		"life",
		"mana",
		"max_life",
		"max_mana",
		"level"
	]
	if attribute in attribute_accessor:
		set(attribute, value)
		if attribute == "max_life":
			$HUD/LifeBar.max_value = value
		elif attribute == "life":
			$HUD/LifeBar.value = value
		elif attribute == "max_mana":
			$HUD/ManaBar.max_value = value
		else:
			$HUD/ManaBar.value = value
