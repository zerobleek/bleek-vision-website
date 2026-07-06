extends Node3D
## Blocky PS2-era character, built and animated entirely in code:
## run cycle, charge crouch, air tuck, a flip on the double jump,
## land squash. Attached to the player's Body node (the yaw pivot).

const SUIT := Color(0.16, 0.20, 0.30)
const SUIT_DARK := Color(0.12, 0.15, 0.22)
const SKIN := Color(0.83, 0.68, 0.54)
const ACCENT := Color(0.54, 0.63, 0.76)
const FLIP_TIME := 0.38

var _rig: Node3D
var _arm_l: Node3D
var _arm_r: Node3D
var _leg_l: Node3D
var _leg_r: Node3D
var _phase := 0.0
var _flip_left := 0.0
var _squash := 1.0

@onready var _player: Player = get_parent()


func _ready() -> void:
	_rig = Node3D.new()
	add_child(_rig)
	_box(Vector3(0.5, 0.55, 0.28), Vector3(0, 1.25, 0), SUIT)         # torso
	_box(Vector3(0.28, 0.28, 0.28), Vector3(0, 1.67, 0), SKIN)        # head
	_box(Vector3(0.24, 0.07, 0.06), Vector3(0, 1.7, 0.15), ACCENT)    # visor
	_box(Vector3(0.52, 0.1, 0.3), Vector3(0, 1.0, 0), ACCENT)         # belt
	_arm_l = _limb(Vector3(-0.33, 1.5, 0), Vector3(0.13, 0.55, 0.13), SUIT_DARK)
	_arm_r = _limb(Vector3(0.33, 1.5, 0), Vector3(0.13, 0.55, 0.13), SUIT_DARK)
	_leg_l = _limb(Vector3(-0.14, 0.95, 0), Vector3(0.17, 0.9, 0.17), SUIT_DARK)
	_leg_r = _limb(Vector3(0.14, 0.95, 0), Vector3(0.17, 0.9, 0.17), SUIT_DARK)
	_player.jumped.connect(_on_jumped)
	_player.landed.connect(_on_landed)


func _box(size: Vector3, pos: Vector3, color: Color) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.position = pos
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	mi.material_override = m
	_rig.add_child(mi)
	return mi


func _limb(pivot_pos: Vector3, size: Vector3, color: Color) -> Node3D:
	var pivot := Node3D.new()
	pivot.position = pivot_pos
	_rig.add_child(pivot)
	var mi := _box(size, Vector3.ZERO, color)
	mi.reparent(pivot)
	mi.position = Vector3(0, -size.y * 0.5 + 0.05, 0)
	return pivot


func _physics_process(delta: float) -> void:
	var flat := Vector2(_player.velocity.x, _player.velocity.z).length()
	var grounded := _player.is_on_floor()
	var charging := _player.state == Player.State.CHARGE
	var k := 1.0 - exp(-12.0 * delta)

	if charging:
		_pose(0.55, -0.55, 0.35, -0.2, k)          # arms back, one knee bent
	elif grounded:
		_phase += delta * flat * 2.4
		var sw := clampf(flat / _player.run_speed, 0.0, 1.0) * 0.9
		_pose(sin(_phase) * sw, -sin(_phase) * sw, -sin(_phase) * sw, sin(_phase) * sw, k)
	else:
		_pose(-2.4, -2.2, 0.55, -0.35, k)          # arms up, legs split

	var target_squash := 0.88 if charging else 1.0
	_squash = lerpf(_squash, target_squash, k)
	_rig.scale.y = _squash

	if _flip_left > 0.0:
		var step := minf(delta * TAU / FLIP_TIME, _flip_left)
		_rig.rotation.x += step
		_flip_left -= step
		if _flip_left <= 0.0:
			_rig.rotation.x = 0.0


func _pose(arm_l: float, arm_r: float, leg_l: float, leg_r: float, k: float) -> void:
	_arm_l.rotation.x = lerpf(_arm_l.rotation.x, arm_l, k)
	_arm_r.rotation.x = lerpf(_arm_r.rotation.x, arm_r, k)
	_leg_l.rotation.x = lerpf(_leg_l.rotation.x, leg_l, k)
	_leg_r.rotation.x = lerpf(_leg_r.rotation.x, leg_r, k)


func _on_jumped(kind: StringName) -> void:
	if kind == &"air":
		_flip_left = TAU
	_squash = 1.08  # brief stretch on takeoff


func _on_landed(
	_surface: Node, _drop: float, kind: StringName, _airtime: float, _distance: float
) -> void:
	match kind:
		&"heavy", &"knockdown":
			_squash = 0.68
		&"roll":
			_squash = 0.78
		_:
			_squash = 0.85
	_rig.rotation.x = 0.0
	_flip_left = 0.0
