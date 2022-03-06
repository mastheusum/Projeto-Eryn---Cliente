extends PlayableCharacter

func _ready():
	$HUD/CharacterName.text = creature_name
	$HUD/LifeBar.max_value = max_life
	$HUD/LifeBar.value = life
	$HUD/ManaBar.max_value = max_mana
	$HUD/ManaBar.value = mana
	
	$AnimatedSprite.frames = load("res://Resources/Animations/"+str(sprite_index)+".tres")

func _on_TargetArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_RIGHT:
			$Mark.visible = ! $Mark.visible

func update_status(life : int, mana : int):
	self.life = life
	self.mana = mana
	$HUD/LifeBar.value = life
	$HUD/ManaBar.value = mana


func _on_Mark_visibility_changed():
	if $Mark.visible:
		GameManager.set_player_target( int(name) )
		$Tween.interpolate_property(
				$Mark, 'rotation_degrees',
				0, 360, 3, 
				Tween.TRANS_LINEAR, Tween.EASE_IN
			)
		$Tween.start()
	else:
		GameManager.set_player_target( -1 )
		$Tween.stop_all()

func _on_Tween_tween_all_completed():
	if $Mark.visible:
		$Tween.interpolate_property(
				$Mark, 'rotation_degrees',
				0, 360, 3, 
				Tween.TRANS_LINEAR, Tween.EASE_IN
			)
		$Tween.start()
