extends Node

@export var option_inactive_color = Color.GRAY
@export var option_active_color = Color.WHITE
@export var options: VBoxContainer

var select_index = 0

func _ready() -> void:
	update_options()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("down"):
		select_index += 1
		update_options()
	elif Input.is_action_just_pressed("up"):
		select_index -= 1
		update_options()
	elif Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("fly"):
		select()

func update_options():
	select_index = clamp(select_index, 0, options.get_child_count() - 1)
	for i in range(options.get_child_count()):
		var option = options.get_child(i)
		if i == select_index:
			option.label_settings.font_color = option_active_color
		else:
			option.label_settings.font_color = option_inactive_color

func select():
	match select_index:
		0: print("play")
		1: print("settings")
		2: print("quit")
