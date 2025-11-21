extends CharacterBody2D
class_name Combatant

signal health_changed(current: float, maximum: float)
signal mana_changed(current: float, maximum: float)
signal died()

@export var max_health: float = 100.0
@export var max_mana: float = 96.0
@export var base_attack_power: float = 20.0
@export var base_armor: float = 2.0
@export var resistance: float = 0.0

var health: float
var mana: float
var defending_timer: float = 0.0
var defense_bonus: float = 8.0
var invulnerable_timer: float = 0.0
var mana_recharge_timer: float = 0.0
const INVUL_DURATION: float = 0.2
const MANA_RECHARGE_INTERVAL: float = 5.0
const MANA_RECHARGE_AMOUNT: float = 12.0

func _ready():
	health = max_health
	mana = max_mana
	mana_recharge_timer = 0.0
	emit_signal("health_changed", health, max_health)
	emit_signal("mana_changed", mana, max_mana)

func _physics_process(delta: float) -> void:
	_combatant_physics_process(delta)

func _combatant_physics_process(delta: float) -> void:
	if invulnerable_timer > 0.0:
		invulnerable_timer = max(invulnerable_timer - delta, 0.0)

	if defending_timer > 0.0:
		defending_timer = max(defending_timer - delta, 0.0)
		if defending_timer == 0.0:
			_end_defend()

	_regenerate_mana_tick(delta)

func _end_defend() -> void:
	defending_timer = 0.0

func start_defend(duration: float) -> void:
	defending_timer = duration
	invulnerable_timer = 0.0

func is_defending() -> bool:
	return defending_timer > 0.0

func get_current_armor() -> float:
	var bonus := 0.0
	if is_defending():
		bonus = defense_bonus
	return base_armor + bonus

func _regenerate_mana_tick(delta: float) -> void:
	if mana >= max_mana:
		mana_recharge_timer = 0.0
		return

	mana_recharge_timer += delta
	if mana_recharge_timer < MANA_RECHARGE_INTERVAL:
		return

	mana_recharge_timer -= MANA_RECHARGE_INTERVAL
	var previous_mana := mana
	mana = clamp(mana + MANA_RECHARGE_AMOUNT, 0.0, max_mana)
	if mana != previous_mana:
		emit_signal("mana_changed", mana, max_mana)

func can_use_mana(cost: float) -> bool:
	return mana >= cost

func consume_mana(cost: float) -> void:
	mana = clamp(mana - cost, 0.0, max_mana)
	mana_recharge_timer = 0.0
	emit_signal("mana_changed", mana, max_mana)

func take_damage(amount: float) -> float:
	if amount <= 0.0 or invulnerable_timer > 0.0:
		return 0.0

	var raw_damage: float = max(amount - get_current_armor(), 0.0)
	var final_damage: float = raw_damage * (1.0 - resistance)

	health = clamp(health - final_damage, 0.0, max_health)
	invulnerable_timer = INVUL_DURATION
	emit_signal("health_changed", health, max_health)

	if health <= 0.0:
		die()

	return final_damage

func die() -> void:
	if is_inside_tree():
		queue_free()
	emit_signal("died")

func is_alive() -> bool:
	return health > 0.0
