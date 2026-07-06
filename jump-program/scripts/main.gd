extends Node3D
## M0 glue. Landing events print for now; the XP system takes this
## signal over in M2, telemetry logging in M3.

@onready var _player: Player = $Player


func _ready() -> void:
	_player.landed.connect(_on_player_landed)


func _on_player_landed(surface: Node, fall_speed: float) -> void:
	print("landed on %s (fall %.1f m/s)" % [surface.get(&"surface_id"), absf(fall_speed)])
