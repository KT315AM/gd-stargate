class_name ArmIKModifier
extends TwoBoneIK3D
## Configures a two-bone IK chain for an arm.


@export_group("Bones")
@export var root_bone_name: StringName
@export var middle_bone_name: StringName
@export var end_bone_name: StringName

@export_group("Targets")
@export var target_node: Node3D
@export var pole_node: Node3D


func _ready() -> void:
    if not target_node:
        push_warning("ArmIKModifier: Target node is not assigned.")
        return

    if not pole_node:
        push_warning("ArmIKModifier: Pole node is not assigned.")
        return

    set_setting_count(1)
    set_root_bone_name(0, root_bone_name)
    set_middle_bone_name(0, middle_bone_name)
    set_end_bone_name(0, end_bone_name)
    set_target_node(0, get_path_to(target_node))
    set_pole_node(0, get_path_to(pole_node))
