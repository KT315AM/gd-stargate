class_name Equipment
extends Node3D
## Base class for all equippable actors


enum Slot
{
    NONE = 0,
    HEAD = 20,
    LEFT_HAND = 40,
    RIGHT_HAND = 41
}

enum Type
{
    UNDEFINED = 0,
    ARMOR = 1,
    CLOTHES = 2,
    WEAPON = 3,
    TOOL = 4,
    AMMUNITION = 5,
    ACCESSORY = 5,
    DECORATION = 6
}


## Can be armed/unarmed when equipped
var armable := false

## Can be attached to rig
var attachable := false

var character: Character
var current_slot: Slot
var _supported_slots: Array[Slot] = []


var default_slot: Slot:
    get: return _supported_slots[0] if not _supported_slots.is_empty() else Slot.NONE

var current_rig_slot: StringName:
    get: return get_parent().name if is_inside_tree() else &""

var attached: bool:
    get: return is_inside_tree()

var equipped: bool:
    get: return current_slot != Slot.NONE


func is_slot_supported(slot: Slot):
    return _supported_slots.has(slot)


func can_be_equipped(slot: Slot = Slot.NONE):
    if not slot:
        slot = default_slot
    
    return is_slot_supported(slot)
