extends Node
class_name LevelManager

@export var targets: Array[Target]
@export var target_counter: HBoxContainer
@export var target_ui_lit: Texture2D
@export var target_ui_unlit: Texture2D

var targets_left: Array[Target]

func _enter_tree() -> void:
	Globals.level_manager = self
	targets_left = targets.duplicate()

func _ready() -> void:
	for target in targets:
		var target_ui = TextureRect.new()
		target_ui.texture = target_ui_unlit
		target_counter.add_child(target_ui)

func update_current_target():
	targets_left.front().on_opened()

func pop_target():
	var popped_target = targets_left.pop_front()
	popped_target.on_touched()
	target_counter.get_child(targets.size() - targets_left.size() - 1).texture = target_ui_lit

	if targets_left.size() <= 0:
		end_level()
	else:
		update_current_target()

func end_level():
	get_tree().reload_current_scene()
	print(Globals.timer.text)

func player_die():
	# get_tree().reload_current_scene()
	pass
