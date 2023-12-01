extends Node
class_name LevelManager

@export var targets: Array[Target]

var targets_left: Array[Target]

func _enter_tree() -> void:
	Globals.level_manager = self
	targets_left = targets

func update_current_target():
	targets_left.front().on_opened()

func pop_target():
	var popped_target = targets_left.pop_front()
	popped_target.on_touched()
	if targets_left.size() <= 0:
		get_tree().reload_current_scene()
	else:
		update_current_target()
