extends PlayableCharacter

func _ready():
	$HUD/CharacterName.text = creature_name
	$HUD/LifeBar.max_value = max_life
	$HUD/LifeBar.value = life
	$HUD/ManaBar.max_value = max_mana
	$HUD/ManaBar.value = mana
