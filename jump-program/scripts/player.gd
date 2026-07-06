class_name Player
extends CharacterBody3D
## Kinematic controller with authored jump arcs (not physics-sim).
## Implements the movement contract in docs/jump-program/GREYBOX_BLOCK.md §1:
## tap jump (T0), hold-to-charge jump (T1), ledge grab & mantle, landing states.
## The jump fires on RELEASE: a quick tap is the base jump, holding charges it,
## so tap / variable height / charged jump are one continuous input.

signal landed(surface: Node, drop: float, kind: StringName, airtime: float, distance: float)
signal took_off
signal jumped(kind: StringName)
signal grabbed

enum State { MOVE, CHARGE, MANTLE, STUN }

@export_group("Run")
@export var run_speed := 6.0
@export var ground_accel := 40.0
@export var air_accel := 12.0
@export var turn_speed := 12.0

@export_group("Jump")
## Apex of an uncharged tap, meters. Contract: base jump lands on rises <= apex - 0.1.
@export var jump_height := 1.3
## Apex at full charge (T1). Contract: charged jump lands on rises <= 2.6, mantles <= 3.6.
@export var charged_height := 3.0
## Seconds from takeoff to apex for the BASE jump; sets rise gravity.
## Charged jumps reuse that gravity with a bigger launch speed (floatier, on purpose).
@export var time_to_apex := 0.36
## Hold longer than this (grounded, T1+) to start charging.
@export var charge_threshold := 0.15
## Hold this long past the threshold for full charge.
@export var charge_time := 0.6
## Steering speed while charging (aiming).
@export var charge_walk_speed := 2.0
@export var fall_gravity_mult := 1.8
@export var coyote_time := 0.1
@export var jump_buffer := 0.1

@export_group("Air (T2)")
## Apex of the mid-air double jump. Contract: charged 2.6 + air 1.0 = 3.6 max rise.
@export var air_jump_height := 1.0
@export var air_jumps_max := 1
## Height gained per wall jump. Contract: +2.0 m per wall contact.
@export var wall_jump_height := 2.0
## Horizontal push away from the wall on a wall jump.
@export var wall_push := 3.5

@export_group("Ledge grab")
## How far ahead of the capsule we search for a wall.
@export var grab_forward := 0.6
## Ledge top must be within this above the feet, mid-air. Contract emerges as
## apex + reach: 1.3 + 0.6 = 1.9 (T0 grab), 3.0 + 0.6 = 3.6 (T1 mantle).
@export var grab_reach := 0.6
@export var mantle_time := 0.28

@export_group("Landing")
## Falls of at least this many meters land heavy (brief stun).
@export var heavy_drop := 4.0
## At T2, drops up to this many meters roll instead of landing heavy (no stun).
@export var roll_drop := 8.0
## Falls beyond this knock the player down. Contract: drops > 12 m = knockdown.
@export var knockdown_drop := 12.0
@export var heavy_stun := 0.25
@export var knockdown_stun := 0.9

@export_group("Progression")
## Set by the XP system on load and on tier-up; exported only for testing.
@export var player_tier := 0

var state := State.MOVE
var last_landing := "—"
var last_landing_kind: StringName = &"clean"
var max_altitude := 0.0
var coyote_left := 0.0
var buffer_left := 0.0
var hold_time := 0.0
var air_jumps_left := 0

var _held := false
var _airtime := 0.0
var _takeoff_pos := Vector3.ZERO
var _fall_top := 0.0
var _was_on_floor := false
var _stun_left := 0.0
var _mantle_from: Vector3
var _mantle_to: Vector3
var _mantle_t := 0.0
var _spawn: Transform3D

@onready var _body: Node3D = $Body


func _ready() -> void:
	_spawn = global_transform


func rise_gravity() -> float:
	return 2.0 * jump_height / (time_to_apex * time_to_apex)


func jump_speed_for(apex: float) -> float:
	return sqrt(2.0 * rise_gravity() * apex)


func charge_ratio() -> float:
	if player_tier < 1 or state != State.CHARGE:
		return 0.0
	return clampf((hold_time - charge_threshold) / charge_time, 0.0, 1.0)


