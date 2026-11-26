@tool
class_name CharacterRig
extends Rig
## Manages character's rig - attachment slots, slot manipulations (attach to slot, detach from slot).


# Character slots
# body
const SLOT_HEAD = &"HeadSlot"
const SLOT_TORSO = &"TorsoSlot"

const SLOT_BACK_TOP = &"BackTopSlot"
const SLOT_BACK_BOTTOM = &"BackBottomSlot"
const SLOT_BACK_LEFT = &"BackLeftSlot"
const SLOT_BACK_RIGHT = &"BackRightSlot"

const SLOT_BELT_FRONT = &"BeltFrontSlot"
const SLOT_BELT_BACK = &"BeltBackSlot"
const SLOT_BELT_LEFT = &"BeltLeftSlot"
const SLOT_BELT_RIGHT = &"BeltRightSlot"

# hands
const SLOT_LEFT_SHOULDER = &"LeftShoulderSlot"
const SLOT_RIGHT_SHOULDER = &"RightShoulderSlot"
const SLOT_LEFT_HAND = &"LeftHandSlot"
const SLOT_RIGHT_HAND = &"RightHandSlot"

# legs
const SLOT_LEFT_THIGH = &"LeftThighSlot"
const SLOT_RIGHT_THIGH = &"RightThighSlot"
const SLOT_LEFT_FOOT = &"LeftFootSlot"
const SLOT_RIGHT_FOOT = &"RightFootSlot"
