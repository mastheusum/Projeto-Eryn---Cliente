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

