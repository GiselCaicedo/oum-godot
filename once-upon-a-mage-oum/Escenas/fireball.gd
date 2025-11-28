extends Area2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var speed := 400.0
@export var lifetime := 2.4

var velocity := Vector2.ZERO
var damage := 18.0
var instigator: Combatant

func _ready():
	body_entered.connect(_on_body_entered)
	sprite.play("Launch")
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func initialize(direction: Vector2, damage_value: float, instigator: Combatant, obj_mask: int, speed_multiplier: float = 1.0) -> void:
	var direccion_disparo = Vector2.ZERO

	direccion_disparo = (direction - global_position).normalized()
	velocity = direccion_disparo * speed * speed_multiplier
	damage = damage_value
	self.instigator = instigator
	collision_mask = 0 
	set_collision_mask_value(obj_mask, true)
	set_collision_mask_value(3, true) 
	rotation = direccion_disparo.angle()

func _physics_process(delta: float) -> void:
	if velocity != Vector2.ZERO:
		global_position += velocity * delta

func _on_body_entered(body):
	if body == instigator:
		return

	if body is TileMapLayer:
		queue_free()
		return

	if body is Combatant:
		body.take_damage(damage)
		queue_free()
