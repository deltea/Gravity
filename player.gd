extends CharacterBody2D
class_name Player

enum { RUN, FLY }

@export_group("Running")
@export var run_speed = 220
@export var jump_velocity = 320
@export var gravity = 980
@export var fall_gravity = 1800
@export var double_jump = true

@export_group("Flying")
@export var fly_speed = 300
@export var stamina_cost = 15
@export var stamina_regen = 10
@export var acceleration = 1800
@export var deceleration = 1800
@export var stamina_bar: TextureProgressBar
@export var fly_transition_scale = 1.8

@export_group("Animation")
@export var fly_texture: Texture2D
@export var stretch = 1.8
@export var squash = 1.8
@export var squash_stretch_smoothing = 4
@export var run_rotation_degrees = 30
@export var rotation_smoothing = 1000
@export var stamina_bar_smoothing = 200

@export_group("Gameplay")
@export var arrow: TextureRect
@export var arrow_distance = 100

@onready var sprite := $Sprite
@onready var trail := $Trail
@onready var run_collider := $CollisionShape
@onready var fly_collider := $FlyCollisionShape

var state = RUN
var original_scale = Vector2.ONE
var original_texture: Texture2D
var run_rotation = 0
var double_jump_rotation = 0
var can_double_jump = false
var stamina = 100

func _enter_tree() -> void:
	Globals.player = self

func _ready() -> void:
	original_texture = sprite.texture
	update_stamina(0)

func _process(delta: float) -> void:
	sprite.scale = sprite.scale.move_toward(original_scale, squash_stretch_smoothing * delta)
	sprite.rotation_degrees = move_toward(sprite.rotation_degrees, run_rotation + double_jump_rotation, rotation_smoothing * delta)

	stamina_bar.value = move_toward(stamina_bar.value, stamina, stamina_bar_smoothing * delta)

	var current_target = Globals.level_manager.targets_left.front()
	var direction = current_target.position - position
	arrow.rotation = direction.angle()
	arrow.position = Globals.SCREEN_CENTER + Vector2.from_angle(arrow.rotation) * arrow_distance
	# arrow.position.x = clamp(arrow.position.x, 30, Globals.SCREEN_SIZE.x - 30)

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

	if Input.is_action_just_pressed("fly"):
		start_fly()

	update_stamina(stamina_regen, delta)

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

	update_stamina(-stamina_cost, delta)

	if Input.is_action_just_pressed("fly"):
		end_fly()

	move_and_slide()

func start_fly():
	state = FLY
	trail.enable()
	sprite.texture = fly_texture
	run_collider.disabled = true
	fly_collider.disabled = false
	sprite.scale = Vector2.ONE * fly_transition_scale

func end_fly():
	state = RUN
	trail.disable()
	sprite.texture = original_texture
	fly_collider.disabled = true
	run_collider.disabled = false
	sprite.scale = Vector2.ONE * fly_transition_scale

func update_stamina(value: float, delta: float = 1):
	stamina += value * delta
	stamina = clampf(stamina, 0, 100)

	if stamina <= 0:
		end_fly()

func hide_arrow(target: Target):
	if not target == Globals.level_manager.targets_left.front(): return
	arrow.hide()

func show_arrow(target: Target):
	if not target == Globals.level_manager.targets_left.front(): return
	arrow.show()

func _on_item_area_area_entered(area: Area2D) -> void:
	if area is Refill:
		area.on_collect()
		update_stamina(100)
	elif area is Target and area == Globals.level_manager.targets_left.front():
		Globals.level_manager.pop_target()
		arrow.show()
