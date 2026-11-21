@warning_ignore_start("shadowed_variable")

class_name DamageInfo
extends RefCounted
## Describes a single damage event.


enum Type {
	KINETIC,
	ENERGY,
	EXPLOSIVE,
	THERMAL,
	TOXIC,
	TRUE
}


var amount: float
var type: Type
var source: Node
var instigator: Node
var hit_position: Vector3
var hit_normal: Vector3


static func create(
	amount: float,
	type: Type = Type.KINETIC,
	source: Node = null,
	instigator: Node = null,
	hit_position: Vector3 = Vector3.ZERO,
	hit_normal: Vector3 = Vector3.ZERO
) -> DamageInfo:
	var damage = DamageInfo.new()
	damage.amount = maxf(amount, 0.0)
	damage.type = type
	damage.source = source
	damage.instigator = instigator
	damage.hit_position = hit_position
	damage.hit_normal = hit_normal
	return damage
