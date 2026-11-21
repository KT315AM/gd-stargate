class_name Projectile
extends RigidBody3D
## Base class for physical projectiles.


var damage_amount: float = 0.0
var damage_type: DamageInfo.Type = DamageInfo.Type.KINETIC
var source_weapon: Weapon
var instigator: Character

var _remaining_lifetime: float = 5.0
var _has_hit: bool = false


func _ready() -> void:
    body_entered.connect(_on_body_entered)

    if instigator and is_instance_valid(instigator):
        add_collision_exception_with(instigator)


func configure(
    amount: float,
    type: DamageInfo.Type,
    weapon: Weapon,
    shooter: Character,
    lifetime: float
) -> void:
    damage_amount = maxf(amount, 0.0)
    damage_type = type
    source_weapon = weapon
    instigator = shooter
    _remaining_lifetime = maxf(lifetime, 0.01)


func launch(direction: Vector3, speed: float) -> void:
    linear_velocity = direction.normalized() * maxf(speed, 0.0)


func _physics_process(delta: float) -> void:
    _remaining_lifetime -= delta
    if _remaining_lifetime <= 0.0:
        queue_free()


func _on_body_entered(body: Node) -> void:
    if _has_hit:
        return

    _has_hit = true

    var hit_normal := -linear_velocity.normalized()
    if hit_normal.is_zero_approx():
        hit_normal = Vector3.UP

    var damage := DamageInfo.create(
        damage_amount,
        damage_type,
        source_weapon,
        instigator,
        global_position,
        hit_normal
    )

    if source_weapon and is_instance_valid(source_weapon):
        source_weapon._on_hit(body, damage)

    queue_free()
