class_name Player
extends CharacterBody3D
## Kinematic controller with authored jump arcs (not physics-sim).
## The numbers here ARE the movement contract in
## docs/jump-program/GREYBOX_BLOCK.md §1 — if tuning changes them,
## the level geometry gets re-audited against the new values.

signal landed(surface: Node, fall_speed: float)

@export_group("Run")
@export var run_speed := 6.0
@export var ground_accel := 40.0
@export var air_accel := 12.0
@export var turn_speed := 12.0

@export_group("Jump")
## Apex height in meters. Contract: base jump lands on rises <= apex - 0.1.
@export var jump_height := 1.3
## Seconds from takeoff to apex. Shorter = snappier.
@export var time_to_apex := 0.36
## Falling gravity multiplier vs rising — heavier down is the classic feel trick.
@export var fall_gravity_mult := 1.8
## Vertical speed kept when jump is released mid-rise (variable height).
@export var jump_cut_mult := 0.4
@export var coyote_time := 0.1
@export var jump_buffer := 0.1

var last_landing := "—"
var max_altitude := 0.0
var coyote_left := 0.0
var buffer_left := 0.0

var _was_on_floor := false
var _jump_was_held := false
var _spawn: Transform3D

@onready var _body: Node3D = $Body


func _ready() -> void:
	_spawn = global_transform


func rise_gravity() -> float:
	return 2.0 * jump_height / (time_to_apex * time_to_apex)


func jump_velocity() -> float:
	return rise_gravity() * time_to_apex


func _physics_process(delta: float) -> void:
	var on_floor := is_on_floor()

	if not on_floor:
		var g := rise_gravity() * (fall_gravity_mult if velocity.y < 0.0 else 1.0)
		velocity.y -= g * delta

	coyote_left = coyote_time if on_floor else maxf(coyote_left - delta, 0.0)
	buffer_left = maxf(buffer_left - delta, 0.0)
	if Input.is_action_just_pressed(&"jump") or TouchControls.consume_jump():
		buffer_left = jump_buffer
	if buffer_left > 0.0 and coyote_left > 0.0:
		velocity.y = jump_velocity()
		buffer_left = 0.0
		coyote_left = 0.0

	var jump_held := Input.is_action_pressed(&"jump") or TouchControls.jump_held
	if velocity.y > 0.0 and _jump_was_held and not jump_held:
		velocity.y *= jump_cut_mult
	_jump_was_held = jump_held

	var in_vec := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	if TouchControls.move_vector.length_squared() > in_vec.length_squared():
		in_vec = TouchControls.move_vector
	var cam_yaw := _camera_yaw()
	var wish := Basis(Vector3.UP, cam_yaw) * Vector3(in_vec.x, 0.0, in_vec.y)
	var accel := ground_accel if on_floor else air_accel
	velocity.x = move_toward(velocity.x, wish.x * run_speed, accel * delta)
	velocity.z = move_toward(velocity.z, wish.z * run_speed, accel * delta)

	var fall_speed := velocity.y
	move_and_slide()

	var flat := Vector3(velocity.x, 0.0, velocity.z)
	if flat.length() > 0.5:
		_body.rotation.y = lerp_angle(_body.rotation.y, atan2(flat.x, flat.z), turn_speed * delta)

	if is_on_floor() and not _was_on_floor:
		_on_landed(fall_speed)
	_was_on_floor = is_on_floor()

	max_altitude = maxf(max_altitude, global_position.y)

	if global_position.y < -5.0 or Input.is_action_just_pressed(&"reset"):
		respawn()


func respawn() -> void:
	global_transform = _spawn
	velocity = Vector3.ZERO


func _on_landed(fall_speed: float) -> void:
	var surface := _floor_collider()
	if surface and surface.is_in_group(&"landable"):
		last_landing = str(surface.get(&"surface_id"))
		landed.emit(surface, fall_speed)


func _floor_collider() -> Node:
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if col.get_normal().y > 0.7:
			return col.get_collider()
	return null


func _camera_yaw() -> float:
	var rig := get_tree().get_first_node_in_group(&"camera_rig")
	return rig.global_rotation.y if rig is Node3D else 0.0
