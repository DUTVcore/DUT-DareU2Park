extends StaticBody2D

const VARIANTS := [
	"res://assets/sprites/vehicles/parked_wave_blue.png",
	"res://assets/sprites/vehicles/parked_wave_red.png",
	"res://assets/sprites/vehicles/parked_exciter_gp.png",
	"res://assets/sprites/vehicles/parked_vision_white.png",
	"res://assets/sprites/vehicles/parked_sh_black.png",
	"res://assets/sprites/vehicles/parked_wave_silver.png",
]

const PLATES := ["43-F1", "92-N1", "75-K1", "74-C1", "73-B1", "76-E1", "77-L1", "43-D1"]

@export var variant_index: int = -1
@export var has_alarm: bool = false

var _wobble_time: float = 0.0
var _alarm_flash: float = 0.0
var _plate_code: String = "43-F1"
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	var h := int(absf(global_position.x * 13.0 + global_position.y * 31.0))
	if variant_index < 0:
		variant_index = h % VARIANTS.size()
	else:
		variant_index = posmod(variant_index, VARIANTS.size())

	_plate_code = PLATES[h % PLATES.size()]
	if variant_index == 4: # Black SH has Smartkey alarm by default!
		has_alarm = true

	var path: String = VARIANTS[variant_index]
	if sprite and ResourceLoader.exists(path):
		sprite.texture = load(path)

func on_bumped(_force: float = 60.0) -> void:
	_wobble_time = 0.38
	if has_alarm and _alarm_flash <= 0.05:
		_alarm_flash = 1.6
		AudioManager.play_sfx("card_beep", 1.25, 1.35, -7.0)
		FloatingText.spawn(get_parent(), global_position + Vector2(0, -30), "Chít chít! Báo động xe SH (" + _plate_code + ")!", Color("#F59E0B"))

func _process(delta: float) -> void:
	if _wobble_time > 0.0:
		_wobble_time = maxf(0.0, _wobble_time - delta)
		if sprite:
			sprite.position.x = sin(_wobble_time * 52.0) * 2.5 * (_wobble_time / 0.38)
	elif sprite and sprite.position.x != 0.0:
		sprite.position.x = 0.0

	if _alarm_flash > 0.0:
		_alarm_flash = maxf(0.0, _alarm_flash - delta)
		queue_redraw()

func _draw() -> void:
	if _alarm_flash > 0.0 and int(_alarm_flash * 10.0) % 2 == 0:
		draw_circle(Vector2(-11, -24), 4.5, Color(1.0, 0.65, 0.1, 0.85))
		draw_circle(Vector2(11, -24), 4.5, Color(1.0, 0.65, 0.1, 0.85))
		draw_circle(Vector2(-9, 28), 4.5, Color(1.0, 0.35, 0.1, 0.85))
		draw_circle(Vector2(9, 28), 4.5, Color(1.0, 0.35, 0.1, 0.85))
