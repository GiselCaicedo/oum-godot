extends Combatant

const CHASE_SPEED := 65.0
const WANDER_SPEED := 40.0
const ATTACK_COOLDOWN := 2
const ATTACK_DAMAGE := 16.0
const FIREBALL_SCENE = preload("res://Escenas/Fireball.tscn")

var attack_timer := 0.0
var target: Combatant

var player_target: Node2D = null
var is_in_attack_zone = false
var move_direction := Vector2.ZERO
var move_timer := 0.0
const MOVE_CHANGE_TIME := 1.5

@onready var sprite = $AnimatedSprite2D
@onready var wall_detector = $ShapeCast2D

func _ready():
	_choose_new_direction()

func _physics_process(delta: float) -> void:
	attack_timer = max(attack_timer - delta, 0.0)
	move_timer = max(move_timer - delta, 0.0)
	
	var current_velocity = Vector2.ZERO
	if player_target:
		if is_in_attack_zone:
			
			if attack_timer <= 0.0:
				current_velocity = Vector2.ZERO
				sprite.play("Idle") 
				_perform_attack()
				
				attack_timer = ATTACK_COOLDOWN
				_choose_new_direction() 
				
			else:
				current_velocity = _handle_movement(CHASE_SPEED)
				sprite.play("Run")

		else:
			current_velocity = Vector2.ZERO
			sprite.play("Idle")
			
	else:
		if move_timer <= 0.0:
			_choose_new_direction()
			move_timer = MOVE_CHANGE_TIME
			
		current_velocity = _handle_movement(WANDER_SPEED)
		
		if current_velocity.length() > 0:
			sprite.play("Run")
		else:
			sprite.play("Idle")
	velocity = current_velocity
	
	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
		
	move_and_slide()
	_combatant_physics_process(delta)
	
func _choose_new_direction():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func _handle_movement(speed: float) -> Vector2:
	wall_detector.target_position = move_direction * 50.0 
	wall_detector.force_shapecast_update()
	
	if wall_detector.is_colliding():
		var normal = wall_detector.get_collision_normal(0)
		move_direction = move_direction.bounce(normal).normalized()
		
		if randf() > 0.5:
			move_direction = move_direction.rotated(PI / 4)
	
	return move_direction * speed

func _perform_attack() -> void:
	var fireball = FIREBALL_SCENE.instantiate()
	fireball.global_position = global_position
	fireball.initialize(player_target.global_position, ATTACK_DAMAGE, self, 1)
	get_parent().add_child(fireball)
	
	if target:
		target.take_damage(ATTACK_DAMAGE)


func _on_attack_zone_body_entered(body: Node2D) -> void:
	player_target = body
	is_in_attack_zone = true
	_choose_new_direction()
	print("Launch Entered")


func _on_attack_zone_body_exited(body: Node2D) -> void:
	if body == player_target:
		is_in_attack_zone = false
		player_target = null
		print("Launch Exited")
