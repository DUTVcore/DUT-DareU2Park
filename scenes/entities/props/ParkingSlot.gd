extends Area2D

@export var slot_width: float = 42.0
@export var slot_length: float = 86.0
@export var max_offset_px: float = 19.0
@export var max_angle_deg: float = 17.5
@export var slot_label: String = "Ô TRỐNG"

var _pulse: float = 0.0
var _tracked_bike: Node2D = null
var last_eval: Dictionary = {}

func _ready() -> void:
	add_to_group("parking_slot")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player_bike"):
		_tracked_bike = body

func _on_body_exited(body: Node2D) -> void:
	if body == _tracked_bike:
		_tracked_bike = null
		last_eval = {}

func evaluate_bike(bike: Node2D) -> Dictionary:
	if bike == null or not is_instance_valid(bike):
		return {"ready": false, "reason": "Không tìm thấy xe!"}

	var local_pos := to_local(bike.global_position)
	var lateral_err := absf(local_pos.x)
	var long_err := absf(local_pos.y)
	var dist := local_pos.length()
	var in_bounds := (lateral_err <= max_offset_px * 0.85) and (long_err <= max_offset_px * 1.15)

	var angle_diff_rad := absf(angle_difference(bike.global_rotation, global_rotation))
	var angle_deg := rad_to_deg(angle_diff_rad)
	var angle_ok := angle_deg <= max_angle_deg

	var spd: float = absf(float(bike.get("current_speed")))
	var speed_ok := spd <= 22.0

	var ready := in_bounds and angle_ok and speed_ok
	var reason := "CHUẨN GÓC! Bấm [SPACE] gạt chân chống!"
	if not in_bounds:
		if dist > 65.0:
			reason = "Chưa vào ô đỗ trống! Chạy theo mũi tên vàng trên HUD!"
		else:
			reason = "Đưa xe lọt hẳn vào giữa vạch sơn ô đỗ!"
	elif not angle_ok:
		if angle_deg > 115.0:
			reason = "Ngược đầu xe rồi! Quay đầu xe theo đúng chiều mũi tên!"
		else:
			reason = "Xe còn xéo góc (%d°)! Đánh lái thẳng dưới %d°!" % [int(round(angle_deg)), int(max_angle_deg)]
	elif not speed_ok:
		reason = "Phanh xe dừng hẳn lại rồi mới gạt chân chống!"

	var result := {
		"ready": ready,
		"in_bounds": in_bounds,
		"angle_ok": angle_ok,
		"speed_ok": speed_ok,
		"angle_deg": angle_deg,
		"dist": dist,
		"reason": reason,
	}
	last_eval = result
	return result

func _process(delta: float) -> void:
	_pulse += delta * 4.2
	if _tracked_bike != null and is_instance_valid(_tracked_bike):
		evaluate_bike(_tracked_bike)
	queue_redraw()

func _draw() -> void:
	var hw := slot_width * 0.5
	var hl := slot_length * 0.5
	var pulse_alpha := 0.55 + 0.30 * sin(_pulse)

	var state_col := Color(0.96, 0.72, 0.05, pulse_alpha) # Gold default
	var fill_col := Color(0.96, 0.72, 0.05, 0.14 + 0.06 * sin(_pulse))

	if _tracked_bike != null and not last_eval.is_empty():
		if bool(last_eval.get("ready", false)):
			state_col = Color(0.15, 0.92, 0.45, 0.95)
			fill_col = Color(0.15, 0.92, 0.45, 0.28)
		else:
			state_col = Color(0.98, 0.58, 0.12, 0.90)
			fill_col = Color(0.98, 0.58, 0.12, 0.18)

	# Glowing floor rectangle
	draw_rect(Rect2(-hw, -hl, slot_width, slot_length), fill_col, true)

	# Painted bay lines (left, right, front stopper)
	draw_line(Vector2(-hw, -hl), Vector2(-hw, hl), state_col, 3.0)
	draw_line(Vector2(hw, -hl), Vector2(hw, hl), state_col, 3.0)
	draw_line(Vector2(-hw, -hl), Vector2(hw, -hl), state_col, 3.5)

	# Animated directional arrow pointing UP (-Y in local space = desired front wheel direction!)
	var bob := sin(_pulse * 1.4) * 4.0
	var arrow_col := Color(1.0, 1.0, 1.0, 0.85)
	draw_line(Vector2(0, 18 + bob), Vector2(0, -22 + bob), arrow_col, 3.2)
	var head := PackedVector2Array([
		Vector2(0, -30 + bob),
		Vector2(-10, -16 + bob),
		Vector2(10, -16 + bob),
	])
	draw_colored_polygon(head, arrow_col)

	# Label above slot
	var fnt := DUTTheme.get_bold_font()
	draw_string(fnt, Vector2(-38, hl + 18), slot_label, HORIZONTAL_ALIGNMENT_CENTER, 76, 12, state_col)
