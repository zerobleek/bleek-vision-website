extends Node
## XP + progression (M2). Turns the player's landing events into experience
## using the earning rules from docs/jump-program/PLAN.md §3: airtime and
## distance pay base XP, first-ever landings on a surface pay the exploration
## bonus, precision surfaces pay every clean landing, chained jumps multiply,
## heavy/knockdown landings break the chain. Tiers gate player abilities.

signal xp_gained(amount: int, total: int, mult: float)
signal chain_changed(chain: int)
signal tier_up(tier: int, tier_name: String, unlock_text: String)

const TIER_THRESHOLDS: Array[int] = [0, 150, 500]
const TIER_NAMES: Array[String] = ["GROUNDED", "LIFT", "MOMENTUM"]
const TIER_UNLOCKS: Array[String] = [
	"",
	"CHARGED JUMP — hold to aim, release to fly",
	"DOUBLE JUMP · WALL JUMP · ROLL (arriving in M3)",
]
## Chain survives if the next takeoff happens within this many seconds grounded.
const CHAIN_WINDOW := 1.5
const NEW_SURFACE_BONUS := 25.0
const PRECISION_BONUS := 15.0
const XP_PER_METER := 2.0
const XP_PER_AIR_SECOND := 6.0
const XP_PER_RECORD_METER := 2.0
const SAVE_PATH := "user://save.json"

@export var player_path: NodePath

var xp := 0
var chain := 0
var best_altitude := 0.0
var visited := {}

var _player: Player
var _grounded_at_ms := 0


func _ready() -> void:
	_player = get_node(player_path)
	_player.landed.connect(_on_landed)
	_player.took_off.connect(_on_took_off)
	_load()
	_player.player_tier = tier()


func tier() -> int:
	var t := 0
	for i in TIER_THRESHOLDS.size():
		if xp >= TIER_THRESHOLDS[i]:
			t = i
	return t


## XP needed for the next tier, or -1 when maxed out.
func next_threshold() -> int:
	var t := tier()
	return TIER_THRESHOLDS[t + 1] if t + 1 < TIER_THRESHOLDS.size() else -1


func multiplier() -> float:
	return 1.0 + 0.1 * mini(maxi(chain - 1, 0), 10)


func _on_took_off() -> void:
	if Time.get_ticks_msec() - _grounded_at_ms > CHAIN_WINDOW * 1000.0:
		_set_chain(0)


func _on_landed(
	surface: Node, _drop: float, kind: StringName, airtime: float, distance: float
) -> void:
	_grounded_at_ms = Time.get_ticks_msec()
	if kind == &"knockdown":
		_set_chain(0)
		return
	_set_chain(0 if kind == &"heavy" else chain + 1)

	var base := XP_PER_METER * distance + XP_PER_AIR_SECOND * airtime
	var bonus := 0.0
	var sid := str(surface.get(&"surface_id"))
	if sid != "" and not visited.has(sid):
		visited[sid] = true
		bonus += NEW_SURFACE_BONUS
	if bool(surface.get(&"precision")):
		bonus += PRECISION_BONUS
	if _player.max_altitude > best_altitude + 0.5:
		bonus += XP_PER_RECORD_METER * (_player.max_altitude - best_altitude)
		best_altitude = _player.max_altitude

	var prev_tier := tier()
	var amount := maxi(int(round((base + bonus) * multiplier())), 1)
	xp += amount
	xp_gained.emit(amount, xp, multiplier())
	if tier() > prev_tier:
		_player.player_tier = tier()
		tier_up.emit(tier(), TIER_NAMES[tier()], TIER_UNLOCKS[tier()])
	_save()


func _set_chain(v: int) -> void:
	if v != chain:
		chain = v
		chain_changed.emit(chain)


func _save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({
			"xp": xp,
			"best_altitude": best_altitude,
			"visited": visited.keys(),
		}))


func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var data: Variant = JSON.parse_string(f.get_as_text())
	if data is Dictionary:
		xp = int(data.get("xp", 0))
		best_altitude = float(data.get("best_altitude", 0.0))
		for sid in data.get("visited", []):
			visited[str(sid)] = true
