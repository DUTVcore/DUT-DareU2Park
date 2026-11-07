extends CharacterBody2D

signal hp_changed(current_hp: float, max_hp: float)
signal mirrors_toggled(folded: bool)
signal bike_wrecked(reason: String)
signal horn_honked(world_pos: Vector2)
signal park_attempted()
signal status_message(msg: String, color: Color)

# Operating parameters (overridden by selected bike in GameManager)
@export var acceleration: float = 430.0
@export var max_speed: float = 245.0
@export var reverse_speed: float = 84.0
@export var friction: float = 265.0
@export var steer_speed: float = 3.80
@export var max_hp: float = 100.0

var current_hp: float = 100.0
var current_speed: float = 0.0
var steering_input: float = 0.0
var is_stunned: bool = false
var is_parked: bool = false
var is_disabled: bool = false
var mirrors_folded: bool = false
var pothole_resist: float = 1.0

var _drift_velocity: Vector2 = Vector2.ZERO
var _wet_timer: float = 0.0
var _collision_cd: float = 0.0
var _mirror_cd: float = 0.0
var _horn_ring_time: float = -1.0
var _mirror_fold_anim: float = 0.0
var _is_braking: bool = false
var _skid_points: Array[Dictionary] = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var mirror_left: Area2D = $MirrorHitboxLeft
@onready var mirror_right: Area2D = $MirrorHitboxRight
@onready var cam = $Camera2D
@onready var overlay: Node2D = $RiderOverlay

func _ready() -> void:
	add_to_group("player_bike")
	_apply_selected_bike_stats()
	current_hp = max_hp

	if mirror_left:
		mirror_left.area_entered.connect(_on_mirror_hit_area.bind(-1.0))
		mirror_left.body_entered.connect(_on_mirror_hit_body.bind(-1.0))
	if mirror_right:
		mirror_right.area_entered.connect(_on_mirror_hit_area.bind(1.0))
		mirror_right.body_entered.connect(_on_mirror_hit_body.bind(1.0))

	if overlay:
		overlay.draw.connect(_draw_rider_and_mirrors)

	hp_changed.emit(current_hp, max_hp)
	mirrors_toggled.emit(mirrors_folded)

func _apply_selected_bike_stats() -> void:
	var data: Dictionary = GameManager.get_selected_bike_data()
	acceleration = float(data.get("acceleration", acceleration))
	max_speed = float(data.get("max_speed", max_speed))
	reverse_speed = float(data.get("reverse_speed", reverse_speed))
	friction = float(data.get("friction", friction))
	steer_speed = float(data.get("steer_speed", steer_speed))
	max_hp = float(data.get("max_hp", max_hp))
	pothole_resist = float(data.get("pothole_resist", 1.0))
	var tex_path: String = str(data.get("sprite", ""))
	if tex_path != "" and ResourceLoader.exists(tex_path) and sprite != null:
		sprite.texture = load(tex_path)

func _physics_process(delta: float) -> void:
	if _collision_cd > 0.0:
		_collision_cd -= delta
	if _mirror_cd > 0.0:
		_mirror_cd -= delta
	if _wet_timer > 0.0:
		_wet_timer -= delta
	if _horn_ring_time >= 0.0:
		_horn_ring_time += delta
		if _horn_ring_time > 0.45:
			_horn_ring_time = -1.0

	var target_fold := 1.0 if mirrors_folded else 0.0
	_mirror_fold_anim = move_toward(_mirror_fold_anim, target_fold, delta * 8.0)

	if is_parked or is_disabled:
		AudioManager.update_engine(0.0, false)
		if overlay:
			overlay.queue_redraw()
		queue_redraw()
		return

	if not is_stunned:
		_handle_actions()
		_handle_input(delta)
	_apply_movement(delta)

	var speed_ratio := clampf(absf(current_speed) / maxf(max_speed, 1.0), 0.0, 1.0)
	AudioManager.update_engine(speed_ratio, true)
	if cam and cam.has_method("update_lookahead"):
		cam.update_lookahead(velocity, delta)

	_update_skids(delta)
	if overlay:
		overlay.queue_redraw()
	queue_redraw()

