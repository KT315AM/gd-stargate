extends Character


func _ready() -> void:
    health_component.damage_taken.connect(_on_damage_taken)
    health_component.died.connect(_on_died)


func _on_damage_taken(damage: DamageInfo, actual_amount: float):
    print("[%s] Damage taken: %.2f / %.2f (%s), %.2f" % [name, damage.amount, actual_amount, damage.type, health_component.current_health])


func _on_died(damage: DamageInfo):
    print("[%s] Died: %.2f (%s), %.2f" % [name, damage.amount, damage.type, health_component.current_health])
    
    model.scale = Vector3(2, 0.5, 2)
    var pop_tween = create_tween()
    pop_tween.tween_property(model, "scale", Vector3.ONE, 1.0).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
    pop_tween.tween_callback(queue_free)
