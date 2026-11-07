extends StaticBody2D

var _alarm_timer: float = 0.0

func _ready() -> void:
	add_to_group("lecturer_car")

func on_bumped(_force: float = 80.0) -> void:
	_alarm_timer = 2.0
	AudioManager.play_sfx("horn", 0.72, 0.78, -2.0)

func _process(delta: float) -> void:
	if _alarm_timer > 0.0:
		_alarm_timer = maxf(0.0, _alarm_timer - delta)
		queue_redraw()

func _draw() -> void:
	if _alarm_timer > 0.0 and int(_alarm_timer * 8.0) % 2 == 0:
		draw_circle(Vector2(-24, -72), 8.0, Color(1.0, 0.85, 0.2, 0.85))
		draw_circle(Vector2(24, -72), 8.0, Color(1.0, 0.85, 0.2, 0.85))
