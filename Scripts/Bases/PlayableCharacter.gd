extends Creature

class_name PlayableCharacter

var max_life : int
var life : int
var max_mana : int
var mana : int
var level : int
var attack_range : float = 50

func receive_damage(value : int, type : int):
	pass

func attack(target_id : int, max_range : float, power : int):
	pass

func _on_dead():
	pass
