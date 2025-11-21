extends Combatant

const CHASE_SPEED := 65.0
const ATTACK_RANGE := 32.0
const ATTACK_COOLDOWN := 1.2
const ATTACK_DAMAGE := 16.0

var attack_timer := 0.0
var target: Combatant
func _enter_tree() -> void:
	target = _find_player()

func _physics_process(delta: float) -> void:
	if not target or not target.is_alive():
		target = _find_player()

	if target and target.is_alive():
		_chase_player(delta)
	else:
		velocity = Vector2.ZERO

	attack_timer = max(attack_timer - delta, 0.0)
	_combatant_physics_process(delta)

func _chase_player(delta: float) -> void:
	var direction := target.global_position - global_position
	var distance := direction.length()

	if distance > ATTACK_RANGE:
		velocity = direction.normalized() * CHASE_SPEED
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		if attack_timer == 0.0:
			_perform_attack()
			attack_timer = ATTACK_COOLDOWN

func _perform_attack() -> void:
	if target:
		target.take_damage(ATTACK_DAMAGE)

func _find_player() -> Combatant:
	for candidate in get_tree().get_nodes_in_group("Player"):
		if candidate is Combatant:
			return candidate
	return null
