extends Combatant

const FIREBALL_SCENE = preload("res://Escenas/Fireball.tscn")
const GRAFOMANCIA_RUNE = preload("res://Escenas/GrafomanciaRune.tscn")
const SPEED = 100.0
const LOGOI_MANA_COST = 12.0
const GRAFOMANCIA_MANA_COST = 28.0
const TEURGIA_HEALTH_COST = 18.0
const TEURGIA_DAMAGE_MULT = 1.9
const COMBO_RESET_TIME = 1.4
const COMBO_BONUS = 4.0
const MAX_COMBO = 5
const DEFEND_DURATION = 0.75
const DEFEND_COOLDOWN = 1.6

@onready var playerSprite: AnimatedSprite2D = $AnimatedSprite2D

var last_direction := Vector2.RIGHT
var combo_counter := 0
var combo_timer := 0.0
var defend_cooldown_timer := 0.0
var _mouse_left_prev := false

func _ready():
	set_physics_process(true)
	health = max_health
	mana = max_mana
	if not is_in_group("Player"):
		add_to_group("Player")

func _physics_process(delta: float) -> void:
	_handle_movement()
	_handle_combo(delta)
	_handle_defense(delta)
	var mouse_left_pressed := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	var mouse_left_just_pressed := mouse_left_pressed and not _mouse_left_prev
	logoi_tecnia(mouse_left_just_pressed)
	_mouse_left_prev = mouse_left_pressed
	grafomancia()
	teurgia()
	_combatant_physics_process(delta)
	_update_animation()

func _handle_movement() -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 10.0)

	move_and_slide()

func _handle_combo(delta: float) -> void:
	if combo_counter == 0:
		return

	combo_timer -= delta
	if combo_timer <= 0.0:
		combo_counter = 0
		combo_timer = 0.0

func _handle_defense(delta: float) -> void:
	if defend_cooldown_timer > 0.0:
		defend_cooldown_timer = max(defend_cooldown_timer - delta, 0.0)

	if Input.is_action_just_pressed("Dash") and defend_cooldown_timer == 0.0:
		start_defend(DEFEND_DURATION)
		defend_cooldown_timer = DEFEND_COOLDOWN

func _compute_aim_direction() -> Vector2:
	var direction := get_global_mouse_position() - global_position
	if direction.length() == 0.0:
		return last_direction
	return direction.normalized()

func logoi_tecnia(mouse_click: bool) -> void:
	if not Input.is_action_just_pressed("Logoitecnia_Attack") and not mouse_click:
		return

	if not can_use_mana(LOGOI_MANA_COST):
		return

	var aim_direction := _compute_aim_direction()
	last_direction = aim_direction

	var fireball = FIREBALL_SCENE.instantiate()
	fireball.global_position = global_position
	var damage = base_attack_power + combo_counter * COMBO_BONUS
	fireball.initialize(aim_direction, damage, self)
	get_parent().add_child(fireball)
	consume_mana(LOGOI_MANA_COST)
	_register_combo()

func grafomancia() -> void:
	if not Input.is_action_just_pressed("Grafomancia_Attack"):
		return

	if not can_use_mana(GRAFOMANCIA_MANA_COST):
		return

	var rune = GRAFOMANCIA_RUNE.instantiate()
	rune.global_position = global_position + last_direction * 32.0
	rune.configure(base_attack_power * 1.4 + combo_counter * 2.0, self)
	get_parent().add_child(rune)
	consume_mana(GRAFOMANCIA_MANA_COST)
	_register_combo()

func teurgia() -> void:
	if not Input.is_action_just_pressed("Teúrgia_Attack"):
		return

	if health <= TEURGIA_HEALTH_COST + 2.0:
		return

	var fireball = FIREBALL_SCENE.instantiate()
	fireball.global_position = global_position
	var bonus_damage = base_attack_power * TEURGIA_DAMAGE_MULT
	fireball.initialize(last_direction, bonus_damage, self, 1.3)
	get_parent().add_child(fireball)
	health = clamp(health - TEURGIA_HEALTH_COST, 0.0, max_health)
	emit_signal("health_changed", health, max_health)
	if health <= 0.0:
		die()
	combo_counter = 0
	combo_timer = 0.0

func _register_combo() -> void:
	combo_counter = min(combo_counter + 1, MAX_COMBO)
	combo_timer = COMBO_RESET_TIME

func _update_animation() -> void:
	if velocity.length() > 0.0:
		playerSprite.play("Run")
	else:
		playerSprite.play("Idle")

	if velocity.x != 0.0:
		playerSprite.flip_h = velocity.x < 0
