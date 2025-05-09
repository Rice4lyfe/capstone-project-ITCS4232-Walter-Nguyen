extends Control

@onready var stats_label = $StatsLabel
@onready var what_now = $whatnowLabel
@onready var preparations_menu = $initiate_buttons  
@onready var skill_points_nofi = $SPNotificationLabel

@onready var confirmation_battle = $ConfirmationBattle
@onready var confirmation_quit_menu = $ConfirmationQuitMenu

@onready var yes_button = $ConfirmationQuitMenu/VBoxContainer/yes_quit_button
@onready var no_button = $ConfirmationQuitMenu/VBoxContainer/no_quit_button

@onready var stat_upgrade = $StatUpgrade

@onready var equip_menu = $EquipMenu

@onready var item_buttons = [
	$EquipMenu/TabContainer/VBoxContainer/Item1,
	$EquipMenu/TabContainer/VBoxContainer/Item2,
	$EquipMenu/TabContainer/VBoxContainer/Item3
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	preparations_menu.visible = false #the buttons at the start of the gmae
	confirmation_quit_menu.visible = false #confirm to quit
	confirmation_battle.visible = false #confirm to battle
	what_now.visible = false #what now label
	skill_points_nofi.visible = false #Skill point notification
	stat_upgrade.visible = false #stats menu
	equip_menu.visible = false #equip menu
	#DialogueManager.show_dialogue_balloon(load("res://Dialogue/story.dialogue"),"prologue")
	#DialogueManager.dialogue_ended.connect(_on_preperations)
	match PlayerStats.story_progress:
		0:
			if (PlayerStats.complete_prologue == false):
				PlayerStats.complete_prologue = true
				DialogueManager.show_dialogue_balloon(load("res://Dialogue/story.dialogue"),"prologue")
				DialogueManager.dialogue_ended.connect(_on_preperations)
			PlayerStats.story_progress += 1
		1:
			_on_preperations()
		2:
			if (PlayerStats.complete_chapter_1 == false):
				PlayerStats.complete_chapter_1 = true
				DialogueManager.show_dialogue_balloon(load("res://Dialogue/story.dialogue"),"chapter_1")
				DialogueManager.dialogue_ended.connect(_on_preperations)
			_on_preperations()
		3:
			if (PlayerStats.complete_chapter_2 == false):
				PlayerStats.complete_chapter_2 = true
				DialogueManager.show_dialogue_balloon(load("res://Dialogue/story.dialogue"),"chapter_2")
				DialogueManager.dialogue_ended.connect(_on_preperations)
			_on_preperations()
		4:
			if (PlayerStats.complete_chapter_3 == false):
				PlayerStats.complete_chapter_3 = true
				DialogueManager.show_dialogue_balloon(load("res://Dialogue/story.dialogue"),"chapter_2")
				DialogueManager.dialogue_ended.connect(_on_preperations)
			_on_preperations()

func _process(_delta: float) -> void:
	if PlayerStats.skill_points >= 1:
		skill_points_nofi.visible = true
	else:
		skill_points_nofi.visible = false

func _on_preperations(_unused = null) -> void:
	preparations_menu.visible = true
	what_now.visible = true
	
	stats_label.text = "HP: %d\nAtk: %d\nSp. Atk: %d\nDef: %d\nSp. Def: %d\nAgility: %d\nSP: %d" % [
		PlayerStats.max_hp,
		PlayerStats.atk,
		PlayerStats.sp_atk,
		PlayerStats.def,
		PlayerStats.sp_def,
		PlayerStats.agility,
		PlayerStats.skill_points
	]

func _on_start_battle_pressed() -> void:
	confirmation_battle.visible = true
	what_now.visible = false
	preparations_menu.visible = false
	stats_label.text = ""
	$button_pressed.play()

func _on_stats_button_pressed() -> void:
	preparations_menu.visible = false
	confirmation_quit_menu.visible = false
	confirmation_battle.visible = false
	what_now.visible = false
	stat_upgrade.visible = true
	stats_label.text = ""
	$button_pressed.play()


func _on_skills_button_pressed() -> void:
	what_now.visible = false
	preparations_menu.visible = false
	stats_label.text = ""
	equip_menu.visible = true
	$button_pressed.play()

func _on_end_button_pressed() -> void:
	$button_pressed.play()
	show_confirmationQuit_menu()
	
# Called when you need to show the confirmation menu
func show_confirmationQuit_menu() -> void:
	confirmation_quit_menu.visible = true  # Show the confirmation menu
	what_now.visible = false
	preparations_menu.visible = false
	stats_label.text = ""

# Hide the confirmation menu after a choice is made
func _on_yes_quit_button_pressed() -> void:
	confirmation_quit_menu.visible = false
	PlayerStats.story_progress = 0
	$button_pressed.play()
	get_tree().change_scene_to_file("res://Scenes/game_over.tscn") #Change this to the Game Over Screen

func _on_no_quit_button_pressed() -> void:
	confirmation_quit_menu.visible = false
	what_now.visible = true
	preparations_menu.visible = true
	stats_label.text = "HP: %d\nAtk: %d\nSp. Atk: %d\nDef: %d\nSp. Def: %d\nAgility: %d\nSP: %d" % [
		PlayerStats.max_hp,
		PlayerStats.atk,
		PlayerStats.sp_atk,
		PlayerStats.def,
		PlayerStats.sp_def,
		PlayerStats.agility,
		PlayerStats.skill_points
	]
	$button_pressed.play()
	
func _on_back_pressed() -> void:
	preparations_menu.visible = true
	what_now.visible = true
	stat_upgrade.visible = false
	equip_menu.visible = false
	stats_label.text = "HP: %d\nAtk: %d\nSp. Atk: %d\nDef: %d\nSp. Def: %d\nAgility: %d\nSP: %d" % [
		PlayerStats.max_hp,
		PlayerStats.atk,
		PlayerStats.sp_atk,
		PlayerStats.def,
		PlayerStats.sp_def,
		PlayerStats.agility,
		PlayerStats.skill_points
	]
	$button_pressed.play()


func _on_yes_battle_button_pressed() -> void:
	confirmation_battle.visible = false
	$button_pressed.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://Scenes/battle_scene.tscn") #Change this to the Game Over Screen
	


func _on_no_battle_button_pressed() -> void:
	$button_pressed.play()
	confirmation_battle.visible = false
	what_now.visible = true
	preparations_menu.visible = true
	stats_label.text = "HP: %d\nAtk: %d\nSp. Atk: %d\nDef: %d\nSp. Def: %d\nAgility: %d\nSP: %d" % [
		PlayerStats.max_hp,
		PlayerStats.atk,
		PlayerStats.sp_atk,
		PlayerStats.def,
		PlayerStats.sp_def,
		PlayerStats.agility,
		PlayerStats.skill_points
	]
	
func update_item_menu():
	for i in item_buttons.size():
		if i < PlayerStats.inventory.size():
			var item = PlayerStats.inventory[i]
			item_buttons[i].text = item.name + item.description
			item_buttons[i].disabled = false
			item_buttons[i].connect("pressed", Callable(self, "_on_item_pressed").bind(item,i))
		else:
			item_buttons[i].text = "Empty"
			item_buttons[i].disabled = true

func _on_item_pressed(item: Item, index: int):
	apply_item_effect(PlayerStats, item.effect_type, item.effect_strength)
	PlayerStats.inventory.remove_at(index)
	update_item_menu()
	
func apply_item_effect(target, effect_type: Item.EffectType, strength: int) -> void:
	match effect_type:
		Item.EffectType.HEAL:
			target.current_hp = clamp(target.current_hp + strength, 0, target.max_hp)
		Item.EffectType.BUFF_ATTACK:
			target.atk += strength
			target.spe_atk += strength
		Item.EffectType.BUFF_DEF:
			target.def += strength
			target.sp_def += strength
		Item.EffectType.RAISE_AGILITY:
			target.agility += strength


func _on_view_items_tab_clicked(tab: int) -> void:
	update_item_menu()
