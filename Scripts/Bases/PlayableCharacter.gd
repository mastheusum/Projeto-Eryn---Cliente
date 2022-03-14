extends Creature

class_name PlayableCharacter

var max_life : int
var life : int
var max_mana : int
var mana : int
var level : int
var attack_range : float = 50
var strength : int # physical damage
var constitution : int # max life
var dexterity : int # physical critical hit
var agility : int # attack speed
var intelligence : int # max mana
var willpower : int # resistance to crowd controls
var perception : int # magic critical hit
var wisdom : int # magic damage 

func receive_damage(value : int, type : int):
	pass

func attack(target_id : int, max_range : float, power : int):
	pass

func _on_dead():
	pass
