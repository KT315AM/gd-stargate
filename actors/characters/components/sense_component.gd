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


func _ready() -> void:
    add_to_group("sense_components")


func _physics_process(delta: float) -> void:
    if debug:
        var half_angle := deg_to_rad(vision_angle * 0.5)
        var rot := character.model.global_rotation.y + PI / 4
        DebugDraw.draw_arc(character.global_position + Vector3(0, 0.05, 0), vision_range, rot - half_angle, rot + half_angle)

    _vision_timer += delta
    if _vision_timer < vision_interval:
        return

    _vision_timer = 0.0
    _update_vision()


func _update_vision() -> void:
    var visible_target := _find_visible_player()

    if visible_target == _vision_target:
        return

    var previous_target := _vision_target
    _vision_target = visible_target

    if previous_target:
        vision_target_lost.emit(previous_target)

    if _vision_target:
        vision_target_acquired.emit(_vision_target)


func _find_visible_player() -> Character:
    var origin := character.global_position
    var forward := -character.global_basis.z
    forward.y = 0.0
    forward = forward.normalized()

    var half_angle := deg_to_rad(vision_angle * 0.5)
    var space := character.get_world_3d().direct_space_state

    for node in get_tree().get_nodes_in_group("player"):
        if not node is Character or node == character or not is_instance_valid(node):
            continue

        var target := node as Character
        var target_position := target.global_position
        var offset := target_position - origin
        var distance := offset.length()

        if distance > vision_range or distance <= 0.001:
            continue

        var direction := offset / distance
        if forward.dot(direction) < cos(half_angle):
            continue

        var query := PhysicsRayQueryParameters3D.create(origin, target_position)
        query.collision_mask = vision_collision_mask
        query.exclude = [character.get_rid()]
        query.collide_with_areas = false
        query.collide_with_bodies = true

        var result := space.intersect_ray(query)
        if result.is_empty() or result.collider == target:
            return target

    return null


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

    sound_heard.emit(source, position, loudness)
