class_name NpcCharacterController
extends CharacterComponent
## Controls an NPC's basic behavior.

signal target_acquired(target: Character)
signal target_lost(target: Character)


@export_group("Pursuit")
@export_range(0.0, 10.0, 0.1)
var stop_distance: float = 1.6

@export_range(0.1, 10.0, 0.1)
var navigation_target_update_distance: float = 0.5


@onready var movement_component: NpcMovementComponent = character.get_node_or_null(^"NpcMovementComponent")
@onready var navigation_component: NavigationComponent = character.get_node_or_null(^"NavigationComponent")
@onready var sense_component: SenseComponent = character.get_node_or_null(^"SenseComponent")


var _target: Character
var _last_known_target_position: Vector3
var _has_last_known_target_position: bool = false
var _last_navigation_target_position: Vector3
var _has_navigation_target_position: bool = false


func _ready() -> void:
    if sense_component:
        sense_component.vision_target_acquired.connect(_on_vision_target_acquired)
        sense_component.vision_target_lost.connect(_on_vision_target_lost)

        if sense_component.vision_target:
            _set_target(sense_component.vision_target)


func _physics_process(_delta: float) -> void:
    if not movement_component:
        return

    if not _is_character_alive():
        _stop_movement()
        return

    if _is_target_valid():
        _last_known_target_position = _target.global_position
        _has_last_known_target_position = true
        _update_navigation_target(_last_known_target_position)
        _update_target_movement()
        return

    if _has_last_known_target_position:
        _move_to_last_known_position()
        return

    _stop_movement()


func _on_vision_target_acquired(target: Character) -> void:
    character._logger.print("Vision: target acquired: %s" % [target.name])
    _set_target(target)


func _on_vision_target_lost(target: Character) -> void:
    character._logger.print("Vision: target lost: %s" % [target.name])
    if target != _target:
        return

    if is_instance_valid(target):
        _last_known_target_position = target.global_position
        _has_last_known_target_position = true

    _target = null
    _has_navigation_target_position = false

    if navigation_component and _has_last_known_target_position:
        navigation_component.set_target_position(_last_known_target_position)
        _last_navigation_target_position = _last_known_target_position
        _has_navigation_target_position = true

    target_lost.emit(target)


func _set_target(target: Character) -> void:
    if not is_instance_valid(target) or target == character:
        return

    if _target == target:
        return

    _target = target
    _last_known_target_position = target.global_position
    _has_last_known_target_position = true
    _has_navigation_target_position = false

    if navigation_component:
        navigation_component.set_target_position(_target.global_position)

    target_acquired.emit(target)


func _update_navigation_target(position: Vector3) -> void:
    if not navigation_component:
        return

    if (
        not _has_navigation_target_position
        or _last_navigation_target_position.distance_to(position)
            >= navigation_target_update_distance
    ):
        navigation_component.set_target_position(position)
        _last_navigation_target_position = position
        _has_navigation_target_position = true


func _update_target_movement() -> void:
    var offset := _target.global_position - character.global_position
    offset.y = 0.0

    movement_component.set_facing_direction(offset)

    if offset.length() <= stop_distance:
        movement_component.set_move_direction(Vector3.ZERO)
        return

    if navigation_component:
        movement_component.set_move_direction(
            navigation_component.get_next_path_direction()
        )
    else:
        movement_component.set_move_direction(offset.normalized())


func _move_to_last_known_position() -> void:
    var offset := _last_known_target_position - character.global_position
    offset.y = 0.0

    if offset.length() <= stop_distance:
        _clear_last_known_position()
        return

    var direction := offset.normalized()
    if navigation_component:
        direction = navigation_component.get_next_path_direction()

    movement_component.set_facing_direction(direction)
    movement_component.set_move_direction(direction)


func _clear_last_known_position() -> void:
    _has_last_known_target_position = false
    _has_navigation_target_position = false

    if navigation_component:
        navigation_component.clear_target()

    _stop_movement()


func _stop_movement() -> void:
    if not movement_component:
        return

    movement_component.set_move_direction(Vector3.ZERO)
    movement_component.clear_facing_direction()


func _is_character_alive() -> bool:
    return not character.health_component or character.health_component.is_alive


func _is_target_valid() -> bool:
    return _target and is_instance_valid(_target)
