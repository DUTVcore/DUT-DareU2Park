extends Camera2D

var _shake_strength: float = 0.0
var _shake_decay: float = 14.0
var _lookahead: Vector2 = Vector2.ZERO

func _ready() -> void:
	zoom = Vector2(1.22, 1.22)
	position_smoothing_enabled = true
	position_smoothing_speed = 7.5

func shake(severity: float) -> void:
	_shake_strength = maxf(_shake_strength, clampf(severity, 1.0, 22.0))

func update_lookahead(vel: Vector2, delta: float) -> void:
	var target := vel.limit_length(240.0) * 0.24
	_lookahead = _lookahead.lerp(target, clampf(delta * 4.5, 0.0, 1.0))

func _process(delta: float) -> void:
	var jitter := Vector2.ZERO
	if _shake_strength > 0.1:
		jitter = Vector2(
			randf_range(-_shake_strength, _shake_strength),
			randf_range(-_shake_strength, _shake_strength)
		)
		_shake_strength = move_toward(_shake_strength, 0.0, _shake_decay * delta)
	else:
		_shake_strength = 0.0
	offset = _lookahead + jitter
