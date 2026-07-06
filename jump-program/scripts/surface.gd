@tool
extends StaticBody3D
## Greybox landing surface. Builds its own box mesh + collision from `size`,
## color-coded by intended tier. One instance per entry in
## docs/jump-program/GREYBOX_BLOCK.md §5. Node position = box CENTER.

const TIER_COLORS: Array[Color] = [
	Color(0.55, 0.55, 0.58),  # T0 gray
	Color(0.35, 0.55, 0.85),  # T1 blue
	Color(0.95, 0.60, 0.25),  # T2 orange
	Color(0.90, 0.30, 0.30),  # out of bounds red
]

@export var surface_id: StringName = &"":
	set(v):
		surface_id = v
		if is_inside_tree():
			name = String(v).to_pascal_case() if v != &"" else name
@export var tier := 0:
	set(v):
		tier = v
		_refresh_color()
@export var precision := false:
	set(v):
		precision = v
		_refresh_color()
@export var size := Vector3(2, 1, 2):
	set(v):
		size = v
		_refresh()

var _mesh: MeshInstance3D
var _shape: CollisionShape3D


func _ready() -> void:
	if not Engine.is_editor_hint():
		add_to_group(&"landable")
	_refresh()


func _refresh() -> void:
	if not is_inside_tree():
		return
	if _mesh == null:
		_mesh = MeshInstance3D.new()
		_mesh.mesh = BoxMesh.new()
		_mesh.material_override = StandardMaterial3D.new()
		add_child(_mesh)
		_shape = CollisionShape3D.new()
		_shape.shape = BoxShape3D.new()
		add_child(_shape)
	(_mesh.mesh as BoxMesh).size = size
	(_shape.shape as BoxShape3D).size = size
	_refresh_color()


func _refresh_color() -> void:
	if _mesh == null:
		return
	var c := TIER_COLORS[clampi(tier, 0, TIER_COLORS.size() - 1)]
	if precision:
		c = c.lerp(Color.WHITE, 0.45)
	(_mesh.material_override as StandardMaterial3D).albedo_color = c
