extends Node
class_name LevelManager

@export var targets: Array[Target]
@export var target_counter: HBoxContainer
@export var target_ui_lit: Texture2D
@export var target_ui_unlit: Texture2D
@export var ui_scale = 1.4
@export var ui_scale_smoothing = 3
@export var end_panel: Panel
@export var rank: TextureRect
@export var time_container: Control
@export var time_text: Label
@export var controls: Label
@export var high_score_text: Label

@export var a_rank: Texture2D
@export var b_rank: Texture2D
@export var c_rank: Texture2D
@export var d_rank: Texture2D
@export var e_rank: Texture2D
@export var s_rank: Texture2D

var targets_left: Array[Target]
var level_ended = false
var main_menu = preload("res://main_menu.tscn")
var end_ended = false

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
	rank.scale = rank.scale.move_toward(Vector2.ONE, ui_scale_smoothing * delta)
	time_container.scale = time_container.scale.move_toward(Vector2.ONE, ui_scale_smoothing * delta)
	controls.scale = controls.scale.move_toward(Vector2.ONE, ui_scale_smoothing * delta)
	high_score_text.scale = high_score_text.scale.move_toward(Vector2.ONE, ui_scale_smoothing * delta)

	for target in target_counter.get_children():
		target.scale = target.scale.move_toward(Vector2.ONE, ui_scale_smoothing * delta)

	if end_ended:
		if Input.is_action_just_pressed("jump"):
			get_tree().reload_current_scene()
		elif Input.is_action_just_pressed("fly"):
			print("main menu")
			get_tree().change_scene_to_packed(main_menu)

func update_current_target():
	targets_left.front().on_opened()

func pop_target():
	var popped_target = targets_left.pop_front()
	popped_target.on_touched()

	var target_ui = target_counter.get_child(targets.size() - targets_left.size() - 1)
	target_ui.texture = target_ui_lit
	target_ui.scale = ui_scale * Vector2.ONE

	if targets_left.size() <= 0:
		end_level()
	else:
		update_current_target()

	Globals.alert.show_alert(str(targets_left.size()) + " more to go!")

func end_level():
	level_ended = true
	Events.level_end.emit()
	target_counter.hide()
	end_panel.show()
	var is_high_score = save_high_score()

	await get_tree().create_timer(1.0).timeout

	rank.texture = get_rank()
	rank.scale = ui_scale * Vector2.ONE
	rank.show()

	await get_tree().create_timer(1.0).timeout

	time_container.scale = ui_scale * Vector2.ONE
	time_text.text = str(Globals.timer.text)
	time_container.show()

	if is_high_score:
		await get_tree().create_timer(1.0).timeout

		high_score_text.scale = ui_scale * Vector2.ONE
		high_score_text.show()

	await get_tree().create_timer(1.0).timeout

	controls.scale = ui_scale * Vector2.ONE
	controls.show()

	end_ended = true

func get_rank():
	var time = Globals.timer.time
	if time < 30.0:
		return s_rank
	elif time < 40.0:
		return a_rank
	elif time < 45.0:
		return b_rank
	elif time < 50.0:
		return c_rank
	elif time < 55.0:
		return d_rank
	elif time < 60.0:
		return e_rank

func save_high_score():
	var high_score
	var save_path = "user://high_score_" + get_tree().get_current_scene().name.to_lower().replace(" ", "") + ".save"
	if FileAccess.file_exists(save_path):
		var loaded_file = FileAccess.open(save_path, FileAccess.READ)
		high_score = loaded_file.get_var().to_float()
		if Globals.timer.time < high_score:
			var file = FileAccess.open(save_path, FileAccess.WRITE)
			file.store_var(Globals.timer.text)
			return true
		else:
			return false
	else:
		var file = FileAccess.open(save_path, FileAccess.WRITE)
		file.store_var(Globals.timer.text)
		return true
