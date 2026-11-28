class_name StrafeMovementComponent
extends CharacterComponent
## Handles screen-space movement while facing the mouse cursor.

@export_group("Movement")
@export_range(0.0, 20.0, 0.1)
var max_speed: float = 5.0

@export_range(0.0, 20.0, 0.1)
var backward_speed: float = 2.0

@export_range(0.0, 100.0, 0.1)
var acceleration: float = 20.0

@export_range(0.0, 100.0, 0.1)
var deceleration: float = 24.0

@export_group("Facing")
@export_range(0.1, 20.0, 0.1)
var turn_speed: float = 12.0

@export_group("Aim")
@export_range(1.0, 1000.0, 1.0)
var max_aim_distance: float = 100.0

@export_group("Physics")
@export var gravity: float = 9.8


func _physics_process(delta: float) -> void:
    _update_facing(delta)
    _update_movement(delta)
    _update_gravity(delta)
    character.move_and_slide()


func _update_movement(delta: float) -> void:
    var input_direction := Input.get_vector(
        "move_left",
        "move_right",
        "move_forward",
        "move_back"
    )

    var move_direction := _get_screen_space_direction(input_direction)
    var movement_basis := character.global_basis.orthonormalized()
    if character.model:
        movement_basis = character.model.global_basis.orthonormalized()

    var local_direction := movement_basis.inverse() * move_direction
    local_direction.y = 0.0

    var local_target_velocity := Vector3(
        local_direction.x * max_speed,
        0.0,
        local_direction.z * (backward_speed if local_direction.z > 0.0 else max_speed)
    )
    var target_velocity := movement_basis * local_target_velocity
    var current_velocity := Vector3(character.velocity.x, 0.0, character.velocity.z)
    var rate := acceleration if input_direction.length_squared() > 0.0 else deceleration
    current_velocity = current_velocity.move_toward(target_velocity, rate * delta)
    character.velocity.x = current_velocity.x
    character.velocity.z = current_velocity.z


func _get_screen_space_direction(input_direction: Vector2) -> Vector3:
    if input_direction == Vector2.ZERO:
        return Vector3.ZERO

    var camera := character.get_viewport().get_camera_3d()
    if not camera:
        return Vector3(input_direction.x, 0.0, -input_direction.y).normalized()

    var screen_right := camera.global_basis.x
    var screen_up := camera.global_basis.y

    screen_right.y = 0.0
    screen_up.y = 0.0

    if screen_right.length_squared() < 0.0001:
        screen_right = Vector3.RIGHT
    else:
        screen_right = screen_right.normalized()

    if screen_up.length_squared() < 0.0001:
        screen_up = -camera.global_basis.z
        screen_up.y = 0.0

    if screen_up.length_squared() < 0.0001:
        screen_up = Vector3.FORWARD
    else:
        screen_up = screen_up.normalized()

    var direction := screen_right * input_direction.x - screen_up * input_direction.y
    return direction.normalized()


func _update_facing(delta: float) -> void:
    if not character.model:
        return

    var aim_position := _get_mouse_aim_position()
    var direction := aim_position - character.model.global_position
    direction.y = 0.0

    if direction.length_squared() < 0.0001:
        return

    var target_yaw := atan2(-direction.x, -direction.z)
    character.model.global_rotation.y = rotate_toward(
        character.model.global_rotation.y,
        target_yaw,
        turn_speed * delta
    )


func _get_mouse_aim_position() -> Vector3:
    var camera := character.get_viewport().get_camera_3d()
    if not camera:
        return character.model.global_position - character.model.global_basis.z * max_aim_distance

    var mouse_position := character.get_viewport().get_mouse_position()
    var ray_origin := camera.project_ray_origin(mouse_position)
    var ray_direction := camera.project_ray_normal(mouse_position)
    var ray_end := ray_origin + ray_direction * max_aim_distance

    var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
    query.exclude = [character.get_rid()]

    var hit := character.get_world_3d().direct_space_state.intersect_ray(query)
    if not hit.is_empty():
        return hit["position"]

    if absf(ray_direction.y) > 0.0001:
        var distance := (character.global_position.y - ray_origin.y) / ray_direction.y
        if distance > 0.0 and distance <= max_aim_distance:
            return ray_origin + ray_direction * distance

    ray_end.y = character.global_position.y
    return ray_end


func _update_gravity(delta: float) -> void:
    if character.is_on_floor():
        if character.velocity.y < 0.0:
            character.velocity.y = -0.1
    else:
        character.velocity.y -= gravity * delta
