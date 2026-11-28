class_name AimComponent
extends CharacterComponent


@export_group("Aim")
@export var upper_body_aim_modifier: UpperBodyAimModifier
@export var weapon_rig: Node3D

@export_range(1.0, 1000.0, 1.0)
var max_aim_distance: float = 100.0


func _ready() -> void:
    if not upper_body_aim_modifier:
        push_warning("UpperBodyAimModifier is not assigned.")

    # if not weapon_rig:
    #     push_warning("WeaponRig is not assigned.")


func _process(_delta: float) -> void:
    _update_aim()


func _update_aim() -> void:
    if not upper_body_aim_modifier:
        return

    var camera := get_viewport().get_camera_3d()
    if not camera:
        upper_body_aim_modifier.clear_aim_target()
        return

    var mouse_position := get_viewport().get_mouse_position()
    var ray_origin := camera.project_ray_origin(mouse_position)
    var ray_direction := camera.project_ray_normal(mouse_position)
    var ray_end := ray_origin + ray_direction * max_aim_distance

    var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
    query.exclude = [character.get_rid()]

    var hit := character.get_world_3d().direct_space_state.intersect_ray(query)
    var aim_target: Vector3 = ray_end

    if not hit.is_empty():
        aim_target = hit["position"]

    upper_body_aim_modifier.set_aim_target(aim_target)
    _update_weapon_rig(aim_target)


func _update_weapon_rig(aim_target: Vector3) -> void:
    if not weapon_rig or not character.model:
        return

    var direction := character.model.to_local(aim_target)
    direction -= character.model.to_local(weapon_rig.global_position)

    if direction.length_squared() < 0.0001:
        return

    var horizontal_length := Vector2(direction.x, direction.z).length()
    var yaw := -atan2(direction.x, -direction.z)
    var pitch := atan2(direction.y, horizontal_length)

    yaw = clampf(
        yaw,
        -deg_to_rad(upper_body_aim_modifier.max_yaw_degrees),
        deg_to_rad(upper_body_aim_modifier.max_yaw_degrees)
    )
    pitch = clampf(
        pitch,
        -deg_to_rad(upper_body_aim_modifier.max_pitch_degrees),
        deg_to_rad(upper_body_aim_modifier.max_pitch_degrees)
    )

    weapon_rig.rotation = Vector3(pitch, yaw, 0.0)
