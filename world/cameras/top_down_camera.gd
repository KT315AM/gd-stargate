class_name TopDownCamera
extends Node3D


@export_group("Target")
@export var target: Node3D


@export_group("Follow")
@export_range(0.1, 30.0, 0.1)
var follow_speed: float = 8.0

@export var follow_offset: Vector3 = Vector3.ZERO


@export_group("Zoom")
@export_range(1.0, 50.0, 0.5)
var min_distance: float = 8.0

@export_range(1.0, 100.0, 0.5)
var max_distance: float = 24.0

@export_range(1.01, 2.0, 0.01)
var zoom_step: float = 1.15


@export_group("Rotation")
@export_range(0.001, 0.05, 0.001)
var rotation_sensitivity: float = 0.005

@export_range(1.0, 30.0, 0.5)
var orbit_smoothing: float = 12.0

@export_range(5.0, 80.0, 1.0)
var min_pitch_degrees: float = 25.0

@export_range(10.0, 89.0, 1.0)
var max_pitch_degrees: float = 80.0


@onready var camera: Camera3D = $Camera3D

var _is_rotating: bool = false

var _current_distance: float
var _target_distance: float

var _current_pitch: float
var _target_pitch: float

var _target_yaw: float


func _ready() -> void:
    _current_distance = camera.position.length()
    _target_distance = _current_distance

    _current_pitch = atan2(camera.position.y, camera.position.z)
    _target_pitch = _current_pitch

    _target_yaw = rotation.y


func _input(event: InputEvent) -> void:
    if event.is_action_pressed("camera_zoom_in"):
        var factor: float = event.factor if event is InputEventMouseButton else 1.0
        _zoom(-1.0, factor)

    elif event.is_action_pressed("camera_zoom_out"):
        var factor: float = event.factor if event is InputEventMouseButton else 1.0
        _zoom(1.0, factor)

    elif event.is_action_pressed("camera_rotation"):
        _is_rotating = true

    elif event.is_action_released("camera_rotation"):
        _is_rotating = false

    elif _is_rotating and event is InputEventMouseMotion:
        _target_yaw -= event.relative.x * rotation_sensitivity
        _target_pitch += event.relative.y * rotation_sensitivity
        _target_pitch = clampf(
            _target_pitch,
            deg_to_rad(min_pitch_degrees),
            deg_to_rad(max_pitch_degrees)
        )


func _process(delta: float) -> void:
    if target:
        _update_follow(delta)

    _update_orbit(delta)


func _update_follow(delta: float) -> void:
    var target_position := target.global_position + follow_offset
    var weight := 1.0 - exp(-follow_speed * delta)
    global_position = global_position.lerp(target_position, weight)


func _zoom(direction: float, factor: float) -> void:
    var zoom_amount := pow(zoom_step, maxf(factor, 0.1))
    _target_distance *= zoom_amount if direction > 0.0 else 1.0 / zoom_amount
    _target_distance = clampf(_target_distance, min_distance, max_distance)


func _update_orbit(delta: float) -> void:
    var weight := 1.0 - exp(-orbit_smoothing * delta)

    rotation.y = lerp_angle(rotation.y, _target_yaw, weight)
    _current_pitch = lerpf(_current_pitch, _target_pitch, weight)
    _current_distance = lerpf(_current_distance, _target_distance, weight)

    camera.position = Vector3(
        0.0,
        sin(_current_pitch) * _current_distance,
        cos(_current_pitch) * _current_distance
    )
    camera.rotation.x = -_current_pitch
