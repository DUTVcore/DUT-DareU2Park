extends CharacterBody2D

# Operating parameters
@export var acceleration: float = 400.0       # Forward acceleration
@export var max_speed: float = 250.0          # Maximum speed in the area
@export var reverse_speed: float = 70.0       # Reverse speed
@export var friction: float = 250.0           # Coasting friction when throttle is released
@export var steer_speed: float = 3.5          # Steering speed

# Bike state
var current_speed: float = 0.0
var steering_input: float = 0.0
var is_stunned: bool = false                  # Stunned when hitting a deep pothole

func _physics_process(delta: float) -> void:
	if is_stunned:
		return

	_handle_input(delta)
	_apply_movement(delta)

func _handle_input(delta: float) -> void:
	# 1. Throttle and reverse (W/S or Up/Down)
	var throttle = Input.get_axis("ui_down", "ui_up")
	if throttle > 0:
		current_speed = move_toward(current_speed, max_speed, acceleration * delta)
	elif throttle < 0:
		current_speed = move_toward(current_speed, -reverse_speed, acceleration * delta)
	else:
		current_speed = move_toward(current_speed, 0.0, friction * delta)

	# 2. Steering (A/D or Left/Right)
	# The bike must be moving to steer directionally
	steering_input = Input.get_axis("ui_left", "ui_right")
	if abs(current_speed) > 10.0:
		var direction_modifier = 1.0 if current_speed >= 0 else -1.0
		# Turning is sharper at low speed than at high speed
		var dynamic_steer = steer_speed * (1.0 - (abs(current_speed) / (max_speed * 1.5)))
		rotation += steering_input * dynamic_steer * delta * direction_modifier

func _apply_movement(delta: float) -> void:
	# Direction vector based on the bike's rotation
	var forward_vector = Vector2.UP.rotated(rotation)
	velocity = forward_vector * current_speed
	
	# Move and handle slight slide/contact friction
	move_and_slide()
	
	# If it crashes head-on into a hard wall, brake speed to 0
	if get_slide_collision_count() > 0:
		current_speed = move_toward(current_speed, 0.0, friction * 2 * delta)

# Triggered when driving over a pothole / bump (called from the pothole Area2D signal)
func hit_pothole(severity: float) -> void:
	# Sudden speed reduction
	current_speed *= 0.3
	
	# Apply a random steering angle wobble from -25° to +25°
	var wrench_angle = deg_to_rad(randf_range(-25.0, 25.0))
	rotation += wrench_angle
	
	# Camera shake (screen shake)
	if has_node("Camera2D") and get_node("Camera2D").has_method("shake"):
		get_node("Camera2D").shake(severity)