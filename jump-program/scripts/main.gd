extends Node3D
## M0 glue. Landing events print for now; the XP system takes this
## signal over in M2, telemetry logging in M3.

@onready var _player: Player = $Player


func _ready() -> void:
	_player.landed.connect(_on_player_landed)


func _on_player_landed(
	surface: Node, drop: float, kind: StringName, airtime: float, distance: float
) -> void:
	print("landed on %s (%s, drop %.1f m, air %.2f s, dist %.1f m)"
		% [surface.get(&"surface_id"), kind, drop, airtime, distance])
