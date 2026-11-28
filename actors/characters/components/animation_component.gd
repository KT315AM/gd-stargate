class_name AnimationComponent
extends CharacterComponent
## Updates character locomotion animation from local movement velocity.

@export_group("Animation")
@export var animation_tree: AnimationTree

@export_group("Locomotion")
@export_range(0.1, 20.0, 0.1)
var run_speed: float = 5.0

@export_range(0.0, 20.0, 0.1)
var backward_speed: float = 2.0

@export_range(0.0, 1.0, 0.01)
var movement_threshold: float = 0.05

@export_range(0.1, 30.0, 0.1)
var blend_speed: float = 10.0


const BLEND_PARAMETER: StringName = &"parameters/Locomotion/blend_position"


var _blend_position: Vector2 = Vector2.ZERO


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

    var model_basis := character.global_basis.orthonormalized()
    if character.model:
        model_basis = character.model.global_basis.orthonormalized()

    var local_velocity := model_basis.inverse() * real_velocity
    var target_blend := Vector2(local_velocity.x, -local_velocity.z)

    if target_blend.length() <= movement_threshold:
        target_blend = Vector2.ZERO
    else:
        target_blend.x = clampf(target_blend.x, -run_speed, run_speed)
        target_blend.y = clampf(target_blend.y, -backward_speed, run_speed)

    var weight := 1.0 - exp(-blend_speed * delta)
    _blend_position = _blend_position.lerp(target_blend, weight)
    animation_tree.set(BLEND_PARAMETER, _blend_position)
