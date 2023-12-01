extends CharacterBody2D
class_name Player

enum { RUN, FLY }

@export_group("Running")
@export var run_speed = 180
@export var jump_velocity = 320
@export var gravity = 980
@export var fall_gravity = 1800
@export var double_jump = true

@export_group("Flying")
@export var fly_speed = 240
@export var acceleration = 1800
@export var deceleration = 1800

@export_group("Animation")
@export var stretch = 1.8
@export var squash = 1.8
@export var squash_stretch_smoothing = 4
@export var run_rotation_degrees = 30
@export var rotation_smoothing = 1000

@onready var sprite := $Sprite
@onready var trail := $Trail

var state = RUN
var original_scale = Vector2.ONE
var run_rotation = 0
var double_jump_rotation = 0
var can_double_jump = false

func _ready():
	Globals.player = self

func _process(delta: float) -> void:
	sprite.scale = sprite.scale.move_toward(original_scale, squash_stretch_smoothing * delta)
	sprite.rotation_degrees = move_toward(sprite.rotation_degrees, run_rotation + double_jump_rotation, rotation_smoothing * delta)

func _physics_process(delta: float) -> void:
	match state:
		RUN: run_state(delta)
		FLY: fly_state(delta)

func run_state(delta: float):
	if not is_on_floor():
		if velocity.y > 0:
			velocity.y += fall_gravity * delta
		else:
			velocity.y += gravity * delta
	else:
		can_double_jump = true

	var input := Input.get_axis("left", "right")
	if input:
		run_rotation = input * run_rotation_degrees
		velocity.x = input * run_speed
	else:
		velocity.x = 0
		run_rotation = 0

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = -jump_velocity
			sprite.scale = Vector2(original_scale.x / stretch, original_scale.y * stretch)
		else:
			if can_double_jump and double_jump:
				velocity.y = -jump_velocity
				double_jump_rotation += (1.0 if input == 0 else input) * 360
				can_double_jump = false

	if Input.is_action_just_pressed("transform"):
		state = FLY
		trail.enable()

	var was_on_floor = is_on_floor()

	move_and_slide()

	if not was_on_floor and is_on_floor():
		sprite.scale = Vector2(original_scale.x * squash, original_scale.y / squash)

func fly_state(delta: float):
	var input := Input.get_vector("left", "right", "up", "down")
	if input:
		velocity = velocity.move_toward(input * fly_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, deceleration * delta)

	if Input.is_action_just_pressed("transform"):
		state = RUN
		trail.disable()

	move_and_slide()
