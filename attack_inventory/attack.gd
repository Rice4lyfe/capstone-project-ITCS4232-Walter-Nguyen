extends Resource

class_name Attack

enum ActionType { ATTACK, MAGIC, DEFEND }

@export var name: String = ""
@export var texture: Texture2D
@export var description: String = ""
@export var base_power: int = 0
@export var type: ActionType = ActionType.ATTACK

# Placeholder for custom logic — you can attach scripts/functions later
@export var has_custom_effect: bool = false
