class_name UpperBodyAimModifier
extends SkeletonModifier3D
## Rotates the upper body towards the aim target.


@export_group("Aim")
@export_range(0.0, 90.0, 1.0)
var max_yaw_degrees: float = 60.0

@export_range(0.0, 60.0, 1.0)
var max_pitch_degrees: float = 30.0

@export_range(0.1, 30.0, 0.1)
var aim_smoothing_speed: float = 12.0


@export_group("Spine")
@export var spine_weights: Vector3 = Vector3(0.15, 0.25, 0.60)

@export_range(0.0, 1.0, 0.01)
var head_share: float = 0.25

@export_range(0.0, 1.0, 0.01)
var neck_share: float = 0.35


const SPINE_BONE_NAMES: Array[StringName] = [
    &"mixamorig1_Spine",
    &"mixamorig1_Spine1",
    &"mixamorig1_Spine2"
]
const NECK_BONE_NAME: StringName = &"mixamorig1_Neck"
const HEAD_BONE_NAME: StringName = &"mixamorig1_Head"


var _aim_target: Vector3
var _has_aim_target: bool = false

var _spine_bone_indices: PackedInt32Array = []
var _neck_bone_index: int = -1
var _head_bone_index: int = -1

var _current_yaw: float = 0.0
var _current_pitch: float = 0.0


func _ready() -> void:
    _refresh_bone_indices()


func set_aim_target(target: Vector3) -> void:
    _aim_target = target
    _has_aim_target = true


func clear_aim_target() -> void:
    _has_aim_target = false


func _skeleton_changed(_old_skeleton: Skeleton3D, _new_skeleton: Skeleton3D) -> void:
    _refresh_bone_indices()


func _validate_bone_names() -> void:
    _refresh_bone_indices()


func _refresh_bone_indices() -> void:
    var skeleton := get_skeleton()
    _spine_bone_indices.clear()
    _neck_bone_index = -1
    _head_bone_index = -1

    if not skeleton:
        return

    for bone_name in SPINE_BONE_NAMES:
        var bone_index := skeleton.find_bone(bone_name)
        _spine_bone_indices.append(bone_index)

        if bone_index < 0:
            push_warning("UpperBodyAimModifier: Bone not found: %s" % bone_name)

    _neck_bone_index = skeleton.find_bone(NECK_BONE_NAME)
    _head_bone_index = skeleton.find_bone(HEAD_BONE_NAME)

    if _neck_bone_index < 0:
        push_warning("UpperBodyAimModifier: Bone not found: %s" % NECK_BONE_NAME)

    if _head_bone_index < 0:
        push_warning("UpperBodyAimModifier: Bone not found: %s" % HEAD_BONE_NAME)


func _process_modification_with_delta(delta: float) -> void:
    var skeleton := get_skeleton()
    if not skeleton:
        return

    if _spine_bone_indices.size() != SPINE_BONE_NAMES.size():
        _refresh_bone_indices()

    var model := skeleton.get_parent_node_3d()
    if not model:
        return

    _update_aim_angles(delta, skeleton, model)
    _apply_aim_rotation(skeleton)


func _update_aim_angles(delta: float, skeleton: Skeleton3D, model: Node3D) -> void:
    var target_yaw: float = 0.0
    var target_pitch: float = 0.0

    if _has_aim_target:
        var target_local := skeleton.to_local(_aim_target)
        var origin_local := skeleton.to_local(model.global_position)
        var direction := target_local - origin_local
        var horizontal_length := Vector2(direction.x, direction.z).length()

        if direction.length_squared() > 0.0001:
            target_yaw = atan2(direction.x, -direction.z)
            target_pitch = atan2(direction.y, horizontal_length)

    target_yaw = clampf(
        target_yaw,
        -deg_to_rad(max_yaw_degrees),
        deg_to_rad(max_yaw_degrees)
    )
    target_pitch = clampf(
        target_pitch,
        -deg_to_rad(max_pitch_degrees),
        deg_to_rad(max_pitch_degrees)
    )

    if delta <= 0.0:
        return

    var weight := 1.0 - exp(-aim_smoothing_speed * delta)
    _current_yaw = lerp_angle(_current_yaw, target_yaw, weight)
    _current_pitch = lerpf(_current_pitch, target_pitch, weight)


func _apply_aim_rotation(skeleton: Skeleton3D) -> void:
    var weights := Vector3(
        maxf(spine_weights.x, 0.0),
        maxf(spine_weights.y, 0.0),
        maxf(spine_weights.z, 0.0)
    )
    var weight_sum := weights.x + weights.y + weights.z

    if weight_sum > 0.0:
        weights /= weight_sum
    else:
        weights = Vector3(0.0, 0.0, 1.0)

    var torso_share := 1.0 - clampf(head_share, 0.0, 1.0)

    for i in range(_spine_bone_indices.size()):
        var bone_index: int = _spine_bone_indices[i]
        if bone_index < 0:
            continue

        var weight: float = weights[i] * torso_share
        _rotate_bone(
            skeleton,
            bone_index,
            _current_yaw * weight,
            _current_pitch * weight
        )

    var current_head_share := clampf(head_share, 0.0, 1.0)
    var current_neck_share := clampf(neck_share, 0.0, 1.0)

    _rotate_bone(
        skeleton,
        _neck_bone_index,
        _current_yaw * current_head_share * current_neck_share,
        _current_pitch * current_head_share * current_neck_share
    )
    _rotate_bone(
        skeleton,
        _head_bone_index,
        _current_yaw * current_head_share * (1.0 - current_neck_share),
        _current_pitch * current_head_share * (1.0 - current_neck_share)
    )


func _rotate_bone(
    skeleton: Skeleton3D,
    bone_index: int,
    yaw: float,
    pitch: float
) -> void:
    if bone_index < 0:
        return

    if is_zero_approx(yaw) and is_zero_approx(pitch):
        return

    var bone_pose := skeleton.get_bone_global_pose(bone_index)
    var rotation := (
        Basis(Vector3.UP, yaw)
        * Basis(Vector3.RIGHT, pitch)
    )
    var modified_pose := Transform3D(
        rotation * bone_pose.basis,
        bone_pose.origin
    )

    skeleton.set_bone_global_pose(bone_index, modified_pose)
