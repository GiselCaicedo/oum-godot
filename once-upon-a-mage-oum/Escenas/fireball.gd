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

func initialize(direction: Vector2, damage_value: float, instigator: Combatant, speed_multiplier: float = 1.0) -> void:
	var normalized = direction.normalized()
	if normalized == Vector2.ZERO:
		normalized = Vector2.RIGHT

	velocity = normalized * speed * speed_multiplier
	damage = damage_value
	self.instigator = instigator
	rotation = normalized.angle()

func _physics_process(delta: float) -> void:
	if velocity != Vector2.ZERO:
		global_position += velocity * delta

func _on_body_entered(body):
	if body == instigator:
		return

	if body is TileMap:
		queue_free()
		return

	if body is Combatant:
		body.take_damage(damage)
		queue_free()
