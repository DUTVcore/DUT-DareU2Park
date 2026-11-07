extends Node

var is_muted: bool = false
var _sfx_streams: Dictionary = {}
var _bgm_streams: Dictionary = {}
var _sfx_pool: Array[AudioStreamPlayer] = []
var _bgm_player: AudioStreamPlayer
var _engine_player: AudioStreamPlayer
var _current_bgm_key: String = ""

const SFX_PATHS := {
	"card_beep": "res://assets/audio/sfx/sfx_card_beep.wav",
	"horn": "res://assets/audio/sfx/sfx_horn.wav",
	"mirror": "res://assets/audio/sfx/sfx_mirror.wav",
	"kickstand": "res://assets/audio/sfx/sfx_kickstand.wav",
	"scrape": "res://assets/audio/sfx/sfx_scrape.wav",
	"crash": "res://assets/audio/sfx/sfx_crash.wav",
	"pothole": "res://assets/audio/sfx/sfx_pothole.wav",
	"splash": "res://assets/audio/sfx/sfx_splash.wav",
	"click": "res://assets/audio/sfx/sfx_click.wav",
	"win": "res://assets/audio/sfx/sfx_win.wav",
	"fail": "res://assets/audio/sfx/sfx_fail.wav",
	"engine": "res://assets/audio/sfx/sfx_engine.wav",
}

const BGM_PATHS := {
	"menu": "res://assets/audio/bgm/bgm_menu.wav",
	"gameplay": "res://assets/audio/bgm/bgm_gameplay.wav",
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	for key in SFX_PATHS.keys():
		var p: String = SFX_PATHS[key]
		if ResourceLoader.exists(p):
			var s := load(p)
			if s is AudioStreamWAV and key == "engine":
				_enable_wav_loop(s as AudioStreamWAV)
			_sfx_streams[key] = s

	for key in BGM_PATHS.keys():
		var p: String = BGM_PATHS[key]
		if ResourceLoader.exists(p):
			var s := load(p)
			if s is AudioStreamWAV:
				_enable_wav_loop(s as AudioStreamWAV)
			_bgm_streams[key] = s

	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.volume_db = -9.0
	add_child(_bgm_player)

	_engine_player = AudioStreamPlayer.new()
	_engine_player.volume_db = -14.0
	if _sfx_streams.has("engine"):
		_engine_player.stream = _sfx_streams["engine"]
	add_child(_engine_player)

	for i in range(8):
		var p := AudioStreamPlayer.new()
		add_child(p)
		_sfx_pool.append(p)

func _enable_wav_loop(wav: AudioStreamWAV) -> void:
	if wav == null:
		return
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	wav.loop_begin = 0
	var bytes_per_sample := 2 if wav.format == AudioStreamWAV.FORMAT_16_BITS else 1
	if wav.stereo:
		bytes_per_sample *= 2
	if bytes_per_sample > 0 and wav.data.size() > 0:
		wav.loop_end = int(wav.data.size() / bytes_per_sample)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_mute"):
		toggle_mute()

func toggle_mute() -> bool:
	is_muted = not is_muted
	var master_idx := AudioServer.get_bus_index("Master")
	if master_idx >= 0:
		AudioServer.set_bus_mute(master_idx, is_muted)
	if is_muted:
		stop_engine()
	return is_muted

func play_bgm(key: String) -> void:
	if _current_bgm_key == key and _bgm_player.playing:
		return
	_current_bgm_key = key
	if not _bgm_streams.has(key):
		_bgm_player.stop()
		return
	_bgm_player.stream = _bgm_streams[key]
	if not is_muted:
		_bgm_player.play()

func stop_bgm() -> void:
	_current_bgm_key = ""
	_bgm_player.stop()

func play_sfx(key: String, pitch_min: float = 0.96, pitch_max: float = 1.04, volume_db: float = -3.0) -> void:
	if is_muted or not _sfx_streams.has(key):
		return
	for player in _sfx_pool:
		if not player.playing:
			player.stream = _sfx_streams[key]
			player.pitch_scale = randf_range(pitch_min, pitch_max)
			player.volume_db = volume_db
			player.play()
			return
	var fallback := _sfx_pool[0]
	fallback.stream = _sfx_streams[key]
	fallback.pitch_scale = randf_range(pitch_min, pitch_max)
	fallback.volume_db = volume_db
	fallback.play()

func update_engine(speed_ratio: float, active: bool) -> void:
	if is_muted or not active or get_tree().paused or not _sfx_streams.has("engine"):
		if _engine_player.playing:
			_engine_player.stop()
		return
	if not _engine_player.playing:
		_engine_player.play()
	_engine_player.pitch_scale = lerpf(0.85, 1.95, clampf(speed_ratio, 0.0, 1.0))
	_engine_player.volume_db = lerpf(-16.0, -9.5, clampf(speed_ratio, 0.0, 1.0))

func stop_engine() -> void:
	if _engine_player != null and _engine_player.playing:
		_engine_player.stop()
