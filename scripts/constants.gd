class_name Constants
extends Object
## Game specific constants


# Common physics layers (1-16)
const PHYSICS_LAYER_WORLD = 1 << 0
const PHYSICS_LAYER_CHARACTERS = 1 << 1
const PHYSICS_LAYER_STRUCTURES = 1 << 2


# Trait layers - stored as 3D Physics layers (17-32)
const TRAIT_LAYER_REACTABLE = 1 << 16
const TRAIT_LAYER_ACTIVATABLE = 1 << 17
const TRAIT_LAYER_INTERACTABLE = 1 << 18

## Damageable actors can take damage and always has `health_component: HealthComponent` property.
const TRAIT_LAYER_DAMAGEABLE = 1 << 19
