extends CharacterBody2D

@onready var playerSprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 100.0

func _physics_process(_delta) -> void:
		# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 10)

	move_and_slide()
	
	if velocity.length() > 0:
		playerSprite.play("Run")
	else:
		playerSprite.play("Idle")
		
	if velocity.x != 0:
		# Si velocity.x es menor que 0, is_left es verdadero
		var is_left = velocity.x < 0
		playerSprite.flip_h = is_left
