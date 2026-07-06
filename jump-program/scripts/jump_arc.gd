extends MeshInstance3D
## World-projected charge arc: simulates the exact launch the player would get
## on release (same gravity constants as player.gd) and draws the trajectory
## plus a landing ring where it first hits world geometry.

const STEP := 0.03
const MAX_STEPS := 150

var _im := ImmediateMesh.new()

@onready var _player: Player = get_parent()


func _ready() -> void:
	mesh = _im
	top_level = true
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = Color(1.0, 1.0, 1.0, 0.9)
	material_override = m


func _physics_process(_delta: float) -> void:
	_im.clear_surfaces()
	if _player.state != Player.State.CHARGE:
		return
	global_transform = Transform3D.IDENTITY

	var space := get_world_3d().direct_space_state
	var p := _player.global_position + Vector3.UP * 0.05
	var v := _player.launch_velocity_preview()
	var g_up := _player.rise_gravity()
	var pts: Array[Vector3] = [p]
	var hit := {}
	for i in MAX_STEPS:
		var g := g_up * (_player.fall_gravity_mult if v.y < 0.0 else 1.0)
		v.y -= g * STEP
		var next := p + v * STEP
		hit = space.intersect_ray(PhysicsRayQueryParameters3D.create(p, next, 1))
		if not hit.is_empty():
			pts.append(hit.position)
			break
		pts.append(next)
		p = next

	_im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for pt in pts:
		_im.surface_add_vertex(pt)
	_im.surface_end()
	if not hit.is_empty():
		_draw_ring(hit.position, hit.normal)


func _draw_ring(at: Vector3, normal: Vector3) -> void:
	var u := normal.cross(Vector3.RIGHT)
	if u.length() < 0.1:
		u = normal.cross(Vector3.FORWARD)
	u = u.normalized() * 0.4
	var w := normal.cross(u).normalized() * 0.4
	var c := at + normal * 0.03
	_im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for i in 17:
		var a := TAU * i / 16.0
		_im.surface_add_vertex(c + u * cos(a) + w * sin(a))
	_im.surface_end()
