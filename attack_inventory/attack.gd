extends Resource

class_name Attack

enum ActionType { ATTACK, MAGIC, DEFEND }

enum EffectType {
	NONE,
	HEAL,
	TAKE_DAMAGE,
	BUFF_ATTACK,
	BUFF_DEF,
	RAISE_AGILITY
}

@export var name: String = ""
@export var texture: Texture2D
@export var description: String = ""
@export var base_power: int = 0
@export var type: ActionType = ActionType.ATTACK

# Placeholder for custom logic — you can attach scripts/functions later
@export var effect_type: EffectType = EffectType.NONE
@export var effect_strength: int = 0
