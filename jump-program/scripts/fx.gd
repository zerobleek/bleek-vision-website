extends Node3D
## Landing dust + speed lines, built in code. Chunky box particles — no
## soft alpha sprites; the era demands hard little cubes.

var _dust: GPUParticles3D
var _trail: GPUParticles3D

@onready var _player: Player = get_parent()


func _ready() -> void:
	_dust = _make_emitter(14, 0.5, true, Color(0.75, 0.73, 0.7), 2.5, -6.0)
	_trail = _make_emitter(24, 0.3, false, Color(1, 1, 1, 0.5), 0.4, 0.0)
	_player.landed.connect(_on_landed)


func _make_emitter(
	amount: int, lifetime: float, one_shot: bool, color: Color, speed: float, gravity: float
) -> GPUParticles3D:
	var p := GPUParticles3D.new()
	p.amount = amount
	p.lifetime = lifetime
	p.one_shot = one_shot
	p.explosiveness = 1.0 if one_shot else 0.0
	p.emitting = false
	p.local_coords = false
	var pm := ParticleProcessMaterial.new()
	pm.direction = Vector3(0, 1, 0)
	pm.spread = 75.0
	pm.initial_velocity_min = speed * 0.5
	pm.initial_velocity_max = speed
	pm.gravity = Vector3(0, gravity, 0)
	pm.scale_min = 0.6
	pm.scale_max = 1.2
	pm.color = color
	p.process_material = pm
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.08, 0.08, 0.08)
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.vertex_color_use_as_albedo = true
	mesh.material = m
	p.draw_pass_1 = mesh
	add_child(p)
	return p


func _physics_process(_delta: float) -> void:
	var fast := _player.velocity.length() > 8.0
	if _trail.emitting != fast:
		_trail.emitting = fast
	_trail.global_position = _player.global_position + Vector3.UP * 0.9


func _on_landed(
	_surface: Node, drop: float, _kind: StringName, airtime: float, _distance: float
) -> void:
	if airtime < 0.15 and drop < 0.5:
		return
	_dust.global_position = _player.global_position + Vector3.UP * 0.1
	_dust.restart()
	_dust.emitting = true
