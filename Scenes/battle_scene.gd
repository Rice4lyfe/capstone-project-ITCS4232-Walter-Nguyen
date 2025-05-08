extends Control

@onready var story_label = $Location #determines location
@onready var progress_bar = $BattleProgress #determines how many fights are left before boss
@onready var text_box = $Action
@onready var text_box_text = $Action/text

@onready var confirmation_escape = $ConfirmationEscape

signal textbox_closed
signal combat_ended
signal battle_ended

#initiate enemies
@export var enemy_bandit = preload("res://enemy/bandit.tres")
@export var enemy_guard = preload("res://enemy/guard.tres")
@export var enemy_boss1 = preload("res://enemy/boss1.tres")

#initiate moves as buttons
@onready var bite = $"Player Choice"/HBoxContainer/AttackContainer/Bite
@onready var devour = $"Player Choice"/HBoxContainer/AttackContainer/Devour
@onready var chomp = $"Player Choice"/HBoxContainer/AttackContainer/Chomp
@onready var fire = $"Player Choice"/HBoxContainer/MagicContainer/Fire
@onready var aquelve = $"Player Choice"/HBoxContainer/MagicContainer/Aquelve
@onready var swish = $"Player Choice"/HBoxContainer/MagicContainer/Swish
@onready var resist = $"Player Choice"/HBoxContainer/DefendContainer/Resist
@onready var rage = $"Player Choice"/HBoxContainer/DefendContainer/Rage
@onready var embody = $"Player Choice"/HBoxContainer/DefendContainer/Embody

@onready var slot_labels = [
	$"Player Choice/Move1",
	$"Player Choice/Move2",
	$"Player Choice/Move3"
]

#for future reference
#bite
#devour
#chomp
#fire
#aquelve
#swish
#resist
#rage
#embody

var current_enemy = Enemy

var current_player_health = 0
var current_enemy_health = 0

var battle_won := 0

var story_backgrounds = {
	"Den_City": preload("res://Sprites/bg/thecity.png"),
	"Hash_Forest": preload("res://Sprites/bg/theforest.png"),
	"Reverse_Heaven": preload("res://Sprites/bg/theoppositeofheaven.png"),
	"Unknown": preload("res://Sprites/bg/thefinaldomain.png")
}

var escape_chance = randfn(0,1)
var dodge = randfn(0,1)

var player_action_queue: Array[Attack] = []
const MAX_QUEUE_SIZE = 3
var enemy_action_queue: Array[Attack] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerStats.current_hp = PlayerStats.max_hp
	set_health($"Player Options/HP",PlayerStats.current_hp,PlayerStats.max_hp)
	PlayerStats.story_progress = 1 #for testing
	escape_chance = randfn(0,1)
	text_box.hide()
	current_player_health = PlayerStats.current_hp
	
	reset_progress_battle()
	match PlayerStats.story_progress:
		1:
			current_enemy = enemy_bandit
			spawn_enemy(current_enemy)
			first_decider()
			story_label.text = "Location: Den City"
			$Background.texture = story_backgrounds["Den_City"]
		2:
			story_label.text = "Location: Hash Forest"
			$Background.texture = story_backgrounds["Hash_Forest"]
		3:
			story_label.text = "Location: ?Heaven¿"
			$Background.texture = story_backgrounds["Reverse_Heaven"]
		4:
			story_label.text = "Location: ?????"
			$Background.texture = story_backgrounds["Unknown"]
	await textbox_closed
	#bite.toggle_mode = true
	#devour.toggle_mode = true
	#chomp.toggle_mode = true
	#fire.toggle_mode = true
	#aquelve.toggle_mode = true
	#swish.toggle_mode = true
	#resist.toggle_mode = true
	#rage.toggle_mode = true
	#embody.toggle_mode = true
	$"Player Options".show()
	
