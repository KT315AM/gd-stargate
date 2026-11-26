class_name NpcMovementComponent
extends CharacterComponent
## Handles physics-based movement for non-player characters.

@export_group("Movement")
@export_range(0.0, 20.0, 0.1)
var max_speed: float = 3.5

@export_range(0.0, 100.0, 0.1)
var acceleration: float = 16.0

@export_range(0.0, 100.0, 0.1)
var deceleration: float = 20.0

@export_group("Facing")
@export_range(0.1, 20.0, 0.1)
var turn_speed: float = 8.0

@export_group("Physics")
@export var gravity: float = 9.8


var _move_direction: Vector3 = Vector3.ZERO
var _facing_direction: Vector3 = Vector3.ZERO
var _has_facing_direction: bool = false


func set_move_direction(direction: Vector3) -> void:
    direction.y = 0.0
    _move_direction = direction.normalized()


func set_facing_direction(direction: Vector3) -> void:
    direction.y = 0.0
    _facing_direction = direction.normalized()
    _has_facing_direction = _facing_direction.length_squared() > 0.0


func clear_facing_direction() -> void:
    _facing_direction = Vector3.ZERO
    _has_facing_direction = false


func _physics_process(delta: float) -> void:
    _update_movement(delta)
    _update_gravity(delta)
    character.move_and_slide()
    _update_facing(delta)


func _update_movement(delta: float) -> void:
    var target_velocity := _move_direction * max_speed
    var current_velocity := Vector3(character.velocity.x, 0.0, character.velocity.z)
    var rate := acceleration if _move_direction.length_squared() > 0.0 else deceleration
    current_velocity = current_velocity.move_toward(target_velocity, rate * delta)
    character.velocity.x = current_velocity.x
    character.velocity.z = current_velocity.z


func _update_gravity(delta: float) -> void:
    if character.is_on_floor():
        if character.velocity.y < 0.0:
            character.velocity.y = -0.1
    else:
        character.velocity.y -= gravity * delta


func _update_facing(delta: float) -> void:
    if not character.model:
        return

    var direction := _facing_direction if _has_facing_direction else character.get_real_velocity()
    direction.y = 0.0

    if direction.length_squared() < 0.0025:
        return

    var target_yaw := atan2(-direction.x, -direction.z)
    character.model.global_rotation.y = rotate_toward(
        character.model.global_rotation.y,
        target_yaw,
        turn_speed * delta
    )
