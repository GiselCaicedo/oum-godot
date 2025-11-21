extends CharacterBody2D

@onready var playerSprite: AnimatedSprite2D = $AnimatedSprite2D
const FIREBALL_SCENE = preload("res://Escenas/Fireball.tscn")
const SPEED = 100.0

# Variable para recordar la última dirección en la que miró el personaje
# (Para disparar incluso si está quieto)
var last_direction = Vector2.RIGHT 

func _physics_process(_delta) -> void:
	# 1. MOVIMIENTO
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction:
		velocity = direction * SPEED
		last_direction = direction # Actualizamos la última dirección conocida
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 10)

	move_and_slide()
	
	# 2. ANIMACIONES
	if velocity.length() > 0:
		playerSprite.play("Run")
	else:
		playerSprite.play("Idle")
		
	if velocity.x != 0:
		var is_left = velocity.x < 0
		playerSprite.flip_h = is_left

	# 3. ATAQUE (Aquí llamamos a la función)
	logoi_tecnia()

func logoi_tecnia():
	if Input.is_action_just_pressed("Logoitecnia_Attack"):
		var inst = FIREBALL_SCENE.instantiate()
		inst.global_position = global_position
		get_parent().add_child(inst)
		inst.setup(get_global_mouse_position(), 5)
