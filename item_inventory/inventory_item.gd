extends Resource

class_name Item

@export var name: String = ""
@export var texture: Texture2D
@export var description: String = ""

enum EffectType {
	NONE,
	HEAL,
	BUFF_ATTACK,
	BUFF_DEF,
	RAISE_AGILITY
}

@export var effect_type: EffectType = EffectType.NONE
@export var effect_strength: int = 0
