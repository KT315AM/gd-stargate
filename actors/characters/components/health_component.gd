class_name HealthComponent
extends CharacterComponent
## Manages character health, damage reception, healing, and death.


signal health_changed(current_health: float, max_health: float)
signal damage_taken(damage: DamageInfo, actual_amount: float)
signal healed(actual_amount: float, current_health: float)
signal died(damage: DamageInfo)


@export_group("Health")
@export_range(0.0, 10000.0, 0.1)
var max_health: float = 100.0

@export var invulnerable: bool = false


var current_health: float = 0.0


var is_alive: bool:
    get: return current_health > 0.0


func _ready() -> void:
    if character:
        character.collision_layer |= Constants.TRAIT_LAYER_DAMAGEABLE
    
    max_health = maxf(max_health, 0.0)
    current_health = max_health
    health_changed.emit(current_health, max_health)


func take_damage(damage: DamageInfo) -> float:
    if not is_alive or invulnerable or not damage:
        return 0.0

    var actual_amount := minf(maxf(damage.amount, 0.0), current_health)
    if actual_amount <= 0.0:
        return 0.0

    current_health = maxf(current_health - actual_amount, 0.0)

    damage_taken.emit(damage, actual_amount)
    health_changed.emit(current_health, max_health)

    if current_health <= 0.0:
        died.emit(damage)

    return actual_amount


func heal(amount: float) -> float:
    if not is_alive or amount <= 0.0:
        return 0.0

    var actual_amount := minf(amount, max_health - current_health)
    if actual_amount <= 0.0:
        return 0.0

    current_health += actual_amount
    healed.emit(actual_amount, current_health)
    health_changed.emit(current_health, max_health)

    return actual_amount
