extends CanvasLayer

const HEALTH_TEXTURES := [
	preload("res://MagicAssets/Interface/Kit/Base/Life Bar Animated 1.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Life Bar Animated 2.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Life Bar Animated 3.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Life Bar Animated 4.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Life Bar Animated 5.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Life Bar Animated 6.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Life Bar Animated 7.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Life Bar Animated 8.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Life Bar Animated 9.png"),
]

const MANA_TEXTURES := [
	preload("res://MagicAssets/Interface/Kit/Base/Power Bar Animated 1.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Power Bar Animated 2.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Power Bar Animated 3.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Power Bar Animated 4.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Power Bar Animated 5.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Power Bar Animated 6.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Power Bar Animated 7.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Power Bar Bar Animated 8.png"),
	preload("res://MagicAssets/Interface/Kit/Base/Power Bar Bar Animated 9.png"),
]

@onready var health_fill: TextureRect = $HealthContainer/HealthFill
@onready var mana_fill: TextureRect = $ManaContainer/ManaFill

var _bound_player: Combatant = null

func _ready() -> void:
	set_process(true)
	print("[HUD] ready")

func _process(_delta: float) -> void:
	if _bound_player:
		set_process(false)
		return

	var player := _find_player()
	if not player:
		print("[HUD] no player yet")
		print("[HUD] Player nodes:", get_tree().get_nodes_in_group("Player"))
		return

	_bind_player(player)
	_bound_player = player
	set_process(false)

func _find_player() -> Combatant:
	for candidate in get_tree().get_nodes_in_group("Player"):
		if candidate is Combatant:
			return candidate
	return null

func _bind_player(player: Combatant) -> void:
	_update_health_texture(player.health, player.max_health)
	_update_mana_texture(player.mana, player.max_mana)
	player.connect("health_changed", Callable(self, "_on_health_changed"))
	player.connect("mana_changed", Callable(self, "_on_mana_changed"))
	print("[HUD] bound to ", player.name, " (mana ", player.mana, "/", player.max_mana, ")")

func _on_health_changed(current: float, maximum: float) -> void:
	_update_health_texture(current, maximum)

func _on_mana_changed(current: float, maximum: float) -> void:
	_update_mana_texture(current, maximum)
	print("[HUD] mana_changed -> ", current, "/", maximum)

func _update_health_texture(current: float, maximum: float) -> void:
	health_fill.texture = HudUtils.select_frame(HEALTH_TEXTURES, current, maximum)

func _update_mana_texture(current: float, maximum: float) -> void:
	mana_fill.texture = HudUtils.select_frame(MANA_TEXTURES, current, maximum)