func _handle_actions() -> void:
	if Input.is_action_just_pressed("fold_mirrors"):
		set_mirrors_folded(not mirrors_folded)
	if Input.is_action_just_pressed("horn"):
		AudioManager.play_sfx("horn", 0.98, 1.03, -2.0)
		_horn_ring_time = 0.0
		horn_honked.emit(global_position)
	if Input.is_action_just_pressed("kickstand"):
		park_attempted.emit()

func set_mirrors_folded(folded: bool, silent: bool = false) -> void:
	if mirrors_folded == folded:
		return
	mirrors_folded = folded
	if mirror_left:
		mirror_left.set_deferred("monitoring", not mirrors_folded)
	if mirror_right:
		mirror_right.set_deferred("monitoring", not mirrors_folded)
	if not silent:
		AudioManager.play_sfx("mirror", 0.95, 1.06, -3.0)
		var txt := "Đã GẬP GƯƠNG (Lách khe 15cm)" if mirrors_folded else "Đã MỞ GƯƠNG (Tầm nhìn rộng)"
		var col := Color("#38BDF8") if mirrors_folded else Color("#F5B700")
		FloatingText.spawn(get_parent(), global_position + Vector2(0, -36), txt, col)
		status_message.emit(txt, col)
	mirrors_toggled.emit(mirrors_folded)

func _handle_input(delta: float) -> void:
	var throttle := Input.get_axis("move_backward", "move_forward")
	var effective_max := max_speed * (0.60 if mirrors_folded else 1.0)
	var grip_mult := 0.52 if _wet_timer > 0.0 else 1.0
	_is_braking = false

	if throttle > 0.05:
		if current_speed < -5.0:
			_is_braking = true
			current_speed = move_toward(current_speed, 0.0, acceleration * 1.7 * grip_mult * delta)
		else:
			current_speed = move_toward(current_speed, effective_max, acceleration * delta)
	elif throttle < -0.05:
		_is_braking = true
		if current_speed > 8.0:
			current_speed = move_toward(current_speed, 0.0, acceleration * 1.75 * grip_mult * delta)
		else:
			current_speed = move_toward(current_speed, -reverse_speed, acceleration * 0.85 * delta)
	else:
		current_speed = move_toward(current_speed, 0.0, friction * grip_mult * delta)

	steering_input = Input.get_axis("steer_left", "steer_right")
	if absf(current_speed) > 4.0 and absf(steering_input) > 0.01:
		var direction_modifier := 1.0 if current_speed >= 0.0 else -1.0
		var speed_factor := clampf(absf(current_speed) / 42.0, 0.35, 1.0)
		var high_speed_dampen := 1.0 - (absf(current_speed) / (max_speed * 1.65))
		var dynamic_steer := steer_speed * speed_factor * clampf(high_speed_dampen, 0.42, 1.0)
		var turn_delta := steering_input * dynamic_steer * delta * direction_modifier
		rotation += turn_delta

		# Lose traction slightly when cornering aggressively at high speed or on wet floor
		var slip_threshold := 140.0 if _wet_timer > 0.0 else 185.0
		if absf(current_speed) > slip_threshold:
			var side_vec := Vector2.RIGHT.rotated(rotation) * steering_input
			var slip_amount := (absf(current_speed) - slip_threshold) * (0.42 if _wet_timer > 0.0 else 0.24)
			_drift_velocity = _drift_velocity.lerp(side_vec * slip_amount, clampf(delta * 5.0, 0.0, 1.0))
			_record_skid()

