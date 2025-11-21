extends Area2D

@onready var sprite = $AnimatedSprite2D

# Configuración por defecto
var velocidad = 300.0
var tiempo_espera = 1.0

var se_esta_moviendo = false
var direccion_disparo = Vector2.ZERO
var objetivo_final = Vector2.ZERO

func _ready():
	body_entered.connect(_on_body_entered)
	# No iniciamos nada automáticamente. Esperamos a "setup()".

# --- ESTA ES LA FUNCIÓN MÁGICA ---
func setup(posicion_objetivo: Vector2, capa_a_golpear: int):
	# 1. Guardamos el destino
	objetivo_final = posicion_objetivo
	
	# 2. Configuramos a quién golpea (La Máscara)
	# Primero limpiamos las máscaras anteriores para evitar errores
	collision_mask = 0 
	
	# Activamos la capa de colisión del OBJETIVO (Ej: 3 para Enemigos, 1 para Player)
	set_collision_mask_value(capa_a_golpear, true)
	
	# Activamos SIEMPRE la colisión con el mundo (Digamos que paredes es capa 2 o TileMap)
	# Ajusta este número según donde tengas tus paredes
	set_collision_mask_value(2, true) 
	
	# 3. Iniciamos la lógica
	iniciar_secuencia()

func iniciar_secuencia():
	sprite.play("Spelling") # Animación de carga
	
	# Esperar tiempo de carga
	await get_tree().create_timer(tiempo_espera).timeout
	
	# Calcular dirección final hacia el objetivo guardado
	direccion_disparo = (objetivo_final - global_position).normalized()
	rotation = direccion_disparo.angle()
	
	sprite.play("Launch") # Animación de viaje
	se_esta_moviendo = true

func _physics_process(delta):
	if se_esta_moviendo:
		position += direccion_disparo * velocidad * delta

func _on_body_entered(body):
	# Si es Pared (TileMapLayer o lo que uses para el mundo)
	if body is TileMapLayer: 
		queue_free()
		return

	# Si chocó con algo que tiene la máscara correcta (Ya la filtramos en setup)
	# Simplemente destruimos y (opcional) aplicamos daño
	queue_free()
	
	# OPCIONAL: Sistema de daño genérico
	#if body.has_method("take_damage"):
	#	body.take_damage(10)
