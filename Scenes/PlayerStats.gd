#file for keeping all of the player stats
extends Node

var max_hp: int = 20
var current_hp: int
var atk: int
var sp_atk: int
var def: int
var sp_def: int
var agility: int
var story_progress: int = 0
var skill_points: int = 2

var inventory: Array[Item] = []
const MAX_ITEMS = 3

var attack_choice: Array[Attack] = []
var equipped_attacks: Dictionary = {
	Attack.ActionType.ATTACK: [],
	Attack.ActionType.MAGIC: [],
	Attack.ActionType.DEFEND: []
	}
	
var all_player_attacks: Array[Attack] = [
	preload("res://attack_inventory/attacks/player_attack/Bite.tres"),
	preload("res://attack_inventory/attacks/player_attack/Devour.tres"),
	preload("res://attack_inventory/attacks/player_attack/Chomp.tres"),
	preload("res://attack_inventory/attacks/player_attack/Punisher.tres"),
	preload("res://attack_inventory/attacks/player_attack/Fire.tres"),
	preload("res://attack_inventory/attacks/player_attack/Aquelve.tres"),
	preload("res://attack_inventory/attacks/player_attack/Swish.tres"),
	preload("res://attack_inventory/attacks/player_attack/Avarite.tres"),
	preload("res://attack_inventory/attacks/player_attack/Resist.tres"),
	preload("res://attack_inventory/attacks/player_attack/Rage.tres"),
	preload("res://attack_inventory/attacks/player_attack/Embody.tres"),
	preload("res://attack_inventory/attacks/player_attack/PKicker.tres")
]

#Punisher - 2 attack. Double this attack if you did take damage the last attack (in the stack)
#Bite - 3 attack. 
#Devour - 6 attack. You lose 1/8(rounded down) life.
#Chomp - 4 attack. You gain 1/6(rounded up) life.
#Punisher
#
#Magic
#Fire - 8 attack. You lose 1/4(rounded down) life.
#Aquelve - 2 attack. The next damage you take (in the stack) is reduced by 3 attack
#Swish - 12 attack. You take 1/2 more damage next attack
#Avarite - 5 attack. The basic magic.
#
#Defend
#Resist - Raise your def/speDef by some amount
#Phoenix kicker - heal the damage you took from a previous attack and add it to the next attack
#Rage - Gain attack/speATK by some amount
#Embody - Block the next attack but any remaining attack does 0 damage

func _init():
	current_hp = max_hp
	atk = randi_range(5, 7)
	sp_atk = randi_range(5, 8)
	def = randi_range(5, 7)
	sp_def = randi_range(3, 6)
	agility = randi_range(4, 4)
	story_progress = 0
	skill_points = 2
	
func _ready() -> void:
	for attack in all_player_attacks:
		match attack.type:
			Attack.ActionType.ATTACK:
				if equipped_attacks[Attack.ActionType.ATTACK].size() < 3:
					equipped_attacks[Attack.ActionType.ATTACK].append(attack)
			Attack.ActionType.MAGIC:
				if equipped_attacks[Attack.ActionType.MAGIC].size() < 3:
					equipped_attacks[Attack.ActionType.MAGIC].append(attack)
			Attack.ActionType.DEFEND:
				if equipped_attacks[Attack.ActionType.DEFEND].size() < 3:
					equipped_attacks[Attack.ActionType.DEFEND].append(attack)
	for type in equipped_attacks.keys():
		print("Equipped ", type, ":")
		for attack in equipped_attacks[type]:
			print("  - ", attack.name)

func add_item(new_item: Item) -> bool:
	if inventory.size() < MAX_ITEMS:
		inventory.append(new_item)
		return true
	else:
		return false

func remove_item(item: Item) -> void:
	inventory.erase(item)
	
func use_item(index: int) -> void:
	if index >= 0 and index < inventory.size():
		var item = inventory[index]
		item.effect.call()
		inventory.remove_at(index)

func equip_attack(attack: Attack) -> bool:
	var type = attack.action_type
	
	if attack in equipped_attacks[type]:
		return false
	if equipped_attacks[type].size() >= 3:
		return false
	equipped_attacks[type].append(attack)
	return true

func unequip_attack(attack: Attack) -> bool:
	var type = attack.action_type
	if attack in equipped_attacks[type]:
		equipped_attacks[type].erase(attack)
		return true
	return false
