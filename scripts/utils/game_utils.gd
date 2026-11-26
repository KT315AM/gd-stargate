class_name GameUtils
extends RefCounted


static func has_all_traits(object: Node, traits_mask: int) -> bool:
    return object is CollisionObject3D and (object.collision_layer & traits_mask) == traits_mask


static func has_any_traits(object: Node, traits_mask: int) -> bool:
    return object is CollisionObject3D and (object.collision_layer & traits_mask) != 0


static func is_reactable(object: Node) -> bool:
    return has_any_traits(object, Constants.TRAIT_LAYER_REACTABLE)


static func is_activatable(object: Node) -> bool:
    return has_any_traits(object, Constants.TRAIT_LAYER_ACTIVATABLE)


static func is_interactable(object: Node) -> bool:
    return has_any_traits(object, Constants.TRAIT_LAYER_INTERACTABLE)


static func is_damageable(object: Node) -> bool:
    return has_any_traits(object, Constants.TRAIT_LAYER_DAMAGEABLE)


static func find_unique_nodes(root: Node) -> Dictionary[StringName, Node]:
    var result: Dictionary[StringName, Node] = {}
    _collect_unique_nodes(root, root, result)
    return result


static func _collect_unique_nodes(current: Node, root: Node, result: Dictionary[StringName, Node]) -> void:
    for child in current.get_children():
        if child.unique_name_in_owner:
            result[child.name] = child

        if not child.scene_file_path:
            _collect_unique_nodes(child, root, result)
