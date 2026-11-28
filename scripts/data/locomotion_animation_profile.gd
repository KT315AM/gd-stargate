class_name LocomotionAnimationProfile
extends Resource
## Defines the locomotion clips used by a weapon or character.

@export_group("State")
@export var state_name: StringName = &"Rifle"

@export_group("Animation Library")
@export var animation_library: AnimationLibrary
@export var library_name: StringName = &"rifle"

@export_group("Animation Names")
@export var idle_animation: StringName = &"idle"
@export var walk_forward_animation: StringName = &"walk_forward"
@export var run_forward_animation: StringName = &"run"
@export var walk_backward_animation: StringName = &"walk_backward"
@export var strafe_left_animation: StringName = &"run_strafe_left"
@export var strafe_right_animation: StringName = &"run_strafe_right"
