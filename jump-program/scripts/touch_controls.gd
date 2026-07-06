extends CanvasLayer
## Touch input (autoload). Left half: floating virtual stick.
## Right half: tap/hold = jump, drag = camera orbit.
## Desktop testing works through emulate_touch_from_mouse.

const STICK_RADIUS := 96.0

var move_vector := Vector2.ZERO
var jump_held := false
var camera_delta := Vector2.ZERO

var _stick_index := -1
var _stick_origin := Vector2.ZERO
var _stick_pos := Vector2.ZERO
var _right_index := -1
var _jump_queued := false
var _overlay: Control


func _ready() -> void:
	layer = 10
	_overlay = Control.new()
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.draw.connect(_draw_stick)
	add_child(_overlay)


func consume_jump() -> bool:
	var q := _jump_queued
	_jump_queued = false
	return q


func _process(_delta: float) -> void:
	_overlay.queue_redraw()


func _input(event: InputEvent) -> void:
	var half_w := _overlay.size.x * 0.5
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < half_w and _stick_index == -1:
				_stick_index = event.index
				_stick_origin = event.position
				_stick_pos = event.position
			elif event.position.x >= half_w and _right_index == -1:
				_right_index = event.index
				_jump_queued = true
				jump_held = true
		else:
			if event.index == _stick_index:
				_stick_index = -1
				move_vector = Vector2.ZERO
			elif event.index == _right_index:
				_right_index = -1
				jump_held = false
	elif event is InputEventScreenDrag:
		if event.index == _stick_index:
			_stick_pos = event.position
			var v: Vector2 = (event.position - _stick_origin) / STICK_RADIUS
			move_vector = v.limit_length(1.0)
		elif event.index == _right_index:
			camera_delta += event.relative


func _draw_stick() -> void:
	if _stick_index == -1:
		return
	_overlay.draw_circle(_stick_origin, STICK_RADIUS, Color(1, 1, 1, 0.08))
	_overlay.draw_arc(_stick_origin, STICK_RADIUS, 0.0, TAU, 48, Color(1, 1, 1, 0.25), 2.0)
	var knob := _stick_origin + move_vector * STICK_RADIUS
	_overlay.draw_circle(knob, 28.0, Color(1, 1, 1, 0.35))
