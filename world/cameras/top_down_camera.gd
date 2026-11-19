class_name TopDownCamera
extends Node3D


@export_group("Target")
@export var target: Node3D


@export_group("Follow")
@export_range(0.1, 30.0, 0.1)
var follow_speed: float = 8.0

@export var follow_offset: Vector3 = Vector3.ZERO


func _process(delta: float) -> void:
    if not target:
        return

    _update_follow(delta)


func _update_follow(delta: float) -> void:
    var target_position := target.global_position + follow_offset
    var weight := 1.0 - exp(-follow_speed * delta)
    global_position = global_position.lerp(target_position, weight)