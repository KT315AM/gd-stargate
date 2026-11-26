class_name PlayerCharacter
extends Character
## Base class for all playable characters.


func _ready() -> void:
    add_to_group("player")
