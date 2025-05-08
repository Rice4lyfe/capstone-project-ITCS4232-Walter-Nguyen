extends Resource

class_name Enemy

@export var name: String
@export var texture: Texture2D
@export var max_hp: int
@export var current_hp: int
@export var atk: int
@export var sp_atk: int
@export var def: int
@export var sp_def: int
@export var agility: int
@export var attack_list: Array[Attack]
@export var is_boss: bool
@export var skill_point_loot: int