func set_health(progress_bar,health,max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" %[health,max_health]
	
func spawn_enemy(current_enemy):
	set_health($"Enemy/HP",current_enemy.current_hp,current_enemy.max_hp)
	$Enemy/Enemy.texture = current_enemy.texture
	$Enemy/Name.text = current_enemy.name
	current_enemy_health = current_enemy.current_hp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("up"):
		#if battle_won < progress_bar.get_child_count():
			#update_battle_progress()
			#print("Battle Won:", battle_won)
		first_decider()
	if Input.is_action_just_pressed("down"):
		reset_progress_battle() #testing
	if text_box.visible:
		$"Player Options".hide()
		await textbox_closed
		$"Player Options".show()
	await combat_ended
	dodge = randf()
	print(dodge)

func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and text_box.visible:
		text_box.hide()
		emit_signal("textbox_closed")
	
func reset_progress_battle():
	battle_won = 0;
	for battle in progress_bar.get_children():
		battle.color = Color.BLACK

func update_battle_progress() -> void:
	battle_won += 1
	for i in progress_bar.get_child_count():
		var battle = progress_bar.get_child(i)
		if i < battle_won:
			battle.color = Color.AQUA
		else:
			battle.color = Color.BLACK
	#for i in range(progress_bar.get_child_count()):
		#var battle_rect = progress_bar.get_child(i)
		#if i < current_battle:
			#battle_rect.modulate = Color(0, 1, 0) # Green
		#else:
			#battle_rect.modulate = Color(0, 0, 0) # Black
			
		
func display_action(text):
	text_box.show()
	text_box_text.text = text

func _on_escape_button_pressed() -> void:
	$button_pressed.play()
	confirmation_escape.visible = true
	$"Player Options".hide()

func _on_yes_retreat_pressed() -> void:
	$button_pressed.play()
	if escape_chance < 0.5:
		confirmation_escape.visible = false
		DialogueManager.show_dialogue_balloon(load("res://Dialogue/story.dialogue"),"escapeWin")
		await get_tree().create_timer(1.2).timeout
		get_tree().change_scene_to_file("res://Scenes/introduction.tscn") 
	else:
		DialogueManager.show_dialogue_balloon(load("res://Dialogue/story.dialogue"),"escapeLose")


func _on_no_retreat_pressed() -> void:
	$button_pressed.play()
	confirmation_escape.visible = false
	$"Player Options".show()
	
func dodge_check(agility: int):
	var base = agility * 0.01 + 0.10
	if base > dodge:
		pass
	
func calc_phys_damage(attacker_attack: int, defender_defense: int) -> int:
	var base = (attacker_attack) - defender_defense #straightforward lol
	return max(1,base + randi() % 3)

func calc_spec_damage(attacker_attack: int, defender_defense: int) -> int: 
	var base = (attacker_attack * 2) - defender_defense
	return max(1,base + randi() % 3)

func first_decider() -> void:
	var coin = randfn(0,1)
	if coin < 0.5:
		$firstIndicator.text = "The First to Attack is: " + current_enemy.name
	else:
		$firstIndicator.text = "The First to Attack is: You"

func _on_attack_button_pressed() -> void:
	$button_pressed.play()
	$"Player Choice".show()
	$"Player Options".hide()

func _on_back_attack_pressed() -> void:
	$button_pressed.play()
	reset_player_action()
	$"Player Choice".hide()
	$"Player Options".show()
	

func _on_bite_pressed() -> void:
	$button_pressed.play()
	if player_action_queue.size() < MAX_QUEUE_SIZE:
		player_action_queue.append(PlayerStats.all_player_attacks[0])
		bite.disabled = true
		update_queue_display()
		print("Queued:", player_action_queue)
	else:
		print("Queue full!")

func _on_devour_pressed() -> void:
	$button_pressed.play()
	if player_action_queue.size() < MAX_QUEUE_SIZE:
		player_action_queue.append(PlayerStats.all_player_attacks[1])
		devour.disabled = true
		update_queue_display()
		print("Queued:", player_action_queue)
	else:
		print("Queue full!")

func _on_chomp_pressed() -> void:
	$button_pressed.play()
	if player_action_queue.size() < MAX_QUEUE_SIZE:
		player_action_queue.append(PlayerStats.all_player_attacks[2])
		chomp.disabled = true
		update_queue_display()
		print("Queued:", player_action_queue)
	else:
		print("Queue full!")

func _on_fire_pressed() -> void:
	$button_pressed.play()
	if player_action_queue.size() < MAX_QUEUE_SIZE:
		player_action_queue.append(PlayerStats.all_player_attacks[3])
		fire.disabled = true
		update_queue_display()
		print("Queued:", player_action_queue)
	else:
		print("Queue full!")

func _on_aquelve_pressed() -> void:
	$button_pressed.play()
	if player_action_queue.size() < MAX_QUEUE_SIZE:
		player_action_queue.append(PlayerStats.all_player_attacks[4])
		aquelve.disabled = true
		update_queue_display()
		print("Queued:", player_action_queue)
	else:
		print("Queue full!")

func _on_swish_pressed() -> void:
	$button_pressed.play()
	if player_action_queue.size() < MAX_QUEUE_SIZE:
		player_action_queue.append(PlayerStats.all_player_attacks[5])
		swish.disabled = true
		update_queue_display()
		print("Queued:", player_action_queue)
	else:
		print("Queue full!")

func _on_resist_pressed() -> void:
	$button_pressed.play()
	if player_action_queue.size() < MAX_QUEUE_SIZE:
		player_action_queue.append(PlayerStats.all_player_attacks[6])
		resist.disabled = true
		update_queue_display()
		print("Queued:", player_action_queue)
	else:
		print("Queue full!")

func _on_rage_pressed() -> void:
	$button_pressed.play()
	if player_action_queue.size() < MAX_QUEUE_SIZE:
		player_action_queue.append(PlayerStats.all_player_attacks[7])
		rage.disabled = true
		update_queue_display()
		print("Queued:", player_action_queue)
	else:
		print("Queue full!")


func _on_embody_pressed() -> void:
	$button_pressed.play()
	if player_action_queue.size() < MAX_QUEUE_SIZE:
		player_action_queue.append(PlayerStats.all_player_attacks[8])
		embody.disabled = true
		update_queue_display()
		print("Queued:", player_action_queue)
	else:
		print("Queue full!")

func reset_player_action() -> void:
	player_action_queue.clear()
	update_queue_display()
	for button in [bite,devour,chomp,fire,aquelve,swish,resist,rage,embody]:
		button.disabled = false
		
func reset_turn() -> void:
	reset_player_action()

func update_queue_display() -> void:
	for i in range(3):
		if i < player_action_queue.size():
			slot_labels[i].text = player_action_queue[i].name
		else:
			slot_labels[i].text = ""
