extends Node2D

signal card_scanned()

@export var gate_title: String = "TRẠM THẺ TỪ SV"
@export var fee_text: String = "TÍT! Thẻ SV Bách Khoa hợp lệ (-3.000đ)"

var is_open: bool = false
var _arm_angle: float = 0.0
var _led_pulse: float = 0.0

@onready var barrier_body: StaticBody2D = $BarrierBody
@onready var barrier_col: CollisionShape2D = $BarrierBody/CollisionShape2D
@onready var scan_zone: Area2D = $ScanZone

func _ready() -> void:
	add_to_group("card_gate")
	if barrier_body:
		barrier_body.add_to_group("card_barrier")
	if scan_zone:
		scan_zone.body_entered.connect(_on_scan_body_entered)

func _on_scan_body_entered(body: Node2D) -> void:
	if is_open or not body.is_in_group("player_bike"):
		return
	_open_gate(body)

func _open_gate(bike: Node2D) -> void:
	is_open = true
	if barrier_col:
		barrier_col.set_deferred("disabled", true)
	AudioManager.play_sfx("card_beep", 0.99, 1.02, -1.5)
	FloatingText.spawn(get_parent(), global_position + Vector2(0, -40), fee_text, Color("#22C55E"))
	if bike.has_signal("status_message"):
		bike.emit_signal("status_message", fee_text, Color("#22C55E"))
	card_scanned.emit()

func _process(delta: float) -> void:
	_led_pulse += delta * 5.0
	var target_deg := -86.0 if is_open else 0.0
	_arm_angle = move_toward(_arm_angle, target_deg, 240.0 * delta)
	queue_redraw()

func _draw() -> void:
	# Guard Booth on the left (-92, -32)
	draw_rect(Rect2(-118, -36, 56, 68), Color("#0A3266"), true)
	draw_rect(Rect2(-118, -36, 56, 68), Color("#38BDF8"), false, 2.5)
	draw_rect(Rect2(-110, -28, 40, 22), Color("#7DD3FC"), true) # Booth window
	# Security Guard inside booth (blue shirt + dark cap)
	draw_circle(Vector2(-90, -8), 8.0, Color("#1E3A8A"))
	draw_circle(Vector2(-90, -8), 5.5, Color("#FDE68A"))

	# RFID Reader Pillar (-52, 16)
	draw_rect(Rect2(-58, 6, 16, 20), Color("#334155"), true)
	var led_col := Color("#22C55E") if is_open else (Color("#EF4444") if sin(_led_pulse) > 0.0 else Color("#F59E0B"))
	draw_circle(Vector2(-50, 12), 4.0, led_col)

	# Scan pad zone highlight on floor before gate
	if not is_open:
		var pad_col := Color(0.22, 0.75, 0.98, 0.22 + 0.10 * sin(_led_pulse))
		draw_rect(Rect2(-42, 16, 84, 54), pad_col, true)
		draw_rect(Rect2(-42, 16, 84, 54), Color("#38BDF8"), false, 1.8)
		draw_string(DUTTheme.get_bold_font(), Vector2(-46, 48), "QUẸT THẺ TỪ", HORIZONTAL_ALIGNMENT_CENTER, 92, 11, Color("#E0F2FE"))

	# Barrier pivot post (-44, -6) + Rotating red-white barrier arm across lane (-44 -> +52)
	var pivot := Vector2(-44, -6)
	draw_rect(Rect2(-50, -14, 14, 16), Color("#F5B700"), true)

	var arm_dir := Vector2.RIGHT.rotated(deg_to_rad(_arm_angle))
	var arm_perp := arm_dir.orthogonal() * 3.5
	for seg in range(6):
		var p0 := pivot + arm_dir * (seg * 16.0)
		var p1 := pivot + arm_dir * ((seg + 1) * 16.0)
		var seg_col := Color("#EF4444") if seg % 2 == 0 else Color("#F8FAFC")
		var poly := PackedVector2Array([p0 - arm_perp, p1 - arm_perp, p1 + arm_perp, p0 + arm_perp])
		draw_colored_polygon(poly, seg_col)

	# Right side bollard (+56, -6)
	draw_circle(Vector2(56, -6), 7.0, Color("#F5B700"))
	draw_circle(Vector2(56, -6), 4.0, Color("#1E293B"))

	draw_string(DUTTheme.get_bold_font(), Vector2(-124, -44), gate_title, HORIZONTAL_ALIGNMENT_CENTER, 100, 11, Color("#F5B700"))
