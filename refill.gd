extends Area2D
class_name Refill

@export var spin_speed = 100
@export var float_magnitude = 5
@export var float_speed = 0.005

var original_pos

func _ready() -> void:
	original_pos = position

func _process(delta: float) -> void:
	var pos = Vector2.UP * sin(Time.get_ticks_msec() * float_speed) * float_magnitude
	position = original_pos + pos

	rotation_degrees += spin_speed * delta

func on_collect():
	queue_free()
