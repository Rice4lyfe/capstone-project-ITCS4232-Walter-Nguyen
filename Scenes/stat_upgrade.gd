extends Panel

@onready var hp_label = $VBoxContainer/HPContainer/HPLabel
@onready var hp_button = $VBoxContainer/HPContainer/HP_plus_button
@onready var atk_label = $VBoxContainer/ATKContainer/ATKLabel
@onready var atk_button = $VBoxContainer/ATKContainer/ATK_plus_button
@onready var speA_label = $VBoxContainer/SPEATKContainer/SPEATKLabel
@onready var speA_button = $VBoxContainer/SPEATKContainer/SPEATK_plus_button
@onready var def_label = $VBoxContainer/DEFContainer/DEFLabel
@onready var def_button = $VBoxContainer/DEFContainer/DEF_plus_button
@onready var speD_label = $VBoxContainer/SPEDEFContainer/SPEDEFLabel
@onready var speD_button = $VBoxContainer/SPEDEFContainer/SPEDEF_plus_button
@onready var agi_label = $VBoxContainer/AgilityContainer/AGILabel
@onready var agi_button = $VBoxContainer/AgilityContainer/AGI_plus_button
@onready var skill_points_label = $SPLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_labels()

func _on_hp_plus_button_pressed() -> void:
	if PlayerStats.skill_points > 0:
		PlayerStats.max_hp += 1
		PlayerStats.skill_points -= 1
		update_labels()

func _on_atk_plus_button_pressed() -> void:
	if PlayerStats.skill_points > 0:
		PlayerStats.atk += 1
		PlayerStats.skill_points -= 1
		update_labels()
	pass # Replace with function body.


func _on_speatk_plus_button_pressed() -> void:
	if PlayerStats.skill_points > 0:
		PlayerStats.sp_atk += 1
		PlayerStats.skill_points -= 1
		update_labels()
	pass # Replace with function body.


func _on_def_plus_button_pressed() -> void:
	if PlayerStats.skill_points > 0:
		PlayerStats.def += 1
		PlayerStats.skill_points -= 1
		update_labels()
	pass # Replace with function body.


func _on_spedef_plus_button_pressed() -> void:
	if PlayerStats.skill_points > 0:
		PlayerStats.sp_def += 1
		PlayerStats.skill_points -= 1
		update_labels()
	pass # Replace with function body.


func _on_agi_plus_button_pressed() -> void:
	if PlayerStats.skill_points > 0:
		PlayerStats.agility += 1
		PlayerStats.skill_points -= 1
		update_labels()
	pass # Replace with function body.

func update_labels():
	hp_label.text = "HP: %d" % PlayerStats.max_hp
	atk_label.text = "ATK: %d" % PlayerStats.atk
	speA_label.text = "Spe. ATK: %d" % PlayerStats.sp_atk
	def_label.text = "DEF: %d" % PlayerStats.def
	speD_label.text = "Spe. DEF: %d" % PlayerStats.sp_def
	agi_label.text = "AGI: %d" % PlayerStats.agility
	skill_points_label.text = "Skill Points: %d" % PlayerStats.skill_points
