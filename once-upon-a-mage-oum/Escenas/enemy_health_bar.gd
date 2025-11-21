extends TextureRect

const HEALTH_TEXTURES := [
	preload("res://MagicAssets/Interface/Kit/Base/Life Bar Animated 1.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Life Bar Animated 2.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Life Bar Animated 3.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Life Bar Animated 4.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Life Bar Animated 5.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Life Bar Animated 6.png"),
]

@onready var _combatant: Combatant = get_parent() as Combatant

func _ready() -> void:
	if not _combatant:
		return

	_update_texture(_combatant.health, _combatant.max_health)
	_combatant.connect("health_changed", Callable(self, "_on_health_changed"))

func _on_health_changed(current: float, maximum: float) -> void:
	_update_texture(current, maximum)

func _update_texture(current: float, maximum: float) -> void:
	texture = HudUtils.select_frame(HEALTH_TEXTURES, current, maximum)