func charge_apex() -> float:
	return lerpf(jump_height, charged_height, charge_ratio())


## Initial velocity the charge arc preview (and the launch itself) uses.
func launch_velocity_preview() -> Vector3:
	var v := Vector3.UP * jump_speed_for(charge_apex())
	var wish := _wish_dir()
	if wish.length() > 0.1:
		var h := wish.normalized() * run_speed
		v.x = h.x
		v.z = h.z
	return v


func respawn() -> void:
	global_transform = _spawn
	velocity = Vector3.ZERO
	state = State.MOVE
	hold_time = 0.0
	_fall_top = global_position.y


func _physics_process(delta: float) -> void:
	if state == State.MANTLE:
		_mantle_step(delta)
		return
	if state == State.STUN:
		_stun_left -= delta
		if _stun_left <= 0.0:
			state = State.MOVE

	var held := state != State.STUN \
		and (Input.is_action_pressed(&"jump") or TouchControls.jump_held)
	var released := _held and not held
	_held = held

	var on_floor := is_on_floor()
	if on_floor:
		_fall_top = global_position.y
		air_jumps_left = air_jumps_max
	else:
		_fall_top = maxf(_fall_top, global_position.y)
		_airtime += delta
		var g := rise_gravity() * (fall_gravity_mult if velocity.y < 0.0 else 1.0)
		velocity.y -= g * delta

	coyote_left = coyote_time if on_floor else maxf(coyote_left - delta, 0.0)
	buffer_left = maxf(buffer_left - delta, 0.0)

	hold_time = hold_time + delta if held else 0.0
	if state == State.MOVE and held and on_floor \
			and hold_time > charge_threshold and player_tier >= 1:
		state = State.CHARGE

	if released:
		if state == State.CHARGE:
			_launch(charge_apex(), true, &"charged")
			state = State.MOVE
		elif coyote_left > 0.0:
			_launch(jump_height, false, &"tap")
		elif player_tier >= 2 and not on_floor and is_on_wall():
			_wall_jump()
		elif player_tier >= 2 and not on_floor and air_jumps_left > 0:
			air_jumps_left -= 1
			_launch(air_jump_height, true, &"air")
		else:
			buffer_left = jump_buffer
	if buffer_left > 0.0 and coyote_left > 0.0 and state == State.MOVE:
		_launch(jump_height, false, &"tap")
		buffer_left = 0.0

	var wish := _wish_dir() if state != State.STUN else Vector3.ZERO
	var top_speed := charge_walk_speed if state == State.CHARGE else run_speed
	var accel := ground_accel if on_floor else air_accel
	velocity.x = move_toward(velocity.x, wish.x * top_speed, accel * delta)
	velocity.z = move_toward(velocity.z, wish.z * top_speed, accel * delta)

	if not on_floor and velocity.y < 1.0 and state == State.MOVE:
		_try_grab(wish)
		if state == State.MANTLE:
			return

	var fall_speed := velocity.y
	move_and_slide()

	var flat := Vector3(velocity.x, 0.0, velocity.z)
	if flat.length() > 0.5 and state != State.STUN:
		_body.rotation.y = lerp_angle(_body.rotation.y, atan2(flat.x, flat.z), turn_speed * delta)

	if is_on_floor() and not _was_on_floor:
		_on_landed(fall_speed)
	elif not is_on_floor() and _was_on_floor:
		_takeoff_pos = global_position
		_airtime = 0.0
		took_off.emit()
	_was_on_floor = is_on_floor()

	max_altitude = maxf(max_altitude, global_position.y)

	if global_position.y < -5.0 or Input.is_action_just_pressed(&"reset"):
		respawn()


func _launch(apex: float, aimed: bool, kind: StringName) -> void:
	velocity.y = jump_speed_for(apex)
	if aimed:
		var wish := _wish_dir()
		if wish.length() > 0.1:
			var h := wish.normalized() * run_speed
			velocity.x = h.x
			velocity.z = h.z
	coyote_left = 0.0
	buffer_left = 0.0
	jumped.emit(kind)


