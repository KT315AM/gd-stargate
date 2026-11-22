@warning_ignore_start("unused_signal")

class_name Weapon
extends Equipment
## Base class for all weapons


enum State 
{
    UNARMED,
    ARMED,
    ATTACKING,
    BLOCKING,
    RELOADING,
    FAULTY,
}


signal attacking
signal hit(target: Node, damage: DamageInfo)
signal state_changed(previous_state: State, new_state: State)


@export_group("Weapon Settings")

## Damage per hit
@export var damage: float = 10.0

## Damage type
@export var damage_type := DamageInfo.Type.KINETIC

## Attack speed, attacks per second
@export var attack_rate: float = 1.0
@export var max_distance: float = 1000.0

## Deviation from aim, degrees
@export var spread: float = 0.5
@export var state: State = State.UNARMED


@export_group("References")
## Object used as origin of emission (raycasts, projectiles). Defaults to Muzzle or Camera.
@export var caster: Node3D
@export var muzzle: Node3D


var camera: Camera3D
var _attack_timer: Timer


var can_arm: bool:
    get: return state == State.UNARMED

var can_unarm: bool:
    get: return state == State.ARMED or state == State.FAULTY

var can_attack: bool:
    get: return state == State.ARMED


func _ready() -> void:
    _attack_timer = Timer.new()
    _attack_timer.timeout.connect(attack)
    add_child(_attack_timer)

    camera = get_viewport().get_camera_3d()
    
    if not muzzle:
        muzzle = get_node_or_null("Muzzle")
    
    if not caster:
        caster = muzzle if muzzle else camera


func arm():
    if not can_arm:
        return

    _set_state(State.ARMED)


func unarm():
    if not can_unarm:
        return

    _set_state(State.UNARMED)


func attack() -> void:
    if not can_attack:
        return
    
    _set_state(State.ATTACKING)
    _on_attack()
    attacking.emit()
    _play_attack_effects()
    _set_state(State.ARMED)


func start_attack() -> void:
    if not can_attack:
        return
    
    if not _attack_timer.is_stopped():
        return

    _attack_timer.start(1 / max(attack_rate, 0.01))
    _on_attack_started()
    attack()


func stop_attack() -> void:
    if _attack_timer.is_stopped():
        return

    _attack_timer.stop()
    _on_attack_stopped()


func process_hit(target: Node, damage_info: DamageInfo):
    _on_hit(target, damage_info)
    hit.emit(target, damage_info)
    _play_hit_effects()


func _on_attack() -> void:
    print("[%s] Attack" % [name])


func _on_attack_started() -> void:
    print("[%s] Attack started" % [name])


func _on_attack_stopped() -> void:
    print("[%s] Attack stopped" % [name])


func _on_hit(target: Node, damage_info: DamageInfo):
    print("[%s] Hit: %s, %.2v, %.2v" % [name, target.name, damage_info.hit_position, damage_info.hit_normal])


func _play_attack_effects() -> void:
    pass


func _play_hit_effects() -> void:
    pass


func _set_state(new_state: State) -> void:
    if new_state == state:
        return
    
    var previous_state = state
    state = new_state
    state_changed.emit(previous_state, new_state)