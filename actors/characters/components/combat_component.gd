class_name CombatComponent
extends CharacterComponent
## Applies damage to characters when a hit is confirmed.


signal hit_processed(
	target: Node,
	health_component: HealthComponent,
	damage: DamageInfo,
	applied_amount: float
)


func apply_hit(target: Node, damage: DamageInfo) -> float:
	if not is_instance_valid(target) or not damage:
		return 0.0

	var attacker_health := _find_health_component(character)
	if attacker_health and not attacker_health.is_alive:
		return 0.0

	var target_health := _find_health_component(target)
	if not target_health:
		return 0.0

	var applied_amount := target_health.apply_damage(damage)
	hit_processed.emit(target, target_health, damage, applied_amount)

	return applied_amount


func _find_health_component(target: Node) -> HealthComponent:
	var current: Node = target

	while current:
		if current is HealthComponent:
			return current

		for child in current.get_children():
			if child is HealthComponent:
				return child

		current = current.get_parent()

	return null
