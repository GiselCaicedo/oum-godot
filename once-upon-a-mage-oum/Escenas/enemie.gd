extends CharacterBody2D

const SPEED_RUN = 500.0 # Velocidad para huir
const FIREBALL_SCENE = preload("res://Escenas/Fireball.tscn") # Tu escena de bola de fuego

# Variables de estado
var player_target: Node2D = null
var is_in_escape_zone = false
var is_in_launch_zone = false
var can_shoot = true

@onready var sprite = $AnimatedSprite2D
@onready var shoot_timer = $ShootTimer
@onready var wall_detector = $ShapeCast2D

func _ready():
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

func _physics_process(_delta):
	var current_velocity = Vector2.ZERO
	
	if player_target:
		# PRIORIDAD 1: HUIR (Zona de Escape)
		if is_in_escape_zone:
			# 1. Calculamos dirección de huida normal
			var flee_direction = (global_position - player_target.global_position).normalized()
			
			# 2. Proyectamos nuestro "cuerpo fantasma" hacia esa dirección
			# Le damos una distancia (ej. 50 px) para ver el futuro
			wall_detector.target_position = flee_direction * 100.0
			wall_detector.force_shapecast_update() # Actualización instantánea
			
			# 3. Verificamos colisión de volumen
			if wall_detector.is_colliding():
				var wall_normal = wall_detector.get_collision_normal(0)
				flee_direction = flee_direction.slide(wall_normal).normalized()
			current_velocity = flee_direction * SPEED_RUN

		# PRIORIDAD 2: DISPARAR (Zona de Lanzamiento pero NO Escape)
		elif is_in_launch_zone:
			current_velocity = Vector2.ZERO 
			sprite.play("Idle")
			
			if can_shoot:
				shoot_fireball()
		
		else:
			# El jugador existe pero salió de las zonas (ej. se fue muy lejos)
			current_velocity = Vector2.ZERO
			sprite.play("Idle")

	else:
		# No hay jugador detectado
		current_velocity = Vector2.ZERO
		sprite.play("Idle")
	
	velocity = current_velocity
	move_and_slide()

func shoot_fireball():
	can_shoot = false
	shoot_timer.start() # Inicia el enfriamiento (Cooldown)
	
	var inst = FIREBALL_SCENE.instantiate()
	inst.global_position = global_position
	get_parent().add_child(inst)
	print()
	
	if player_target:
		inst.setup(player_target.global_position, 1)

func _on_shoot_timer_timeout():
	can_shoot = true

# --- SEÑALES DE LAS ÁREAS ---

# Señales para AreaEscape (La pequeña)
func _on_escape_body_exited(_body: Node2D) -> void:
	is_in_escape_zone = false
	print("Espaced Exited")

func _on_escape_body_entered(body: Node2D) -> void:
	player_target = body
	is_in_escape_zone = true
	print("Espaced Entered")

# Señales para AreaLaunch (La grande)
func _on_launch_body_entered(body: Node2D) -> void:
	player_target = body
	is_in_launch_zone = true
	print("Launch Entered")

func _on_launch_body_exited(body: Node2D) -> void:
	if body == player_target:
		is_in_launch_zone = false
		player_target = null
		print("Launch Exited")