func _apply_movement(delta: float) -> void:
	var forward_vector := Vector2.UP.rotated(rotation)
	var drift_decay := 2.4 if _wet_timer > 0.0 else 5.5
	_drift_velocity = _drift_velocity.move_toward(Vector2.ZERO, 220.0 * drift_decay * delta)

	var pre_vel := forward_vector * current_speed + _drift_velocity
	velocity = pre_vel
	move_and_slide()

	if get_slide_collision_count() > 0:
		var col := get_slide_collision(0)
		var normal := col.get_normal()
		var impact_speed := maxf(0.0, -pre_vel.dot(normal))
		var collider = col.get_collider()

		if impact_speed > 55.0 and _collision_cd <= 0.0:
			_collision_cd = 0.42
			var dmg := clampf((impact_speed - 45.0) * 0.11, 5.0, 26.0)
			var reason_txt := "Va chạm yếm xe! -%d HP" % int(round(dmg))

			if collider != null:
				if collider.has_method("on_bumped"):
					collider.on_bumped(impact_speed)
				if collider.is_in_group("lecturer_car"):
					dmg = maxf(dmg * 1.5, 20.0)
					reason_txt = "Quẹt ô tô Giảng Viên! -%d HP" % int(round(dmg))
				elif collider.is_in_group("card_barrier"):
					dmg = maxf(dmg, 14.0)
					reason_txt = "Chưa quẹt thẻ đã tông Barie! -%d HP" % int(round(dmg))

			take_damage(dmg, reason_txt, "Va nát dàn áo xe trong nhà xe Bách Khoa!")
			if impact_speed > 130.0:
				AudioManager.play_sfx("crash", 0.92, 1.05, -1.5)
				if cam and cam.has_method("shake"):
					cam.shake(9.5)
			else:
				AudioManager.play_sfx("scrape", 0.94, 1.08, -3.0)
				if cam and cam.has_method("shake"):
					cam.shake(4.5)
			current_speed = -signf(current_speed) * minf(38.0, impact_speed * 0.25)
		else:
			current_speed = move_toward(current_speed, 0.0, friction * 2.2 * delta)

func _on_mirror_hit_area(area: Area2D, side: float) -> void:
	if mirrors_folded or is_parked or is_disabled or _mirror_cd > 0.0:
		return
	if area == mirror_left or area == mirror_right:
		return
	var parent_node = area.get_parent()
	if parent_node == self:
		return
	if parent_node != null and parent_node.has_method("on_bumped"):
		parent_node.on_bumped(80.0)
	_apply_mirror_clip(side, true)

func _on_mirror_hit_body(body, side: float) -> void:
	if mirrors_folded or is_parked or is_disabled or _mirror_cd > 0.0:
		return
	if body == self:
		return
	if absf(current_speed) < 18.0:
		return
	if body != null and body.has_method("on_bumped"):
		body.on_bumped(65.0)
	_apply_mirror_clip(side, false)

func _apply_mirror_clip(side: float, hit_other_mirror: bool) -> void:
	_mirror_cd = 0.45
	var dmg := 8.0 if hit_other_mirror else 6.0
	current_speed *= 0.55
	rotation -= side * deg_to_rad(5.5)
	AudioManager.play_sfx("scrape", 1.05, 1.20, -2.5)
	if cam and cam.has_method("shake"):
		cam.shake(4.2)
	var msg := "Cộp gương! Nhấn [E] gập gương! (-%d HP)" % int(dmg)
	take_damage(dmg, msg, "Gãy rụng cả đôi gương chiếu hậu trước khi kịp đỗ!")

func take_damage(amount: float, popup_msg: String, wreck_reason: String) -> void:
	if is_parked or is_disabled:
		return
	current_hp = maxf(0.0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)
	FloatingText.spawn(get_parent(), global_position + Vector2(0, -32), popup_msg, Color("#EF4444"))
	status_message.emit(popup_msg, Color("#EF4444"))
	if current_hp <= 0.0:
		is_disabled = true
		AudioManager.stop_engine()
		bike_wrecked.emit(wreck_reason)

# Triggered when driving over a pothole / bump (called from Pothole / Puddle Area2D)
func hit_pothole(severity: float) -> void:
	if is_parked or is_disabled:
		return
	var speed_abs := absf(current_speed)
	var speed_scale := clampf(speed_abs / 160.0, 0.25, 1.35)
	var eff_sev := (severity * speed_scale) / maxf(pothole_resist, 0.5)

	current_speed *= lerpf(0.75, 0.32, clampf(speed_scale, 0.0, 1.0))
	var max_deg := clampf(10.0 + eff_sev * 2.2, 6.0, 27.0)
	var wrench_angle := deg_to_rad(randf_range(-max_deg, max_deg))
	rotation += wrench_angle

	AudioManager.play_sfx("pothole", 0.90, 1.08, -2.0)
	if cam and cam.has_method("shake"):
		cam.shake(clampf(eff_sev * 1.6, 3.0, 14.0))

	# Hard pothole jolt pops folded mirrors back open!
	if mirrors_folded and eff_sev > 4.8:
		set_mirrors_folded(false, true)
		FloatingText.spawn(get_parent(), global_position + Vector2(0, -48), "Xóc ổ voi bung gương ra!", Color("#F5B700"))

	if speed_abs > 115.0:
		var dmg := roundf(clampf(eff_sev * 0.9, 3.0, 9.0))
		take_damage(dmg, "Sụp ổ gà kịch phuộc! -%d HP" % int(dmg), "Gãy phuộc xe vì phóng bạt mạng qua ổ voi!")
	else:
		FloatingText.spawn(get_parent(), global_position + Vector2(0, -28), "Ổ gà! Trẹo tay lái!", Color("#F5B700"))

