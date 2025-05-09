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

@onready var item_buttons = [
	$ItemMenu/VBoxContainer/Item1,
	$ItemMenu/VBoxContainer/Item2,
	$ItemMenu/VBoxContainer/Item3
]

@onready var all_items: Array[Item] = [
	preload("res://item_inventory/items/bigGauntlet.tres"),
	preload("res://item_inventory/items/bigpotion.tres"),
	preload("res://item_inventory/items/bigShield.tres"),
	preload("res://item_inventory/items/boots.tres"),
	preload("res://item_inventory/items/mediumGauntlet.tres"),
	preload("res://item_inventory/items/mediumpotion.tres"),
	preload("res://item_inventory/items/mediumShield.tres"),
	preload("res://item_inventory/items/smallGauntlet.tres"),
	preload("res://item_inventory/items/smallpotion.tres"),
	preload("res://item_inventory/items/smallShield.tres")
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

var escape_chance = randf()
var dodge = randf()
var first_check = false

#var player_action_queue: Array[Attack] = []
#const MAX_QUEUE_SIZE = 3
#var enemy_action_queue: Array[Attack] = []
#var action_queue: Array[Attack] = []

var player_attack = PlayerStats.all_player_attacks[0]
var enemy_attack = Attack

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerStats.current_hp = PlayerStats.max_hp
	set_health($HP,PlayerStats.current_hp,PlayerStats.max_hp)
	PlayerStats.story_progress = 1 #for testing
	escape_chance = randf()
	text_box.hide()
	current_player_health = PlayerStats.current_hp
	
	reset_progress_battle()
	match PlayerStats.story_progress:
		1:
			current_enemy = enemy_bandit
			spawn_enemy(current_enemy)
			#generate_enemy_moves(current_enemy)
			#for attack in enemy_action_queue:
				#print("Enemy selected:", attack.name)
			first_decider()
			$battle_music_world_1.play()
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
	$"Player Options".show()
	
func set_health(progress_bar,health,max_health):
	progress_bar.value = health
	progress_bar.max_value = max_health
	progress_bar.get_node("Label").text = "HP: %d/%d" %[health,max_health]
	
func spawn_enemy(current_enemy):
	if current_enemy.is_boss == true:
		$boss_entrance.play()
	$AnimationPlayer.play("enemy_summoned")
	set_health($"Enemy/HP",current_enemy.current_hp,current_enemy.max_hp)
	$Enemy/Enemy.texture = current_enemy.texture
	$Enemy/Name.text = current_enemy.name
	current_enemy_health = current_enemy.current_hp

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("up"):
		##if battle_won < progress_bar.get_child_count():
			##update_battle_progress()
			##print("Battle Won:", battle_won)
		#first_decider()
	#if Input.is_action_just_pressed("down"):
		#reset_progress_battle() #testing
	if text_box.visible:
		$"Player Options".hide()
		await textbox_closed
		$"Player Options".show()
	await combat_ended
	dodge = randf()
	print(dodge)

func _input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and text_box.visible and ($ConfirmationProceed.visible==false):
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
	
func dodge_check(agility: int) -> bool:
	var base = (agility * 0.01) + 0.10
	if base > dodge:
		dodge = randf()
		return true
	else:
		return false
	
func calc_damage(attacker_attack: int, defender_defense: int, base_attack: int) -> int:
	var base = (attacker_attack + base_attack) - defender_defense #straightforward lol
	return max(1,base + randi() % 3)
	
func calc_spe_damage(spe_attacker_attack: int, spe_defender_defense: int, base_attack: int) -> int:
	var base = (spe_attacker_attack * 2) - spe_defender_defense #straightforward lol
	return max(1,base + randi() % 3)

func first_decider() -> bool:
	var coin = randf()
	if coin < 0.5:
		$firstIndicator.text = "The First to Attack is: " + current_enemy.name
		return false
	else:
		$firstIndicator.text = "The First to Attack is: You"
		return true

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
	#if player_action_queue.size() < MAX_QUEUE_SIZE:
		#player_action_queue.append(PlayerStats.all_player_attacks[0])
	player_attack = PlayerStats.all_player_attacks[0]
	bite.disabled = true
		#update_queue_display()
		#print("Queued:", player_action_queue)
	#else:
		#print("Queue full!")

func _on_devour_pressed() -> void:
	$button_pressed.play()
	#if player_action_queue.size() < MAX_QUEUE_SIZE:
		#player_action_queue.append(PlayerStats.all_player_attacks[1])
	player_attack = PlayerStats.all_player_attacks[1]
	devour.disabled = true
		#update_queue_display()
		##print("Queued:", player_action_queue)
	#else:
		#print("Queue full!")

func _on_chomp_pressed() -> void:
	$button_pressed.play()
	#if player_action_queue.size() < MAX_QUEUE_SIZE:
		#player_action_queue.append(PlayerStats.all_player_attacks[2])
	player_attack = PlayerStats.all_player_attacks[2]
	chomp.disabled = true
		#update_queue_display()
		##print("Queued:", player_action_queue)
	#else:
		#print("Queue full!")

func _on_fire_pressed() -> void:
	$button_pressed.play()
	#if player_action_queue.size() < MAX_QUEUE_SIZE:
		#player_action_queue.append(PlayerStats.all_player_attacks[3])
	player_attack = PlayerStats.all_player_attacks[3]
	fire.disabled = true
		#update_queue_display()
		##print("Queued:", player_action_queue)
	#else:
		#print("Queue full!")

func _on_aquelve_pressed() -> void:
	$button_pressed.play()
	#if player_action_queue.size() < MAX_QUEUE_SIZE:
		#player_action_queue.append(PlayerStats.all_player_attacks[4])
	player_attack = PlayerStats.all_player_attacks[4]
	aquelve.disabled = true
		#update_queue_display()
		##print("Queued:", player_action_queue)
	#else:
		#print("Queue full!")

func _on_swish_pressed() -> void:
	$button_pressed.play()
	#if player_action_queue.size() < MAX_QUEUE_SIZE:
		#player_action_queue.append(PlayerStats.all_player_attacks[5])
	player_attack = PlayerStats.all_player_attacks[5]
	swish.disabled = true
		#update_queue_display()
		##print("Queued:", player_action_queue)
	#else:
		#print("Queue full!")

func _on_resist_pressed() -> void:
	$button_pressed.play()
	#if player_action_queue.size() < MAX_QUEUE_SIZE:
		#player_action_queue.append(PlayerStats.all_player_attacks[6])
	player_attack = PlayerStats.all_player_attacks[6]
	resist.disabled = true
		#update_queue_display()
		##print("Queued:", player_action_queue)
	#else:
		#print("Queue full!")

func _on_rage_pressed() -> void:
	$button_pressed.play()
	#if player_action_queue.size() < MAX_QUEUE_SIZE:
		#player_action_queue.append(PlayerStats.all_player_attacks[7])
	player_attack = PlayerStats.all_player_attacks[7]
	rage.disabled = true
		#update_queue_display()
		##print("Queued:", player_action_queue)
	#else:
		#print("Queue full!")


func _on_embody_pressed() -> void:
	$button_pressed.play()
	#if player_action_queue.size() < MAX_QUEUE_SIZE:
		#player_action_queue.append(PlayerStats.all_player_attacks[8])
	player_attack = PlayerStats.all_player_attacks[8]
	embody.disabled = true
		#update_queue_display()
		##print("Queued:", player_action_queue)
	#else:
		#print("Queue full!")
		
func generate_enemy_move(enemy: Enemy) -> Attack:
	var attacks = enemy.attack_list.duplicate()
	attacks.shuffle()
	return attacks[randi_range(0,attacks.size() - 1)]

func reset_player_action() -> void:
	#player_action_queue.clear()
	#update_queue_display()
	for button in [bite,devour,chomp,fire,aquelve,swish,resist,rage,embody]:
		button.disabled = false
	player_attack = PlayerStats.all_player_attacks[0]

#func reset_enemy_action() -> void:
	##enemy_action_queue.clear()
	##generate_enemy_moves(current_enemy)
	##first_decider()
		
func reset_turn() -> void:
	reset_player_action()
	#reset_enemy_action()
	$"Player Options".show()

#func update_queue_display() -> void:
	#for i in range(3):
		#if i < player_action_queue.size():
			#slot_labels[i].text = player_action_queue[i].name
		#else:
			#slot_labels[i].text = ""

func _on_engage_attack_pressed() -> void:
	initiate_player_combat(player_attack,current_enemy)

func initiate_player_combat(attack: Attack,attacker: Enemy):
	$"Player Choice".hide()
	var damage = 0
	#if dodge_check(current_enemy.agility) == false:
	match attack.type:
		Attack.ActionType.ATTACK:
			$physical_attack.play()
			damage = calc_damage(attack.base_power,current_enemy.def, PlayerStats.atk)
			current_enemy_health = max(0, current_enemy_health - damage)
			set_health($Enemy/HP, current_enemy_health, current_enemy.max_hp)
			if attack.effect_type != Attack.EffectType.NONE:
				apply_attack_effect(PlayerStats, attack.effect_type, attack.effect_strength)
			display_action("%s deals %d damage" % [attack.name,damage])
			$AnimationPlayer.play("enemy_damaged")
		Attack.ActionType.MAGIC:
			$magic_attack.play()
			damage = calc_spe_damage(attack.base_power,current_enemy.sp_def, PlayerStats.sp_atk)
			current_enemy_health = max(0, current_enemy_health - damage)
			set_health($Enemy/HP, current_enemy_health, current_enemy.max_hp)
			if attack.effect_type != Attack.EffectType.NONE:
				apply_attack_effect(PlayerStats, attack.effect_type, attack.effect_strength)
			display_action("%s deals %d damage" % [attack.name,damage])
			$AnimationPlayer.play("enemy_damaged")
		Attack.ActionType.DEFEND:
			apply_attack_effect(PlayerStats, attack.effect_type, attack.effect_strength)
			display_action("%s Buff" % [attack.name])
	reset_player_action()
	dodge_check(current_enemy.agility)
	await textbox_closed
	if current_player_health == 0:
		get_tree().change_scene_to_file("res://Scenes/game_over.tscn") 
	if current_enemy_health == 0:
		PlayerStats.skill_points += current_enemy.skill_point_loot
		var roll = randf()
		if roll <= 0.2:
			var droppped_item = all_items.pick_random()
			PlayerStats.inventory.append(droppped_item)
			display_action("YOU JUST GOT: %s" % droppped_item.name)
		else:
			display_action("Nothing dropped...")
		if current_enemy.is_boss == true:
			match PlayerStats.story_progress:
				1:
					DialogueManager.show_dialogue_balloon(load("res://Dialogue/story.dialogue"),"raglokEnd")
					PlayerStats.story_progress += 1
					get_tree().change_scene_to_file("res://Scenes/introduction.tscn") 
				2:
					pass
		else:		
			player_battle_end()
	else:
		enemy_turn()
	
func initiate_enemy_combat(attack: Attack) -> void:
	var damage = 0
	match attack.type:
		Attack.ActionType.ATTACK:
			damage = calc_damage(attack.base_power,PlayerStats.def, current_enemy.atk)
			current_player_health = max(0, current_player_health - damage)
			set_health($HP, current_player_health, PlayerStats.max_hp)
		Attack.ActionType.MAGIC:
			damage = calc_spe_damage(attack.base_power,PlayerStats.sp_def, current_enemy.sp_atk)
			current_player_health  = max(0, current_player_health - damage)
			set_health($HP, current_player_health, PlayerStats.max_hp)
		Attack.ActionType.DEFEND:
			pass
	display_action("%s deals %d damage" % [attack.name,damage])
	await get_tree().create_timer(5).timeout
			
func enemy_turn() -> void:
	var enemy_attack = generate_enemy_move(current_enemy)
	initiate_enemy_combat(enemy_attack)
	if current_player_health == 0:
		get_tree().change_scene_to_file("res://Scenes/game_over.tscn") 
	
func player_battle_end():
	#display_action("%s has fallen." % [current_enemy.name])
	$AnimationPlayer.play("enemy_defeated")
	update_battle_progress()
	$ConfirmationProceed.visible = true

#func loot() -> void:
	

#func start_combat():
	#$"Player Choice".hide()
	#for i in range(3):
		#if first_check == true:
			#action_queue.append(player_action_queue[i])
			##print("Attack added:", player_action_queue[i].name)
			#await get_tree().create_timer(1.0).timeout
			#action_queue.append(enemy_action_queue[i])
			##print("Attack added:", enemy_action_queue[i].name)
		#else:
			#action_queue.append(enemy_action_queue[i])
			##print("Attack added:", enemy_action_queue[i].name)
			#await get_tree().create_timer(1.0).timeout
			#action_queue.append(player_action_queue[i])
			##print("Attack added:", player_action_queue[i].name)
	#for attack in action_queue:
		#print("Attack selected:", attack.name)
	#
#
#func process_combat():
	#while action_queue.size () > 0:
		#var current_attack = action_queue.pop_front()
		#execute_attack(current_attack)
		#await get_tree().create_timer(1.0).timeout
	#end_combat()
#
#func execute_attack(attack: Attack):
	#if attack is Attack:
		#var damage = calculate_damage(attack)
	#
	#if not dodge_check(current_enemy.agility):
		#apply_damage(attack.damage)
	#else:
		#display_action("Dodged.")
#
## Example damage calculation
#func calculate_damage(attack: Attack) -> int:
	#var base_damage = attack.base_power  # This would be the power of the attack
	#var damage = base_damage - current_enemy.defense  # Subtract enemy defense
	#return max(damage, 0)  # Make sure damage is not negative
#
## Apply the damage to the enemy
#func apply_damage(damage: int):
	#current_enemy.current_hp -= damage  # Subtract damage from enemy's current HP
	#set_health($Enemy/HP, current_enemy.current_hp, current_enemy.max_hp)
	#if current_enemy.current_hp <= 0:
		#end_combat()  # End combat if the enemy's health reaches 0
## Apply the damage to the enemy
#
#
## End the combat
#func end_combat():
	#if current_enemy.current_hp <= 0:
		#pass
	 #

func _on_proceed_button_pressed() -> void:
	$ConfirmationProceed.visible = false
	match PlayerStats.story_progress:
		0:
			pass
		1:
			match battle_won:
				1:
					spawn_enemy(enemy_bandit)
				2:
					spawn_enemy(enemy_bandit)
				3:
					DialogueManager.show_dialogue_balloon(load("res://Dialogue/story.dialogue"),"tease")
					spawn_enemy(enemy_guard)
				4:
					spawn_enemy(enemy_guard)
				5:
					$battle_music_world_1.stop()
					$boss_music.play()
					DialogueManager.show_dialogue_balloon(load("res://Dialogue/story.dialogue"),"raglokIntro")
					spawn_enemy(enemy_boss1)
		2:
			pass
	
func _on_retreat_button_pressed() -> void:
	reset_progress_battle()
	get_tree().change_scene_to_file("res://Scenes/introduction.tscn")
	
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
			
func apply_attack_effect(target, effect_type: Attack.EffectType, strength: int) -> void:
	match effect_type:
		Attack.EffectType.HEAL:
			current_player_health  = max(0, current_player_health + strength)
			set_health($HP, current_player_health, PlayerStats.max_hp)
		Attack.EffectType.TAKE_DAMAGE:
			current_player_health  = max(0, current_player_health - strength)
			set_health($HP, current_player_health, PlayerStats.max_hp)
		Attack.EffectType.BUFF_ATTACK:
			target.atk += strength
			target.spe_atk += strength
		Attack.EffectType.BUFF_DEF:
			target.def += strength
			target.sp_def += strength
		Attack.EffectType.RAISE_AGILITY:
			target.agility += strength #not used
#HEAL,
	#TAKE_DAMAGE,
	#BUFF_ATTACK,
	#BUFF_DEF,
	#RAISE_AGILITY

func _on_item_button_pressed() -> void:
	$button_pressed.play()
	$"Player Options".hide()
	$ItemMenu.show()
	update_item_menu()

func _on_back_item_pressed() -> void:
	$button_pressed.play()
	$"Player Options".show()
	$ItemMenu.hide()

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
			
