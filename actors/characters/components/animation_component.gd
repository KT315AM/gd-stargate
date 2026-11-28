class_name AnimationComponent
extends CharacterComponent
## Updates locomotion animation and selects a locomotion set from equipped weapons.

@export_group("Animation")
@export var animation_tree: AnimationTree
@export var animation_player: AnimationPlayer

@export_group("Locomotion")
@export_range(0.1, 20.0, 0.1)
var run_speed: float = 5.0

@export_range(0.0, 20.0, 0.1)
var backward_speed: float = 2.0

@export_range(0.0, 1.0, 0.01)
var movement_threshold: float = 0.05

@export_range(0.1, 30.0, 0.1)
var blend_speed: float = 10.0


const UNARMED_STATE: StringName = &"Unarmed"
const BLEND_PARAMETER_SUFFIX: String = "/blend_position"

var _blend_position: Vector2 = Vector2.ZERO
var _state_machine: AnimationNodeStateMachine
var _state_machine_playback: AnimationNodeStateMachinePlayback
var _unarmed_tree_root: AnimationNode
var _active_profile: LocomotionAnimationProfile
var _active_state: StringName = UNARMED_STATE


func _ready() -> void:
    if not animation_tree:
        push_warning("AnimationTree is not assigned.")
        return

    if not animation_player:
        animation_player = animation_tree.get_node_or_null(animation_tree.anim_player) as AnimationPlayer

    if not animation_player:
        push_warning("AnimationPlayer is not assigned.")
        return

    _unarmed_tree_root = animation_tree.tree_root
    _create_state_machine()

    animation_tree.active = true

    if character.equipment_component:
        character.equipment_component.equipment_changed.connect(_on_equipment_changed)
        _refresh_locomotion_profile()


func _process(delta: float) -> void:
    if not animation_tree or not _state_machine_playback:
        return

    _update_locomotion(delta)


func _create_state_machine() -> void:
    _state_machine = AnimationNodeStateMachine.new()
    _state_machine.add_node(UNARMED_STATE, _unarmed_tree_root, Vector2(0, 0))
    _state_machine.set_start_node(UNARMED_STATE)

    animation_tree.tree_root = _state_machine
    _state_machine_playback = animation_tree.get("parameters/playback")


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
    animation_tree.set("parameters/%s%s" % [_active_state, BLEND_PARAMETER_SUFFIX], _blend_position)


func _on_equipment_changed(_slot: Equipment.Slot, _equipment: Equipment) -> void:
    _refresh_locomotion_profile()


func _refresh_locomotion_profile() -> void:
    var weapon: Weapon
    if character.equipment_component:
        weapon = character.equipment_component.get_equipped(Equipment.Slot.LEFT_HAND) as Weapon
        if not weapon:
            weapon = character.equipment_component.get_equipped(Equipment.Slot.RIGHT_HAND) as Weapon

    var profile: LocomotionAnimationProfile
    if weapon:
        profile = weapon.locomotion_profile

    if profile == _active_profile:
        return

    _active_profile = profile

    if not profile:
        _switch_state(UNARMED_STATE)
        return

    if not _add_profile_state(profile):
        _active_profile = null
        _switch_state(UNARMED_STATE)
        return

    _switch_state(profile.state_name)


func _add_profile_state(profile: LocomotionAnimationProfile) -> bool:
    if not profile.animation_library:
        push_warning("Locomotion animation library is not assigned for profile '%s'." % profile.state_name)
        return false

    if not animation_player.has_animation_library(profile.library_name):
        animation_player.add_animation_library(profile.library_name, profile.animation_library)
    elif animation_player.get_animation_library(profile.library_name) != profile.animation_library:
        push_warning("Animation library name '%s' is already used." % profile.library_name)
        return false

    var blend_space := AnimationNodeBlendSpace2D.new()
    blend_space.auto_triangles = true
    blend_space.min_space = Vector2(-run_speed, -backward_speed)
    blend_space.max_space = Vector2(run_speed, run_speed)

    _add_blend_point(blend_space, profile.idle_animation, Vector2.ZERO, profile)
    _add_blend_point(blend_space, profile.walk_forward_animation, Vector2(0.0, 2.5), profile)
    _add_blend_point(blend_space, profile.run_forward_animation, Vector2(0.0, run_speed), profile)
    _add_blend_point(blend_space, profile.walk_backward_animation, Vector2(0.0, -backward_speed), profile)
    _add_blend_point(blend_space, profile.strafe_left_animation, Vector2(-run_speed, 0.0), profile)
    _add_blend_point(blend_space, profile.strafe_right_animation, Vector2(run_speed, 0.0), profile)

    var state_name := profile.state_name
    if not _state_machine.has_node(state_name):
        _state_machine.add_node(state_name, blend_space, Vector2(300, 0))
        _add_transition(UNARMED_STATE, state_name)
        _add_transition(state_name, UNARMED_STATE)

    return true


func _add_blend_point(
    blend_space: AnimationNodeBlendSpace2D,
    clip_name: StringName,
    position: Vector2,
    profile: LocomotionAnimationProfile
) -> void:
    var animation_node := AnimationNodeAnimation.new()
    animation_node.animation = StringName("%s/%s" % [profile.library_name, clip_name])
    blend_space.add_blend_point(animation_node, position)


func _add_transition(from_state: StringName, to_state: StringName) -> void:
    var transition := AnimationNodeStateMachineTransition.new()
    transition.switch_mode = AnimationNodeStateMachineTransition.SWITCH_MODE_IMMEDIATE
    _state_machine.add_transition(from_state, to_state, transition)


func _switch_state(state_name: StringName) -> void:
    if state_name == _active_state:
        return

    _active_state = state_name
    if _state_machine_playback:
        _state_machine_playback.travel(state_name)