func apply_wet_surface(duration: float = 2.2) -> void:
	if is_parked or is_disabled:
		return
	var was_dry := _wet_timer <= 0.05
	_wet_timer = maxf(_wet_timer, duration)
	if was_dry and absf(current_speed) > 35.0:
		AudioManager.play_sfx("splash", 0.94, 1.08, -3.0)
		FloatingText.spawn(get_parent(), global_position + Vector2(0, -26), "Bánh xe ướt – Coi chừng trượt!", Color("#38BDF8"))

func hit_speed_bump(bump_severity: float = 5.0) -> void:
	if is_parked or is_disabled:
		return
	var speed_abs := absf(current_speed)
	if speed_abs > 125.0:
		current_speed *= 0.55
		rotation += deg_to_rad(randf_range(-11.0, 11.0))
		AudioManager.play_sfx("pothole", 1.05, 1.18, -3.0)
		if cam and cam.has_method("shake"):
			cam.shake(bump_severity * 1.2)
		take_damage(4.0, "Phóng nhanh qua gờ giảm tốc! -4 HP", "Bung dàn nhựa vì phóng qua gờ giảm tốc!")
	else:
		current_speed *= 0.85
		AudioManager.play_sfx("pothole", 1.15, 1.25, -9.0)
		if cam and cam.has_method("shake"):
			cam.shake(1.8)

func engage_kickstand() -> void:
	is_parked = true
	current_speed = 0.0
	velocity = Vector2.ZERO
	AudioManager.stop_engine()
	AudioManager.play_sfx("kickstand", 0.98, 1.02, -1.0)
	var tw := create_tween()
	if sprite:
		tw.tween_property(sprite, "position", Vector2(-2.5, 0.0), 0.16)
	if overlay:
		overlay.queue_redraw()
	queue_redraw()

func _record_skid() -> void:
	var rear_world := global_position + Vector2(0, 26).rotated(rotation)
	_skid_points.append({"pos": rear_world, "ttl": 2.2})
	if _skid_points.size() > 70:
		_skid_points.pop_front()

func _update_skids(delta: float) -> void:
	for i in range(_skid_points.size() - 1, -1, -1):
		_skid_points[i]["ttl"] -= delta
		if _skid_points[i]["ttl"] <= 0.0:
			_skid_points.remove_at(i)

func _draw() -> void:
	# Tire skid marks in local space
	for item in _skid_points:
		var local_pt := to_local(item["pos"])
		var alpha := clampf(float(item["ttl"]) / 2.2, 0.0, 1.0) * 0.35
		draw_circle(local_pt, 2.6, Color(0.08, 0.09, 0.11, alpha))

	# Headlight cone forward
	var cone_pts := PackedVector2Array([
		Vector2(-4, -28),
		Vector2(-30, -135),
		Vector2(30, -135),
		Vector2(4, -28),
	])
	var cone_cols := PackedColorArray([
		Color(1.0, 0.97, 0.78, 0.20),
		Color(1.0, 0.97, 0.78, 0.0),
		Color(1.0, 0.97, 0.78, 0.0),
		Color(1.0, 0.97, 0.78, 0.20),
	])
	draw_polygon(cone_pts, cone_cols)

	# Reverse assist dashed lines ONLY when mirrors are OPEN and backing up!
	if not mirrors_folded and current_speed < -4.0 and not is_parked:
		draw_dashed_line(Vector2(-13, 36), Vector2(-13, 105), Color(0.22, 0.85, 0.98, 0.55), 1.6, 6.0)
		draw_dashed_line(Vector2(13, 36), Vector2(13, 105), Color(0.22, 0.85, 0.98, 0.55), 1.6, 6.0)

	# Brake light glow
	if _is_braking and not is_parked:
		draw_circle(Vector2(0, 30), 6.5, Color(1.0, 0.18, 0.18, 0.45))

	# Horn acoustic wave
	if _horn_ring_time >= 0.0:
		var t := clampf(_horn_ring_time / 0.45, 0.0, 1.0)
		var r := lerpf(12.0, 95.0, t)
		draw_arc(Vector2(0, -28), r, deg_to_rad(-145), deg_to_rad(-35), 24, Color(0.98, 0.82, 0.15, (1.0 - t) * 0.85), 2.5)

