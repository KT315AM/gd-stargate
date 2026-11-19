class_name AnimationComponent
extends CharacterComponent


@export_group("Animation")
@export var animation_tree: AnimationTree


@export_group("Locomotion")
@export_range(0.1, 20.0, 0.1)
var run_speed: float = 5.0

@export_range(0.0, 1.0, 0.01)
var movement_threshold: float = 0.05

@export_range(0.1, 30.0, 0.1)
var blend_speed: float = 10.0


const BLEND_PARAMETER: StringName = &"parameters/Locomotion/blend_position"


var _blend_position: float = 0.0


func _ready() -> void:
    if not animation_tree:
        push_warning("AnimationTree is not assigned.")
        return

    animation_tree.active = true


func _process(delta: float) -> void:
    if not animation_tree:
        return

    _update_locomotion(delta)


func _update_locomotion(delta: float) -> void:
    var real_velocity := character.get_real_velocity()
    real_velocity.y = 0.0
    var current_speed := real_velocity.length()
    var target_blend := 0.0

    if current_speed > movement_threshold:
        target_blend = clampf(current_speed / run_speed, 0.0, 1.0)

    var weight := 1.0 - exp(-blend_speed * delta)

    _blend_position = lerpf(_blend_position, target_blend, weight)
    animation_tree.set(BLEND_PARAMETER, _blend_position)