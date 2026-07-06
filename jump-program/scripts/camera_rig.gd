extends Node3D
## Follow-orbit camera. Yaw lives on this rig, pitch on the SpringArm3D.
## Orbit comes from right-half touch drags (TouchControls.camera_delta).
## Anticipation: FOV widens with ground speed, arm pulls back while charging.

@export var target_path: NodePath
@export var follow_speed := 8.0
@export var sensitivity := 0.005
@export var pitch_min := -70.0
@export var pitch_max := 30.0
@export var base_fov := 70.0
@export var fov_per_speed := 0.6
@export var charge_pullback := 1.2

var _target: Node3D
var _base_length := 5.5

@onready var _arm: SpringArm3D = $Arm
@onready var _cam: Camera3D = $Arm/Camera


func _ready() -> void:
	add_to_group(&"camera_rig")
	_target = get_node_or_null(target_path)
	_base_length = _arm.spring_length
	if _target:
		global_position = _target.global_position


func _physics_process(delta: float) -> void:
	if _target:
		global_position = global_position.lerp(_target.global_position, 1.0 - exp(-follow_speed * delta))

	var d := TouchControls.camera_delta
	TouchControls.camera_delta = Vector2.ZERO
	rotation.y -= d.x * sensitivity
	_arm.rotation.x = clampf(
		_arm.rotation.x - d.y * sensitivity,
		deg_to_rad(pitch_min),
		deg_to_rad(pitch_max)
	)

	if _target is Player:
		var pl := _target as Player
		var flat := Vector2(pl.velocity.x, pl.velocity.z).length()
		_cam.fov = lerpf(_cam.fov, base_fov + flat * fov_per_speed, 1.0 - exp(-4.0 * delta))
		var want := _base_length + charge_pullback * pl.charge_ratio()
		_arm.spring_length = lerpf(_arm.spring_length, want, 1.0 - exp(-6.0 * delta))