func _wall_jump() -> void:
	var n := get_wall_normal()
	velocity.y = jump_speed_for(wall_jump_height)
	velocity.x = n.x * wall_push
	velocity.z = n.z * wall_push
	_body.rotation.y = atan2(n.x, n.z)
	buffer_left = 0.0
	jumped.emit(&"wall")


## Mid-air ledge grab: wall ahead at shin height, walkable top within
## grab_reach above the feet, and the stick pushed toward the wall.
## Clearance check is skipped on purpose — greybox boxes are always clear.
func _try_grab(wish: Vector3) -> void:
	if wish.length() < 0.3:
		return
	var dir := wish.normalized()
	var space := get_world_3d().direct_space_state
	var from := global_position + Vector3.UP * 0.2
	var wall := space.intersect_ray(
		PhysicsRayQueryParameters3D.create(from, from + dir * (0.5 + grab_forward), 1)
	)
	if wall.is_empty() or absf(wall.normal.y) > 0.3:
		return
	var over: Vector3 = wall.position - wall.normal * 0.3
	var top_from := Vector3(over.x, global_position.y + grab_reach + 0.2, over.z)
	var top := space.intersect_ray(
		PhysicsRayQueryParameters3D.create(top_from, top_from + Vector3.DOWN * (grab_reach + 0.2), 1)
	)
	if top.is_empty() or top.normal.y < 0.7:
		return
	var rise: float = top.position.y - global_position.y
	if rise < 0.25 or rise > grab_reach:
		return
	_mantle_from = global_position
	_mantle_to = Vector3(over.x, top.position.y, over.z) + dir * 0.15
	_mantle_t = 0.0
	velocity = Vector3.ZERO
	state = State.MANTLE
	_body.rotation.y = atan2(dir.x, dir.z)
	grabbed.emit()


func _mantle_step(delta: float) -> void:
	_mantle_t += delta / mantle_time
	var t := clampf(_mantle_t, 0.0, 1.0)
	var p := _mantle_from.lerp(_mantle_to, smoothstep(0.0, 1.0, t))
	p.y = lerpf(_mantle_from.y, _mantle_to.y, smoothstep(0.0, 1.0, clampf(t * 1.6, 0.0, 1.0)))
	global_position = p
	if _mantle_t >= 1.0:
		state = State.MOVE
		velocity = Vector3.ZERO
		air_jumps_left = air_jumps_max
		_fall_top = global_position.y
		# Leave _was_on_floor false: the first grounded frame after a mantle
		# fires _on_landed, so grabbing a ledge credits that surface like a landing.
		_was_on_floor = false


func _on_landed(fall_speed: float) -> void:
	var drop := maxf(_fall_top - global_position.y, 0.0)
	var kind: StringName = &"clean"
	if drop > knockdown_drop:
		kind = &"knockdown"
		_stun_left = knockdown_stun
		state = State.STUN
	elif drop >= heavy_drop:
		if player_tier >= 2 and drop <= roll_drop:
			kind = &"roll"
		else:
			kind = &"heavy"
			_stun_left = heavy_stun
			state = State.STUN
	last_landing_kind = kind
	var surface := _floor_collider()
	if surface and surface.is_in_group(&"landable"):
		last_landing = str(surface.get(&"surface_id"))
		var dist := Vector2(global_position.x - _takeoff_pos.x, global_position.z - _takeoff_pos.z)
		landed.emit(surface, drop, kind, _airtime, dist.length())
	if fall_speed < 0.0:
		_fall_top = global_position.y


func _floor_collider() -> Node:
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if col.get_normal().y > 0.7:
			return col.get_collider()
	return null


func _wish_dir() -> Vector3:
	var in_vec := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	if TouchControls.move_vector.length_squared() > in_vec.length_squared():
		in_vec = TouchControls.move_vector
	return Basis(Vector3.UP, _camera_yaw()) * Vector3(in_vec.x, 0.0, in_vec.y)


func _camera_yaw() -> float:
	var rig := get_tree().get_first_node_in_group(&"camera_rig")
	return rig.global_rotation.y if rig is Node3D else 0.0
