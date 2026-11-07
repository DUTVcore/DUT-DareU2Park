extends Area2D

@export var severity: float = 6.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body) -> void:
	if body != null and body.is_in_group("player_bike") and body.has_method("hit_pothole"):
		body.hit_pothole(severity)