func _draw_rider_and_mirrors() -> void:
	var bar_angle := steering_input * 0.24
	var pivot := Vector2(0, -18)

	# Kickstand extended on left side when parked!
	if is_parked:
		overlay.draw_line(Vector2(-8, 6), Vector2(-19, 13), Color("#94A3B8"), 3.0)
		overlay.draw_circle(Vector2(-19, 13), 2.2, Color("#F5B700"))

	# Steerable handlebar
	var left_grip := pivot + Vector2(-16, 0).rotated(bar_angle)
	var right_grip := pivot + Vector2(16, 0).rotated(bar_angle)
	overlay.draw_line(left_grip, right_grip, Color("#334155"), 3.6)
	overlay.draw_circle(left_grip, 2.4, Color("#0F172A"))
	overlay.draw_circle(right_grip, 2.4, Color("#0F172A"))

	# Animated Left & Right Mirrors (wide when 0.0, folded inward when 1.0)
	var l_stalk_end := left_grip + Vector2(lerpf(-5.5, 4.0, _mirror_fold_anim), lerpf(-4.5, 4.0, _mirror_fold_anim)).rotated(bar_angle)
	var r_stalk_end := right_grip + Vector2(lerpf(5.5, -4.0, _mirror_fold_anim), lerpf(-4.5, 4.0, _mirror_fold_anim)).rotated(bar_angle)
	overlay.draw_line(left_grip + Vector2(2, 0), l_stalk_end, Color("#94A3B8"), 1.8)
	overlay.draw_line(right_grip + Vector2(-2, 0), r_stalk_end, Color("#94A3B8"), 1.8)

	var mirror_rim := Color("#1E293B")
	var mirror_glass := Color("#7DD3FC") if not mirrors_folded else Color("#64748B")
	overlay.draw_circle(l_stalk_end, 3.4, mirror_rim)
	overlay.draw_circle(l_stalk_end, 2.2, mirror_glass)
	overlay.draw_circle(r_stalk_end, 3.4, mirror_rim)
	overlay.draw_circle(r_stalk_end, 2.2, mirror_glass)

	# DUT Student Rider (Blue Youth/PE shirt + Laptop Backpack + Helmet)
	if not is_parked:
		# Arms gripping handlebars
		var l_shoulder := Vector2(-9.5, -3)
		var r_shoulder := Vector2(9.5, -3)
		overlay.draw_line(l_shoulder, left_grip + Vector2(2, 1), Color("#1D4ED8"), 4.2)
		overlay.draw_line(r_shoulder, right_grip + Vector2(-2, 1), Color("#1D4ED8"), 4.2)

		# Shoulders / torso
		overlay.draw_rect(Rect2(-10.5, -6, 21, 14), Color("#1E40AF"), true)

		# Student backpack (carrying laptop & Calculus textbook!)
		overlay.draw_rect(Rect2(-7.5, 3, 15, 13), Color("#1E293B"), true)
		overlay.draw_rect(Rect2(-5.5, 5, 11, 3), Color("#F5B700"), true)

		# 3/4 Helmet with visor
		overlay.draw_circle(Vector2(0, -3), 8.2, Color("#0F172A"))
		overlay.draw_circle(Vector2(0, -3), 7.0, Color("#F8FAFC"))
		overlay.draw_arc(Vector2(0, -3), 7.0, deg_to_rad(-145), deg_to_rad(-35), 12, Color("#38BDF8"), 2.6)
