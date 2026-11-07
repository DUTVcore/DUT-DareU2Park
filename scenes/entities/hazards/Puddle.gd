extends Area2D

@export var hides_pothole: bool = false
@export var pothole_severity: float = 7.5

var _ripple_time: float = -1.0
var _tracked_body = null
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if sprite:
		var p := "res://assets/sprites/environment/puddle_deep.png" if hides_pothole else "res://assets/sprites/environment/puddle.png"
		if ResourceLoader.exists(p):
			sprite.texture = load(p)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body) -> void:
	if body == null or not body.is_in_group("player_bike"):
		return
	_tracked_body = body
	_ripple_time = 0.0
	AudioManager.play_sfx("splash", 0.92, 1.08, -2.5)
	if body.has_method("apply_wet_surface"):
		body.apply_wet_surface(2.6)
	if hides_pothole and body.has_method("hit_pothole"):
		FloatingText.spawn(get_parent(), global_position + Vector2(0, -24), "ÙM! Ổ voi ngầm dưới vũng nước!", Color("#F59E0B"))
		body.hit_pothole(pothole_severity)

func _on_body_exited(body) -> void:
	if body == _tracked_body:
		_tracked_body = null

func _process(delta: float) -> void:
	if _tracked_body != null and is_instance_valid(_tracked_body) and _tracked_body.has_method("apply_wet_surface"):
		_tracked_body.apply_wet_surface(1.6)
	if _ripple_time >= 0.0:
		_ripple_time += delta
		if _ripple_time > 0.75:
			_ripple_time = -1.0
		queue_redraw()

func _draw() -> void:
	if _ripple_time >= 0.0:
		var t := clampf(_ripple_time / 0.75, 0.0, 1.0)
		draw_arc(Vector2.ZERO, lerpf(10.0, 44.0, t), 0.0, TAU, 28, Color(0.85, 0.95, 1.0, (1.0 - t) * 0.8), 2.2)
