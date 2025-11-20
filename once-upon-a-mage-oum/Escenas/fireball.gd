extends Area2D

@onready var sprite = $AnimatedSprite2D
var velocidad = 300.0
var tiempo_espera = 1.0

var se_esta_moviendo = false
var direccion_disparo = Vector2.ZERO

func _ready():
	body_entered.connect(_on_body_entered)
	iniciar_secuencia_disparo()

func iniciar_secuencia_disparo():
	# 1. ESTADO DE CARGA
	sprite.play("Spelling") # Nombre de tu animación de carga
	rotation = direccion_disparo.angle()
	# 2. ESPERA (El truco del tiempo)
	# Esto pausa la ejecución de esta función por X segundos, pero el juego sigue corriendo
	await get_tree().create_timer(tiempo_espera).timeout
	
	# 3. CALCULAR DIRECCIÓN (Justo antes de disparar)
	# Restamos la posición del mouse menos la posición actual para obtener el vector
	var mouse_pos = get_global_mouse_position()
	direccion_disparo = (mouse_pos - global_position).normalized()
	rotation = direccion_disparo.angle()
	
	# 4. CAMBIAR A ESTADO DE MOVIMIENTO
	sprite.play("Launch") # Nombre de tu animación de viaje
	se_esta_moviendo = true

func _physics_process(delta):
	if se_esta_moviendo:
		position += direccion_disparo * velocidad * delta

func _on_body_entered(body):
	# 1. Verificamos si el objeto chocado es un TileMap (Paredes/Suelo)
	# Si quieres que las paredes destruyan la bola, descomenta las lineas de abajo:
	if body is TileMapLayer:
		queue_free()
		return 

	# 2. Si NO es un mapa, verificamos si es un objeto con capas (Enemigo)
	if body.has_method("get_collision_layer_value"):
		if body.get_collision_layer_value(5):
			queue_free()
			# Instanciar explosión aquí
