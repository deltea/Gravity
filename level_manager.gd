extends Node
class_name LevelManager

@export var targets: Array[Target]
@export var target_counter: HBoxContainer
@export var target_ui_lit: Texture2D
@export var target_ui_unlit: Texture2D
@export var target_ui_scale = 1.5
@export var target_ui_scale_smoothing = 3

var targets_left: Array[Target]

func _enter_tree() -> void:
	Globals.level_manager = self
	targets_left = targets.duplicate()

func _ready() -> void:
	for target in targets:
		var target_ui = TextureRect.new()
		target_ui.texture = target_ui_unlit
		target_ui.pivot_offset = Vector2(4, 8)
		target_counter.add_child(target_ui)

func _process(delta: float) -> void:
	for target in target_counter.get_children():
		target.scale = target.scale.move_toward(Vector2.ONE, target_ui_scale_smoothing * delta)

func update_current_target():
	targets_left.front().on_opened()

func pop_target():
	var popped_target = targets_left.pop_front()
	popped_target.on_touched()

	var target_ui = target_counter.get_child(targets.size() - targets_left.size() - 1)
	target_ui.texture = target_ui_lit
	target_ui.scale = target_ui_scale * Vector2.ONE

	if targets_left.size() <= 0:
		end_level()
	else:
		update_current_target()

func end_level():
	get_tree().reload_current_scene()
	print(Globals.timer.text)
