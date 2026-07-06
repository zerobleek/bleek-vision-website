extends CanvasLayer
## Player-facing XP HUD (the debug HUD stays separate and dev-only):
## XP bar toward the next tier (top right), chain multiplier while a chain
## is alive, floating "+N" popups per landing, and a tier-up banner.

const BAR_W := 220.0
const BAR_H := 8.0

@export var xp_path: NodePath

var _xp: Node
var _xp_label: Label
var _bar_bg: ColorRect
var _bar_fill: ColorRect
var _chain_label: Label
var _popup: Label
var _banner: Label
var _banner_sub: Label


func _ready() -> void:
	_xp = get_node(xp_path)
	_xp.xp_gained.connect(_on_xp_gained)
	_xp.chain_changed.connect(_on_chain_changed)
	_xp.tier_up.connect(_on_tier_up)
	_build()
	_refresh(int(_xp.xp))


func _build() -> void:
	_xp_label = _label(Vector2.ZERO, 16)
	_xp_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_xp_label.position = Vector2(-BAR_W - 24, 12)

	_bar_bg = ColorRect.new()
	_bar_bg.color = Color(1, 1, 1, 0.15)
	_bar_bg.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_bar_bg.position = Vector2(-BAR_W - 24, 36)
	_bar_bg.size = Vector2(BAR_W, BAR_H)
	add_child(_bar_bg)
	_bar_fill = ColorRect.new()
	_bar_fill.color = Color(0.54, 0.63, 0.76)
	_bar_fill.size = Vector2(0, BAR_H)
	_bar_bg.add_child(_bar_fill)

	_chain_label = _label(Vector2.ZERO, 22)
	_chain_label.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	_chain_label.position = Vector2(-140, -60)
	_chain_label.visible = false

	_popup = _label(Vector2.ZERO, 18)
	_popup.set_anchors_preset(Control.PRESET_CENTER)
	_popup.modulate.a = 0.0

	_banner = _label(Vector2.ZERO, 34)
	_banner.set_anchors_preset(Control.PRESET_CENTER)
	_banner.position = Vector2(-160, -120)
	_banner.modulate.a = 0.0
	_banner_sub = _label(Vector2.ZERO, 16)
	_banner_sub.set_anchors_preset(Control.PRESET_CENTER)
	_banner_sub.position = Vector2(-160, -76)
	_banner_sub.modulate.a = 0.0


func _label(pos: Vector2, size: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override(&"font_size", size)
	l.add_theme_color_override(&"font_color", Color(1, 1, 1, 0.92))
	l.add_theme_color_override(&"font_shadow_color", Color(0, 0, 0, 0.7))
	l.add_theme_constant_override(&"shadow_offset_x", 1)
	l.add_theme_constant_override(&"shadow_offset_y", 1)
	add_child(l)
	return l


func _refresh(total: int) -> void:
	var next: int = _xp.next_threshold()
	var t: int = _xp.tier()
	if next < 0:
		_xp_label.text = "T%d  %d XP" % [t, total]
		_bar_fill.size.x = BAR_W
	else:
		_xp_label.text = "T%d  %d / %d XP" % [t, total, next]
		var floor_xp: int = _xp.TIER_THRESHOLDS[t]
		var frac := float(total - floor_xp) / float(next - floor_xp)
		_bar_fill.size.x = BAR_W * clampf(frac, 0.0, 1.0)


func _on_xp_gained(amount: int, total: int, mult: float) -> void:
	_refresh(total)
	_popup.text = "+%d" % amount if mult <= 1.05 else "+%d  ×%.1f" % [amount, mult]
	_popup.position = Vector2(-30, 40)
	var tw := create_tween()
	_popup.modulate.a = 1.0
	tw.tween_property(_popup, "position:y", 10.0, 0.6)
	tw.parallel().tween_property(_popup, "modulate:a", 0.0, 0.6).set_delay(0.2)


func _on_chain_changed(chain: int) -> void:
	_chain_label.visible = chain >= 2
	if chain >= 2:
		_chain_label.text = "CHAIN %d  ×%.1f" % [chain, _xp.multiplier()]


func _on_tier_up(tier: int, tier_name: String, unlock_text: String) -> void:
	_banner.text = "TIER %d — %s" % [tier, tier_name]
	_banner_sub.text = unlock_text
	var tw := create_tween()
	_banner.modulate.a = 0.0
	_banner_sub.modulate.a = 0.0
	tw.tween_property(_banner, "modulate:a", 1.0, 0.25)
	tw.parallel().tween_property(_banner_sub, "modulate:a", 1.0, 0.25).set_delay(0.15)
	tw.tween_interval(2.6)
	tw.tween_property(_banner, "modulate:a", 0.0, 0.5)
	tw.parallel().tween_property(_banner_sub, "modulate:a", 0.0, 0.5)
