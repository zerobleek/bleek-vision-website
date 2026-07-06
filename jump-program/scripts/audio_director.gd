extends Node
## Plays SFX off player/XP signals and loops the music track.
## All audio is procedurally generated placeholder (assets/audio/) —
## real sound design replaces the files, not this code.

const SFX := {
	&"tap": "res://assets/audio/jump.wav",
	&"charged": "res://assets/audio/jump_charged.wav",
	&"air": "res://assets/audio/jump_air.wav",
	&"wall": "res://assets/audio/jump_wall.wav",
	&"clean": "res://assets/audio/land_clean.wav",
	&"roll": "res://assets/audio/land_roll.wav",
	&"heavy": "res://assets/audio/land_heavy.wav",
	&"knockdown": "res://assets/audio/knockdown.wav",
	&"grab": "res://assets/audio/grab.wav",
	&"chain": "res://assets/audio/chain.wav",
	&"tier_up": "res://assets/audio/tier_up.wav",
}
const MUSIC := "res://assets/audio/music_loop.wav"

@export var player_path: NodePath
@export var xp_path: NodePath

var _sfx := {}
var _music: AudioStreamPlayer


func _ready() -> void:
	for key: StringName in SFX:
		if not ResourceLoader.exists(SFX[key]):
			continue
		var p := AudioStreamPlayer.new()
		p.stream = load(SFX[key])
		p.max_polyphony = 3
		add_child(p)
		_sfx[key] = p

	if ResourceLoader.exists(MUSIC):
		_music = AudioStreamPlayer.new()
		_music.stream = load(MUSIC)
		_music.volume_db = -8.0
		_music.finished.connect(_music.play)
		add_child(_music)
		_music.play()

	var player: Player = get_node(player_path)
	player.jumped.connect(_play)
	player.grabbed.connect(_play.bind(&"grab"))
	player.landed.connect(_on_landed)
	var xp := get_node(xp_path)
	xp.tier_up.connect(func(_t: int, _n: String, _u: String) -> void: _play(&"tier_up"))
	xp.chain_changed.connect(_on_chain)


func _play(key: StringName) -> void:
	if _sfx.has(key):
		_sfx[key].play()


func _on_landed(
	_surface: Node, _drop: float, kind: StringName, airtime: float, _distance: float
) -> void:
	if kind == &"clean" and airtime < 0.15:
		return
	_play(kind)


func _on_chain(chain: int) -> void:
	if chain >= 2 and _sfx.has(&"chain"):
		_sfx[&"chain"].pitch_scale = 1.0 + 0.06 * mini(chain, 10)
		_sfx[&"chain"].play()
