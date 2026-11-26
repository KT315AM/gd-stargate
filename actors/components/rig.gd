@tool
class_name Rig
extends Node3D
## Manages actor's rig - attachment slots, slot manipulations (attach to slot, detach from slot).


signal attached(node: Node, slot_name: StringName)
signal detached(node: Node, slot_name: StringName)


@export_node_path("Skeleton3D")
var external_skeleton: NodePath:
    set(value):
        external_skeleton = value

        if Engine.is_editor_hint():
            var path = NodePath("..".path_join(value)) if value else value
            for child in get_children():
                if child is BoneAttachment3D:
                    child.external_skeleton = path


var _slots: Dictionary[StringName, Node]


func _ready() -> void:
    _slots = GameUtils.find_unique_nodes(self)


func attach(node: Node, slot_name: StringName) -> bool:
    if not node or node.is_inside_tree():
        return false

    if slot_name not in _slots:
        return false
    
    var slot := _slots[slot_name]
    slot.add_child(node)
    node.owner = owner
    attached.emit(node, slot_name)

    return true


func detach(node: Node, slot_name: StringName) -> bool:
    if not node or not node.is_inside_tree():
        return false

    var node_parent = node.get_parent()
    if not node_parent or node_parent.name != slot_name:
        return false
    
    if slot_name not in _slots:
        return false
    
    if node_parent != _slots[slot_name]:
        return false

    node_parent.remove_child(node)    
    detached.emit(node, slot_name)

    return true


func get_all_slots() -> Array[StringName]:
    return _slots.keys()


func get_attachments(slot_name: StringName) -> Array[Node]:
    if slot_name not in _slots:
        return []
    
    return _slots[slot_name].get_children()
