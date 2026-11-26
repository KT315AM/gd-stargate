class_name NavigationComponent
extends CharacterComponent
## Provides pathfinding and navigation queries for a character.


signal navigation_finished
signal waypoint_reached(position: Vector3)


@export_group("Navigation Agent")

@export_range(0.0, 10.0, 0.05)
var path_desired_distance: float = 0.5

@export_range(0.0, 10.0, 0.05)
var target_desired_distance: float = 1.0

@export_range(0.0, 10.0, 0.05)
var path_max_distance: float = 3.0

@export_range(0.0, 10.0, 0.05)
var avoidance_radius: float = 0.5

@export var avoidance_enabled: bool = false


var agent: NavigationAgent3D
var target_position: Vector3:
    get: return agent.target_position if agent else character.global_position

var is_navigation_finished: bool:
    get: return not agent or agent.is_navigation_finished()


func _ready() -> void:
    agent = NavigationAgent3D.new()
    agent.name = "NavigationAgent"
    agent.path_desired_distance = path_desired_distance
    agent.target_desired_distance = target_desired_distance
    agent.path_max_distance = path_max_distance
    agent.radius = avoidance_radius
    agent.avoidance_enabled = avoidance_enabled
    agent.navigation_finished.connect(_on_navigation_finished)
    agent.waypoint_reached.connect(_on_waypoint_reached)
    character.add_child(agent)


func set_target_position(position: Vector3) -> void:
    if not agent:
        return

    agent.target_position = position


func clear_target() -> void:
    if not agent:
        return

    agent.target_position = character.global_position


func get_next_path_position() -> Vector3:
    if not agent:
        return character.global_position

    return agent.get_next_path_position()


func get_next_path_direction() -> Vector3:
    var next_position := get_next_path_position()
    var direction := next_position - character.global_position
    direction.y = 0.0
    return direction.normalized()


func _on_navigation_finished() -> void:
    navigation_finished.emit()


func _on_waypoint_reached(details: Dictionary) -> void:
    waypoint_reached.emit(details.get("position", character.global_position))
