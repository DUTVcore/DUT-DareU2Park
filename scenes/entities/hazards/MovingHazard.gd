extends CharacterBody2D

@export_enum("student_walker", "moving_bike", "security_guard") var hazard_type: String = "student_walker"
@export var patrol_offset: Vector2 = Vector2(160, 0)
@export var move_speed: float = 55.0

var _start_pos: Vector2
var _end_pos: Vector2
var _going_to_end: bool = true
var _pause_timer: float = 0.0
var _anim_time: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	_start_pos = global_position
	_end_pos = global_position + patrol_offset
	_configure_appearance()
	call_deferred("_connect_player_horn")

func _configure_appearance() -> void:
	if hazard_type == "moving_bike":
		if sprite and ResourceLoader.exists("res://assets/sprites/vehicles/parked_exciter_gp.png"):
			sprite.texture = load("res://assets/sprites/vehicles/parked_exciter_gp.png")
			sprite.visible = true
		var rect := RectangleShape2D.new()
		rect.size = Vector2(22, 64)
		col_shape.shape = rect
	else:
		if sprite:
			sprite.visible = false
		var circ := CircleShape2D.new()
		circ.radius = 12.0
		col_shape.shape = circ

func _connect_player_horn() -> void:
	var players := get_tree().get_nodes_in_group("player_bike")
	for p in players:
		if p.has_signal("horn_honked") and not p.is_connected("horn_honked", _on_player_horn):
			p.connect("horn_honked", _on_player_horn)

func _on_player_horn(horn_pos: Vector2) -> void:
	var dist := global_position.distance_to(horn_pos)
	if dist > 235.0:
		return
	_pause_timer = 2.6
	if hazard_type == "security_guard":
		FloatingText.spawn(get_parent(), global_position + Vector2(0, -26), "Bảo vệ: Trong nhà xe đừng bóp còi inh ỏi em!", Color("#F5B700"))
	elif hazard_type == "moving_bike":
		FloatingText.spawn(get_parent(), global_position + Vector2(0, -26), "SV khác: Ok bạn chạy qua trước đi!", Color("#38BDF8"))
	else:
		FloatingText.spawn(get_parent(), global_position + Vector2(0, -26), "SV đi bộ: Ối xin lỗi, mình mải ôn đề cương!", Color("#22C55E"))

func on_bumped(_force: float = 60.0) -> void:
	_pause_timer = 1.8
	if hazard_type == "security_guard":
		FloatingText.spawn(get_parent(), global_position + Vector2(0, -28), "Bảo vệ: Ấy! Tông trúng chú bảo vệ rồi thẻ SV đâu?!", Color("#EF4444"))
	elif hazard_type == "moving_bike":
		FloatingText.spawn(get_parent(), global_position + Vector2(0, -28), "SV khác: Coi chừng trầy xe mới mua của tui!", Color("#F59E0B"))
	else:
		FloatingText.spawn(get_parent(), global_position + Vector2(0, -28), "SV đi bộ: Á đụng trúng chân tui rồi!", Color("#EF4444"))

func _physics_process(delta: float) -> void:
	_anim_time += delta * 6.0
	if _pause_timer > 0.0:
		_pause_timer -= delta
		velocity = Vector2.ZERO
		queue_redraw()
		return

	var target := _end_pos if _going_to_end else _start_pos
	var diff := target - global_position
	if diff.length() < 8.0:
		_going_to_end = not _going_to_end
		_pause_timer = 0.65
		velocity = Vector2.ZERO
		return

	var dir := diff.normalized()
	rotation = dir.angle() + PI * 0.5
	velocity = dir * move_speed
	var collided := move_and_slide()
	if collided:
		_going_to_end = not _going_to_end
		_pause_timer = 0.8
	queue_redraw()

func _draw() -> void:
	if hazard_type == "moving_bike":
		# Blinking amber turn signals + rider helmet
		draw_circle(Vector2(0, -4), 7.5, Color("#F8FAFC"))
		if int(_anim_time * 1.5) % 2 == 0:
			draw_circle(Vector2(-11, -24), 4.0, Color("#F59E0B"))
			draw_circle(Vector2(11, -24), 4.0, Color("#F59E0B"))
		return

	var step := sin(_anim_time) * 3.5 if _pause_timer <= 0.0 else 0.0
	# Feet walking
	draw_circle(Vector2(-4, -5 + step), 3.5, Color("#1E293B"))
	draw_circle(Vector2(4, -5 - step), 3.5, Color("#1E293B"))

	if hazard_type == "security_guard":
		# Light-blue security guard uniform + dark visor cap + yellow armband
		draw_rect(Rect2(-10, -5, 20, 11), Color("#38BDF8"), true)
		draw_rect(Rect2(7, -3, 4, 6), Color("#F5B700"), true)
		draw_circle(Vector2.ZERO, 7.5, Color("#1E3A8A"))
		draw_rect(Rect2(-5, -11, 10, 4), Color("#0F172A"), true)
	else:
		# DUT Student walking with backpack + holding smartphone/notes ahead!
		draw_rect(Rect2(-9, -4, 18, 10), Color("#2563EB"), true)
		draw_rect(Rect2(-7, 3, 14, 9), Color("#334155"), true)
		draw_rect(Rect2(-3, -13, 6, 5), Color("#E2E8F0"), true) # Smartphone / formula sheet!
		draw_circle(Vector2.ZERO, 7.0, Color("#1E293B"))
