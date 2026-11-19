class_name AimComponent
extends CharacterComponent


func _process(_delta: float) -> void:
    _update_aim()


func _update_aim() -> void:
    if not character.model:
        return

    var camera := get_viewport().get_camera_3d()
    if not camera:
        return

    var mouse_position := get_viewport().get_mouse_position()
    var ray_origin := camera.project_ray_origin(mouse_position)
    var ray_direction := camera.project_ray_normal(mouse_position)
    var aim_plane := Plane(Vector3.UP, character.global_position.y)
    var intersection = aim_plane.intersects_ray(ray_origin, ray_direction)

    if not intersection:
        return

    var aim_position: Vector3 = intersection
    var direction := aim_position - character.model.global_position
    direction.y = 0.0

    if direction.length_squared() < 0.0001:
        return

    character.model.look_at(aim_position, Vector3.UP)