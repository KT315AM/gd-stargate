class_name MovementComponent
extends CharacterComponent


@export_group("Movement")
@export_range(0.0, 20.0, 0.1)
var max_speed: float = 5.0

@export_range(0.0, 100.0, 0.1)
var acceleration: float = 20.0

@export_range(0.0, 100.0, 0.1)
var deceleration: float = 24.0


@export_group("Facing")
@export_range(0.1, 20.0, 0.1)
var turn_speed: float = 12.0


@export_group("Physics")
@export var gravity: float = 9.8


func _physics_process(delta: float) -> void:
    _update_movement(delta)
    _update_gravity(delta)
    character.move_and_slide()
    
    _update_facing(delta)


func _update_movement(delta: float) -> void:
    var input_direction := Input.get_vector(
        "move_left",
        "move_right",
        "move_forward",
        "move_back"
    )

    var move_direction := _get_camera_relative_direction(input_direction)
    var target_velocity := move_direction * max_speed
    var current_velocity := Vector3(character.velocity.x, 0.0, character.velocity.z)
    var rate := acceleration if input_direction.length_squared() > 0.0 else deceleration
    current_velocity = current_velocity.move_toward(target_velocity, rate * delta)
    character.velocity.x = current_velocity.x
    character.velocity.z = current_velocity.z


func _get_camera_relative_direction(input_direction: Vector2) -> Vector3:
    if input_direction == Vector2.ZERO:
        return Vector3.ZERO

    var camera := character.get_viewport().get_camera_3d()
    if not camera:
        return Vector3(input_direction.x, 0.0, input_direction.y).normalized()

    var camera_right := camera.global_basis.x
    var camera_backward := camera.global_basis.z
    camera_right.y = 0.0
    camera_backward.y = 0.0
    camera_right = camera_right.normalized()
    camera_backward = camera_backward.normalized()

    var direction := (
        camera_right * input_direction.x
        + camera_backward * input_direction.y
    )

    return direction.normalized()


func _update_gravity(delta: float) -> void:
    if character.is_on_floor():
        if character.velocity.y < 0.0:
            character.velocity.y = -0.1
    else:
        character.velocity.y -= gravity * delta


func _update_facing(delta: float) -> void:
    if not character.model:
        return

    var direction := character.get_real_velocity()
    direction.y = 0.0

    if direction.length_squared() < 0.0025:
        return

    var target_yaw := atan2(-direction.x, -direction.z)

    character.model.global_rotation.y = rotate_toward(
        character.model.global_rotation.y,
        target_yaw,
        turn_speed * delta
    )
