class_name AimComponent
extends CharacterComponent


@export_group("Aim")
@export var upper_body_aim_modifier: UpperBodyAimModifier


func _ready() -> void:
    if not upper_body_aim_modifier:
        push_warning("UpperBodyAimModifier is not assigned.")


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
    var aim_plane := Plane(Vector3.UP, character.global_position.y)
    var intersection = aim_plane.intersects_ray(ray_origin, ray_direction)

    if not intersection:
        upper_body_aim_modifier.clear_aim_target()
        return

    upper_body_aim_modifier.set_aim_target(intersection)
