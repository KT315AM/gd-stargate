class_name Character
extends CharacterBody3D
## Base class for all characters.


@onready var collider: CollisionShape3D = get_node_or_null(^"Collider")
@onready var model: Node3D = get_node_or_null(^"Model")