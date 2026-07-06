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

## surface_id substring -> [texture, world-units per tile]. First match wins,
## so specific parts (fire escapes, antennas) come before their buildings.
const TEXTURE_RULES: Array = [
	["street", "asphalt", 3.0],
	["pole", "metal", 2.0], ["rail", "metal", 2.0], ["fe_", "metal", 2.0],
	["dumpster", "metal", 2.0], ["van", "metal", 2.0], ["machinery", "metal", 2.0],
	["catwalk", "metal", 2.0], ["billboard", "metal", 2.0], ["antenna", "metal", 2.0],
	["awning", "metal", 2.0], ["canopy", "metal", 2.0], ["sign", "metal", 2.0],
	["ac_", "metal", 2.0], ["stairbox", "concrete", 2.0],
	["table", "wood", 2.0], ["crate", "wood", 2.0],
	["balcony", "concrete", 2.0], ["shelf", "concrete", 2.0],
	["ledge", "concrete", 2.0], ["planter", "concrete", 2.0],
	["bodega", "brick", 2.0], ["walkup", "brick", 2.0],
	["mid", "windows", 3.4], ["tower", "windows", 3.4],
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
	var m := _mesh.material_override as StandardMaterial3D
	var tier_c := TIER_COLORS[clampi(tier, 0, TIER_COLORS.size() - 1)]
	var sid := String(surface_id)
	var tex_path := ""
	var tile := 2.0
	for rule in TEXTURE_RULES:
		if sid.contains(rule[0]):
			tex_path = "res://assets/textures/%s.png" % rule[1]
			tile = rule[2]
			break
	if tex_path == "" or not ResourceLoader.exists(tex_path):
		m.albedo_color = tier_c.lerp(Color.WHITE, 0.45) if precision else tier_c
		return
	m.albedo_texture = load(tex_path)
	m.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	m.uv1_triplanar = true
	m.uv1_world_triplanar = true
	m.uv1_scale = Vector3.ONE / tile
	# Faint tier tint keeps route legibility on top of the textures;
	# the Tower stays hard red, precision surfaces read brighter.
	var tint_amt := 0.5 if tier >= TIER_COLORS.size() - 1 else 0.16
	m.albedo_color = Color.WHITE.lerp(tier_c, tint_amt)
	if precision:
		m.albedo_color = m.albedo_color.lightened(0.25)
