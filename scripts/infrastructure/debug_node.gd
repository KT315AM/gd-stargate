class_name DebugNode extends Node


var _logger := GameLogger.new("DebugNode")


func _init() -> void:
    _logger.print("Init: %s, %s" % [owner, get_parent()])


func _enter_tree() -> void:
    _logger.print("Entr: %s, %s" % [owner, get_parent()])


func _exit_tree() -> void:
    _logger.print("Exit: %s, %s" % [owner, get_parent()])


func _ready() -> void:
    _logger.print("Ready %s -> %s (%s)" % [get_path(), owner.get_path() if owner else ^"null", owner])


# func _process(delta: float) -> void:
#     _logger.print("_process: %s, %s" % [owner, get_parent()])
#     process_mode = Node.PROCESS_MODE_DISABLED