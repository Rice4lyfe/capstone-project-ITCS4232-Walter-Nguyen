extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_play_pressed() -> void:
	$button_pressed.play()
	await get_tree().create_timer(0.15).timeout
	get_tree().change_scene_to_file("res://Scenes/introduction.tscn")

func _on_story_pressed() -> void:
	$button_pressed.play()
	DialogueManager.show_dialogue_balloon(load("res://Dialogue/menu_story.dialogue"),"story")

func _on_tutorial_pressed() -> void:
	$button_pressed.play()
	DialogueManager.show_dialogue_balloon(load("res://Dialogue/menu_story.dialogue"),"tutorial")


func _on_quit_pressed() -> void:
	$button_pressed.play()
	get_tree().quit()
