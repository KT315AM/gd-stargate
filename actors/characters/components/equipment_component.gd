class_name EquipmentComponent
extends CharacterComponent
## Manages character's equipment.

signal equipment_changed(slot: Equipment.Slot, equipment: Equipment)


static var slot_map := {
    Equipment.Slot.HEAD: CharacterRig.SLOT_HEAD,
    Equipment.Slot.LEFT_HAND: CharacterRig.SLOT_LEFT_HAND,
    Equipment.Slot.RIGHT_HAND: CharacterRig.SLOT_RIGHT_HAND,
}


var _equipment_registry: Dictionary[Equipment.Slot, Equipment] = {
    Equipment.Slot.HEAD: null,
    Equipment.Slot.LEFT_HAND: null,
    Equipment.Slot.RIGHT_HAND: null,
}


func get_equipped(slot: Equipment.Slot) -> Equipment:
    return _equipment_registry.get(slot)


func can_equip(equipment: Equipment, slot: Equipment.Slot = Equipment.Slot.NONE) -> bool:
    if not slot:
        slot = equipment.default_slot

    return (equipment
        and equipment.can_be_equipped(slot)
        and slot in _equipment_registry
        and _equipment_registry[slot] != equipment
    )


func equip(equipment: Equipment, slot: Equipment.Slot = Equipment.Slot.NONE) -> bool:
    if not equipment:
        return false

    if not slot:
        slot = equipment.default_slot

    if not can_equip(equipment, slot):
        return false

    _equipment_registry[slot] = equipment
    equipment.current_slot = slot

    if equipment.attachable and character.rig:
        character.rig.attach(equipment, slot_map[slot])

    equipment_changed.emit(slot, equipment)
    return true


func unequip(equipment: Equipment) -> bool:
    return equipment and equipment.current_slot and unequip_slot(equipment.current_slot)


func unequip_slot(slot: Equipment.Slot) -> Equipment:
    if slot not in _equipment_registry:
        return null

    var equipment = _equipment_registry[slot]
    if not equipment:
        return null

    _equipment_registry[slot] = null

    if equipment.attached and character.rig:
        character.rig.detach(equipment, equipment.current_rig_slot)

    equipment.current_slot = Equipment.Slot.NONE
    equipment_changed.emit(slot, null)
    return equipment
