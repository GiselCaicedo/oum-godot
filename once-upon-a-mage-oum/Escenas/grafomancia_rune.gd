extends Area2D
class_name GrafomanciaRune

@export var charge_time := 0.8
@export var linger_time := 1.0
@export var damage := 22.0

var instigator: Combatant

func _ready():
	monitoring = true
	await _charge_and_release()

func configure(damage: float, instigator: Combatant = null, charge_time: float = 0.8) -> void:
	self.damage = damage
	self.instigator = instigator
	self.charge_time = charge_time

func _charge_and_release() -> void:
	await get_tree().create_timer(charge_time).timeout
	_release_burst()
	await get_tree().create_timer(linger_time).timeout
	queue_free()

func _release_burst() -> void:
	for body in get_overlapping_bodies():
		if body == instigator:
			continue

		if body is Combatant:
			body.take_damage(damage)
