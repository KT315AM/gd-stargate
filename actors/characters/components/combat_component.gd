class_name CombatComponent
extends CharacterComponent
## Applies damage to characters when a hit is confirmed.


signal hit_processed(target: Node, damage: DamageInfo, actual_amount: float)


func _input(event: InputEvent) -> void:
    _handle_attack_action(event, "attack_main", character.main_weapon)
    _handle_attack_action(event, "attack_secondary", character.secondary_weapon)


func _handle_attack_action(event: InputEvent, action: String, weapon: Weapon) -> void:
    if event.is_action_pressed(action):
        if weapon:
            if not weapon.hit.is_connected(_on_weapon_hit):
                weapon.hit.connect(_on_weapon_hit)
            
            weapon.start_attack()
        
        get_viewport().set_input_as_handled()

    elif event.is_action_released(action):
        if weapon:
            if weapon.hit.is_connected(_on_weapon_hit):
                weapon.hit.disconnect(_on_weapon_hit)

            weapon.stop_attack()
        
        get_viewport().set_input_as_handled()


func _on_weapon_hit(target: Node, damage: DamageInfo) -> void:
    var actual_amount := _apply_damage(target, damage)
    hit_processed.emit(target, damage, actual_amount)


func _apply_damage(target: Node, damage: DamageInfo) -> float:
    if not is_instance_valid(target) or not damage:
        return 0.0

    if character.health_component and not character.health_component.is_alive:
        return 0.0

    var target_health: HealthComponent = target.health_component if GameUtils.is_damageable(target) else null
    if not target_health:
        return 0.0

    var actual_amount := target_health.take_damage(damage)
    return actual_amount
