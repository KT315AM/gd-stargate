class_name SenseComponent
extends CharacterComponent
## Collects sensory information and emits perception signals.


signal vision_target_acquired(target: Character)
signal vision_target_lost(target: Character)
signal sound_heard(source: Node, position: Vector3, loudness: float)


@export_group("Vision")
@export_range(0.0, 1000.0, 0.1)
var vision_range: float = 25.0

@export_range(0.0, 360.0, 1.0)
var vision_angle: float = 120.0

@export_range(0.05, 5.0, 0.05)
var vision_interval: float = 0.2

@export_range(0.0, 10.0, 0.05)
var vision_acquire_time: float = 0.1

@export_range(0.0, 10.0, 0.05)
var vision_target_loss_grace_time: float = 0.6

@export_range(0.0, 90.0, 1.0)
var vision_target_retention_angle_bonus: float = 15.0

@export_range(1.0, 3.0, 0.05)
var vision_target_retention_range_multiplier: float = 1.1

@export_range(0.0, 5.0, 0.1)
var vision_eye_height: float = 1.4

@export_range(0.0, 5.0, 0.1)
var vision_target_aim_height: float = 1.0

@export_flags_3d_physics
var vision_collision_mask: int = (
    Constants.PHYSICS_LAYER_WORLD |
    Constants.PHYSICS_LAYER_CHARACTERS |
    Constants.PHYSICS_LAYER_STRUCTURES
)


@export_group("Hearing")
@export_range(0.0, 1000.0, 0.1)
var hearing_range: float = 15.0


@export_group("Debug")
@export var debug := false


var vision_target: Character:
    get: return _vision_target


var _vision_target: Character
var _vision_timer: float = 0.0
var _vision_candidate: Character
var _vision_candidate_elapsed: float = 0.0
var _vision_target_lost_elapsed: float = 0.0


func _ready() -> void:
    add_to_group("sense_components")


func _physics_process(delta: float) -> void:
    if debug:
        _draw_vision_fov()

    _vision_timer += delta
    if _vision_timer < vision_interval:
        return

    var elapsed := _vision_timer
    _vision_timer = fmod(_vision_timer, vision_interval)
    _update_vision(elapsed)


func _draw_vision_fov() -> void:
    if not character.model:
        return

    var forward := _get_vision_forward()
    if forward.length_squared() < 0.0001:
        return

    var center_angle := atan2(forward.z, forward.x)
    var half_angle := deg_to_rad(vision_angle * 0.5)
    DebugDraw.draw_arc(
        character.global_position + Vector3.UP * 0.05,
        vision_range,
        center_angle - half_angle,
        center_angle + half_angle,
        32,
        Color.YELLOW
    )


func _get_vision_forward() -> Vector3:
    var forward := -character.model.global_basis.z
    forward.y = 0.0
    return forward.normalized()


func _update_vision(elapsed: float) -> void:
    if _vision_target and not is_instance_valid(_vision_target):
        _set_vision_target(null)

    if _vision_target:
        if _is_target_visible(_vision_target, true):
            _vision_target_lost_elapsed = 0.0
            _reset_vision_candidate()
            return

        _vision_target_lost_elapsed += elapsed
        if _vision_target_lost_elapsed < vision_target_loss_grace_time:
            return

        _set_vision_target(null)

    _vision_target_lost_elapsed = 0.0

    var visible_target := _find_visible_player()
    if not visible_target:
        _reset_vision_candidate()
        return

    if visible_target != _vision_candidate:
        _vision_candidate = visible_target
        _vision_candidate_elapsed = 0.0

    _vision_candidate_elapsed += elapsed
    if _vision_candidate_elapsed < vision_acquire_time:
        return

    _set_vision_target(_vision_candidate)
    _reset_vision_candidate()


func _set_vision_target(target: Character) -> void:
    if target == _vision_target:
        return

    var previous_target := _vision_target
    _vision_target = target
    _vision_target_lost_elapsed = 0.0

    if previous_target:
        vision_target_lost.emit(previous_target)

    if _vision_target:
        vision_target_acquired.emit(_vision_target)


func _reset_vision_candidate() -> void:
    _vision_candidate = null
    _vision_candidate_elapsed = 0.0


func _find_visible_player() -> Character:
    for node in get_tree().get_nodes_in_group("player"):
        if not node is Character or node == character or not is_instance_valid(node):
            continue

        var target := node as Character
        if _is_target_visible(target, false):
            return target

    return null


func _is_target_visible(target: Character, retain_target: bool) -> bool:
    if not is_instance_valid(target) or target == character:
        return false

    var origin := character.global_position
    var target_position := target.global_position
    var offset := target_position - origin
    offset.y = 0.0

    var distance := offset.length()
    var range_multiplier := vision_target_retention_range_multiplier if retain_target else 1.0
    if distance > vision_range * range_multiplier or distance <= 0.001:
        return false

    var forward := _get_vision_forward()
    if forward.length_squared() < 0.0001:
        return false

    var direction := offset / distance
    var angle := vision_angle
    if retain_target:
        angle = minf(vision_angle + vision_target_retention_angle_bonus * 2.0, 360.0)

    if forward.dot(direction) < cos(deg_to_rad(angle * 0.5)):
        return false

    var ray_origin := origin + Vector3.UP * vision_eye_height
    var ray_target := target_position + Vector3.UP * vision_target_aim_height
    var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_target)
    query.collision_mask = vision_collision_mask
    query.exclude = [character.get_rid()]
    query.collide_with_areas = false
    query.collide_with_bodies = true

    var result := character.get_world_3d().direct_space_state.intersect_ray(query)
    if result.is_empty():
        return true

    var collider := result.get("collider") as Node
    return collider == target or (collider and target.is_ancestor_of(collider))


static func broadcast_sound(source: Node, position: Vector3, loudness: float = 1.0) -> void:
    if not source or not is_instance_valid(source):
        return

    var tree := source.get_tree()
    for node in tree.get_nodes_in_group("sense_components"):
        if node is SenseComponent:
            (node as SenseComponent)._receive_sound(source, position, maxf(loudness, 0.0))


func _receive_sound(source: Node, position: Vector3, loudness: float) -> void:
    if source == character or loudness <= 0.0:
        return

    var effective_range := hearing_range * loudness
    if character.global_position.distance_to(position) > effective_range:
        return

    if debug:
        DebugDraw.draw_box(
            position + Vector3.UP * 0.15,
            Vector3(0.3, 0.3, 0.3),
            Color.ORANGE
        )

    sound_heard.emit(source, position, loudness)
