extends Control

@export var wobble_speed = 0.005
@export var wobble_magnitude = 5

func _process(_delta: float) -> void:
	rotation_degrees = sin(wobble_speed * Time.get_ticks_msec()) * wobble_magnitude
