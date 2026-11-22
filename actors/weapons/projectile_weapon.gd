class_name ProjectileWeapon
extends Weapon
## Base class for projectile weapons.


@export_group("Projectile Settings")

@export var projectile_scene: PackedScene
@export var projectile_speed: float = 80.0
@export var projectile_lifetime: float = 5.0


func _on_attack() -> void:
    super()

    if not projectile_scene or not caster:
        return

    var direction := -caster.global_transform.basis.z
    direction = MathUtils.apply_spread_deg(direction, spread, caster.global_transform.basis)
    direction = direction.normalized()

    var projectile := projectile_scene.instantiate() as Projectile
    if not projectile:
        push_warning("[%s] Projectile scene root must inherit Projectile." % name)
        return

    var spawn_position := muzzle.global_position if muzzle else caster.global_position
    var up := Vector3.UP
    if absf(direction.dot(up)) > 0.98:
        up = Vector3.RIGHT

    projectile.global_transform = Transform3D(Basis.looking_at(direction, up), spawn_position)
    projectile.configure(damage, damage_type, self, character, projectile_lifetime)
    projectile.launch(direction, projectile_speed)

    get_tree().current_scene.add_child(projectile)
