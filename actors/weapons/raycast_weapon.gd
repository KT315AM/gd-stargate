class_name RaycastWeapon
extends Weapon
## Base class for raycast weapons


## Object used as origin of raycast
@export var caster: Node3D


var _exclude_rids: Array[RID]


func _ready() -> void:
    super()
    _exclude_rids = get_exclude_rids()

    if not caster:
        caster = muzzle if muzzle else camera


func _on_attack() -> void:
    super()

    if not caster:
        return

    var origin := caster.global_position
    var direction : = -caster.global_transform.basis.z
    direction = MathUtils.apply_spread_deg(direction, spread, caster.global_transform.basis)
    var end := origin + direction * max_distance
    var query := PhysicsRayQueryParameters3D.create(origin, end)

    # Ignore the player and weapon.
    query.exclude = _exclude_rids
    query.collision_mask = Constants.PHYSICS_LAYER_WORLD | Constants.TRAIT_LAYER_DAMAGEABLE

    var space := get_world_3d().direct_space_state
    var result := space.intersect_ray(query)
    if result.is_empty():
        return

    _on_hit(result.collider, DamageInfo.create(damage, damage_type, self, character, result.position, result.normal))
    DebugDraw.draw_line(origin, end)


func get_exclude_rids() -> Array[RID]:
    if character:
        return [character.get_rid()]

    var result: Array[RID] = []
    var parent := get_parent()
    while parent:
        if parent is CollisionObject3D:
            result.append(parent.get_rid())
            break

        parent = parent.get_parent()

    return result