extends Node
## M3 playtest telemetry: one JSON line per landing, one file per session,
## written to user://. The M3 exit review is a landing heatmap over these —
## dead surfaces get moved or deleted, hot accidental routes get promoted.

@export var player_path: NodePath
@export var xp_path: NodePath

var _file: FileAccess
var _player: Player
var _xp: Node


func _ready() -> void:
	_player = get_node(player_path)
	_xp = get_node(xp_path)
	_player.landed.connect(_on_landed)
	var stamp := Time.get_datetime_string_from_system().replace(":", "-")
	_file = FileAccess.open("user://landings_%s.jsonl" % stamp, FileAccess.WRITE)


func _on_landed(
	surface: Node, drop: float, kind: StringName, airtime: float, distance: float
) -> void:
	if _file == null:
		return
	_file.store_line(JSON.stringify({
		"t_ms": Time.get_ticks_msec(),
		"surface": str(surface.get(&"surface_id")),
		"kind": String(kind),
		"y": snappedf(_player.global_position.y, 0.01),
		"drop": snappedf(drop, 0.01),
		"air": snappedf(airtime, 0.01),
		"dist": snappedf(distance, 0.01),
		"chain": _xp.chain,
		"tier": _xp.tier(),
		"xp": _xp.xp,
	}))
	_file.flush()
