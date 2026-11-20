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


func _init(
	p_amount: float,
	p_type: Type = Type.KINETIC,
	p_source: Node = null,
	p_instigator: Node = null,
	p_hit_position: Vector3 = Vector3.ZERO,
	p_hit_normal: Vector3 = Vector3.ZERO
) -> void:
	amount = maxf(p_amount, 0.0)
	type = p_type
	source = p_source
	instigator = p_instigator
	hit_position = p_hit_position
	hit_normal = p_hit_normal
