extends Control

@onready var story_label = $Location #determines location
@onready var progress_bar = $BattleProgress #determines how many fights are left before boss
@onready var text_box = $Action
@onready var text_box_text = $Action/text

@onready var confirmation_escape = $ConfirmationEscape

signal textbox_closed

var battle_won := 0

var story_backgrounds = {
	"Den_City": preload("res://Sprites/bg/thecity.png"),
	"Hash_Forest": preload("res://Sprites/bg/theforest.png"),
	"Reverse_Heaven": preload("res://Sprites/bg/theoppositeofheaven.png"),
	"Unknown": preload("res://Sprites/bg/thefinaldomain.png")
}

var escape_chance = randf()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	PlayerStats.story_progress = 1 #for testing
	escape_chance = randf()
	text_box.hide()
	
	reset_progress_battle()
	match PlayerStats.story_progress:
		1:
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
	#display_action("Welcome!")
	await textbox_closed
	$"Player Options".show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("up"):
		#if battle_won < progress_bar.get_child_count():
			#update_battle_progress()
			#print("Battle Won:", battle_won)
	#if Input.is_action_just_pressed("down"):
		#reset_progress_battle() testing
	if text_box.visible:
		$"Player Options".hide()
		await textbox_closed
		$"Player Options".show()

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
			battle.color = Color.GREEN
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
	confirmation_escape.visible = true
	$"Player Options".hide()

func _on_yes_retreat_pressed() -> void:
	if escape_chance < 0.5:
		confirmation_escape.visible = false
		DialogueManager.show_dialogue_balloon(load("res://Dialogue/story.dialogue"),"escapeWin")
		await get_tree().create_timer(2.0).timeout
		get_tree().change_scene_to_file("res://Scenes/introduction.tscn") 
	else:
		DialogueManager.show_dialogue_balloon(load("res://Dialogue/story.dialogue"),"escapeLose")


func _on_no_retreat_pressed() -> void:
	confirmation_escape.visible = false
	$"Player Options".show()
