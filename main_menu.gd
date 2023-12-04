extends Node

enum { MAIN, LEVEL_SELECT, SETTINGS }

@export var option_inactive_color = Color.GRAY
@export var option_active_color = Color.WHITE
@export var options: VBoxContainer
@export var camera_smoothing = 1000
@export var camera_play_position = Vector2(320 + 160, 120)
@export var level_tiles: Control
@export var level_wobble_speed = 0.005
@export var level_wobble_magnitude = 10

@onready var camera := $Camera

var state = MAIN
var select_index = 0
var camera_target: Vector2
var original_camera_pos: Vector2

var level_1 = preload("res://level_1.tscn")

func _ready() -> void:
	update_options_main()
	original_camera_pos = camera.position
	camera_target = camera.position

func _process(delta: float) -> void:
	camera.position = camera.position.move_toward(camera_target, camera_smoothing * delta)

	match state:
		MAIN: main_state()
		LEVEL_SELECT: level_select_state()

func main_state():
	if Input.is_action_just_pressed("down"):
		select_index += 1
		update_options_main()
	elif Input.is_action_just_pressed("up"):
		select_index -= 1
		update_options_main()
	elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("fly"):
		select()

func level_select_state():
	if Input.is_action_just_pressed("right"):
		select_index += 1
		update_options_level_select()
	elif Input.is_action_just_pressed("left"):
		select_index -= 1
		update_options_level_select()
	elif Input.is_action_just_pressed("jump"):
		select()
	elif Input.is_action_just_pressed("fly"):
		back()

	for i in level_tiles.get_child_count():
		var level = level_tiles.get_child(i)
		if select_index == i:
			level.rotation_degrees = sin(level_wobble_speed * Time.get_ticks_msec()) * level_wobble_magnitude
		else:
			level.rotation_degrees = 0

func update_options_main():
	select_index = clamp(select_index, 0, options.get_child_count() - 1)
	for i in range(options.get_child_count()):
		var option = options.get_child(i)
		if i == select_index:
			option.label_settings.font_color = option_active_color
		else:
			option.label_settings.font_color = option_inactive_color

func update_options_level_select():
	select_index = clamp(select_index, 0, level_tiles.get_child_count() - 1)

func select():
	if state == MAIN:
		match select_index:
			0: play()
			1: print("settings")
			2: print("quit")
	elif state == LEVEL_SELECT:
		match select_index:
			0: get_tree().change_scene_to_packed(level_1)
			1: print("level 2")
			2: print("level 3")
			3: print("level 4")

func back():
	select_index = 0
	camera_target = original_camera_pos
	state = MAIN

func play():
	select_index = 0
	camera_target = camera_play_position
	state = LEVEL_SELECT
