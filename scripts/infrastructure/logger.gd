class_name GameLogger extends RefCounted


var name: String


func _init(logger_name: String) -> void:
    name = logger_name


func print(msg: String) -> void:
    print("[%s] %s" % [name, msg])