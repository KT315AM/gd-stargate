class_name HealthComponent
extends CharacterComponent
## Manages character health, damage reception, healing, and death.


signal health_changed(current_health: float, max_health: float)
signal damage_received(damage: DamageInfo, applied_amount: float)
signal healed(applied_amount: float, current_health: float)
signal died(damage: DamageInfo)


@export_group("Health")
@export_range(0.0, 10000.0, 0.1)
var max_health: float = 100.0

@export var invulnerable: bool = false


var current_health: float = 0.0


var is_alive: bool:
	get:
		return current_health > 0.0


func _ready() -> void:
	max_health = maxf(max_health, 0.0)
	current_health = max_health
	health_changed.emit(current_health, max_health)


func apply_damage(damage: DamageInfo) -> float:
	if not is_alive or invulnerable or not damage:
		return 0.0

	var applied_amount := minf(maxf(damage.amount, 0.0), current_health)
	if applied_amount <= 0.0:
		return 0.0

	current_health = maxf(current_health - applied_amount, 0.0)

	damage_received.emit(damage, applied_amount)
	health_changed.emit(current_health, max_health)

	if current_health <= 0.0:
		died.emit(damage)

	return applied_amount


func heal(amount: float) -> float:
	if not is_alive or amount <= 0.0:
		return 0.0

	var applied_amount := minf(amount, max_health - current_health)
	if applied_amount <= 0.0:
		return 0.0

	current_health += applied_amount
	healed.emit(applied_amount, current_health)
	health_changed.emit(current_health, max_health)

	return applied_amount
