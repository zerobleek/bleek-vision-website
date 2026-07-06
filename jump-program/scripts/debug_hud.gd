extends CanvasLayer
## M0 tuning readout. Reads the player directly; no game logic here.

@export var player_path: NodePath

var _label: Label
var _player: Player


func _ready() -> void:
	_player = get_node_or_null(player_path)
	_label = Label.new()
	_label.position = Vector2(12, 12)
	_label.add_theme_color_override(&"font_color", Color(1, 1, 1, 0.9))
	_label.add_theme_color_override(&"font_shadow_color", Color(0, 0, 0, 0.7))
	_label.add_theme_constant_override(&"shadow_offset_x", 1)
	_label.add_theme_constant_override(&"shadow_offset_y", 1)
	add_child(_label)


func _process(_delta: float) -> void:
	if _player == null:
		return
	var flat := Vector2(_player.velocity.x, _player.velocity.z).length()
	_label.text = (
		"speed  %5.2f m/s\n" % flat
		+ "v.y    %5.2f m/s\n" % _player.velocity.y
		+ "alt    %5.2f m   (best %.2f)\n" % [_player.global_position.y, _player.max_altitude]
		+ "floor  %s   coyote %.2f   buffer %.2f\n"
			% [_player.is_on_floor(), _player.coyote_left, _player.buffer_left]
		+ "landed %s\n" % _player.last_landing
		+ "jump: apex %.2f m, t_apex %.2f s  [R] reset" % [_player.jump_height, _player.time_to_apex]
	)
