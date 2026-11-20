
class_name UpperBodyAimModifier
extends SkeletonModifier3D
## Rotates the upper body towards the aim target.


@export_group("Aim")
@export var bone_name: StringName = &"mixamorig1_Spine2"

@export_range(0.0, 90.0, 1.0)
var max_yaw_degrees: float = 60.0


var _aim_target: Vector3
var _has_aim_target: bool = false
var _bone_index: int = -1


func _ready() -> void:
    _refresh_bone_index()


func set_aim_target(target: Vector3) -> void:
    _aim_target = target
    _has_aim_target = true


func clear_aim_target() -> void:
    _has_aim_target = false


func _skeleton_changed(_old_skeleton: Skeleton3D, _new_skeleton: Skeleton3D) -> void:
    _refresh_bone_index()


func _refresh_bone_index() -> void:
    var skeleton := get_skeleton()
    if not skeleton:
        _bone_index = -1
        return

    _bone_index = skeleton.find_bone(bone_name)

    if _bone_index < 0:
        push_warning("UpperBodyAimModifier: Bone not found: %s" % bone_name)


func _process_modification_with_delta(_delta: float) -> void:
    if not _has_aim_target:
        return

    var skeleton := get_skeleton()
    if not skeleton:
        return

    if _bone_index < 0:
        _refresh_bone_index()
        if _bone_index < 0:
            return

    var model := skeleton.get_parent_node_3d()
    if not model:
        return

    _apply_aim_rotation(skeleton, model)


func _apply_aim_rotation(skeleton: Skeleton3D, model: Node3D) -> void:
    var target_local := model.to_local(_aim_target)
    target_local.y = 0.0

    if target_local.length_squared() < 0.0001:
        return

    var yaw := -atan2(target_local.x, -target_local.z)
    var max_yaw := deg_to_rad(max_yaw_degrees)
    yaw = clampf(yaw, -max_yaw, max_yaw)

    var bone_pose := skeleton.get_bone_global_pose(_bone_index)
    var rot := Basis(Vector3.UP, yaw)
    var modified_basis := rot * bone_pose.basis
    var modified_pose := Transform3D(modified_basis, bone_pose.origin)

    skeleton.set_bone_global_pose(_bone_index, modified_pose)
