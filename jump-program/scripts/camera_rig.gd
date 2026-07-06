extends Node3D
## Follow-orbit camera. Yaw lives on this rig, pitch on the SpringArm3D.
## Orbit comes from right-half touch drags (TouchControls.camera_delta).

@export var target_path: NodePath
@export var follow_speed := 8.0
@export var sensitivity := 0.005
@export var pitch_min := -70.0
@export var pitch_max := 30.0

var _target: Node3D

@onready var _arm: SpringArm3D = $Arm


func _ready() -> void:
	add_to_group(&"camera_rig")
	_target = get_node_or_null(target_path)
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
