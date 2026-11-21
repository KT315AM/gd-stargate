class_name Character
extends CharacterBody3D
## Base class for all characters.


# FIX: Temporary export weapons for debug purpose
@export var main_weapon: Weapon
@export var secondary_weapon: Weapon

# Basic nodes
@onready var collider: CollisionShape3D = get_node_or_null(^"Collider")
@onready var model: Node3D = get_node_or_null(^"Model")

# Components
@onready var health_component: HealthComponent = get_node_or_null(^"HealthComponent")
@onready var combat_component: CombatComponent = get_node_or_null(^"CombatComponent")