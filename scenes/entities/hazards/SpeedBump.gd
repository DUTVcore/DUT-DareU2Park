extends Area2D

@export var bump_severity: float = 5.5

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if body != null and body.is_in_group("player_bike") and body.has_method("hit_speed_bump"):
		body.hit_speed_bump(bump_severity)
