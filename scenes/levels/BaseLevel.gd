extends Node2D

const SCENE_PLAYER := preload("res://scenes/entities/player/PlayerBike.tscn")
const SCENE_HUD := preload("res://scenes/ui/HUD.tscn")
const SCENE_PARKED_BIKE := preload("res://scenes/entities/props/ParkedBike.tscn")
const SCENE_PARKING_SLOT := preload("res://scenes/entities/props/ParkingSlot.tscn")
const SCENE_CARD_GATE := preload("res://scenes/entities/props/CardGate.tscn")
const SCENE_PILLAR := preload("res://scenes/entities/props/GaragePillar.tscn")
const SCENE_CAR := preload("res://scenes/entities/props/LecturerCar.tscn")
const SCENE_POTHOLE := preload("res://scenes/entities/hazards/Pothole.tscn")
const SCENE_PUDDLE := preload("res://scenes/entities/hazards/Puddle.tscn")
const SCENE_SPEED_BUMP := preload("res://scenes/entities/hazards/SpeedBump.tscn")
const SCENE_MOVING := preload("res://scenes/entities/hazards/MovingHazard.tscn")
const TEX_ASPHALT := preload("res://assets/sprites/environment/asphalt_tile.png")

class ShedRoofOverlay extends Node2D:
	var roof_rect: Rect2
	var roof_title: String = ""
	var current_alpha: float = 0.78
	var target_alpha: float = 0.78

	func _process(delta: float) -> void:
		if absf(current_alpha - target_alpha) > 0.005:
			current_alpha = move_toward(current_alpha, target_alpha, delta * 2.8)
			queue_redraw()

	func _draw() -> void:
		var bg := Color(0.09, 0.30, 0.56, current_alpha)
		draw_rect(roof_rect, bg, true)
		# Corrugated metal ribs
		var rib_col := Color(0.65, 0.84, 1.0, current_alpha * 0.32)
		var x := roof_rect.position.x + 14.0
		while x < roof_rect.end.x:
			draw_line(Vector2(x, roof_rect.position.y), Vector2(x, roof_rect.end.y), rib_col, 1.5)
			x += 18.0
		draw_rect(roof_rect, Color(0.22, 0.72, 0.98, maxf(current_alpha, 0.35)), false, 2.5)
		if roof_title != "":
			var fnt := DUTTheme.get_bold_font()
			draw_string(
				fnt,
				Vector2(roof_rect.position.x, roof_rect.position.y + roof_rect.size.y * 0.5 + 6.0),
				roof_title,
				HORIZONTAL_ALIGNMENT_CENTER,
				roof_rect.size.x,
				18,
				Color(1.0, 0.96, 0.80, clampf(current_alpha * 1.15, 0.22, 0.95))
			)

@export var level_index: int = 0
@export var lot_bounds: Rect2 = Rect2(-520, -900, 1040, 1150)
@export var player_spawn_pos: Vector2 = Vector2(0, 140)
@export var player_spawn_rot_deg: float = 0.0
@export var fail_tip: String = "Nhớ nhấn [E] gập gương khi qua khe hẹp và phanh dừng hẳn trong ô đỗ trước khi bấm [SPACE]!"

var player = null
var hud = null
var target_slot = null
var card_gate = null

var _world_layer: Node2D
var _roof_layer: Node2D
var _shed_roofs: Array[ShedRoofOverlay] = []
var _painted_bays: Array[Rect2] = []
var _floor_labels: Array[Dictionary] = []
var _building_rects: Array[Dictionary] = []

var _level_data: Dictionary = {}
var _elapsed_time: float = 0.0
var _time_limit: float = 70.0
var _start_sec_before_7am: int = 180
var _is_finished: bool = false
var _card_required: bool = false
var _card_ok: bool = true

func _ready() -> void:
	GameManager.current_level_index = level_index
	_level_data = GameManager.get_level_data(level_index)
	_time_limit = float(_level_data.get("real_time_limit", 70.0))
	_start_sec_before_7am = int(_level_data.get("start_seconds_before_7am", 180))
	_card_required = bool(_level_data.get("requires_card", false))
	_card_ok = not _card_required

	_world_layer = Node2D.new()
	_world_layer.name = "WorldEntities"
	add_child(_world_layer)

	_roof_layer = Node2D.new()
	_roof_layer.name = "ShedRoofs"
	_roof_layer.z_index = 40
	add_child(_roof_layer)

	_build_perimeter_walls()
	_build_level_layout()
	_spawn_player_and_hud()
	AudioManager.play_bgm("gameplay")
	queue_redraw()

# Overridden by each level subclass!
func _build_level_layout() -> void:
	pass

func _build_perimeter_walls() -> void:
	var t := 44.0
	var b := lot_bounds
	add_wall_rect(Rect2(b.position.x - t, b.position.y - t, b.size.x + t * 2.0, t), "", Color("#1E293B"))
	add_wall_rect(Rect2(b.position.x - t, b.end.y, b.size.x + t * 2.0, t), "", Color("#1E293B"))
	add_wall_rect(Rect2(b.position.x - t, b.position.y, t, b.size.y), "", Color("#1E293B"))
	add_wall_rect(Rect2(b.end.x, b.position.y, t, b.size.y), "", Color("#1E293B"))

func _spawn_player_and_hud() -> void:
	player = SCENE_PLAYER.instantiate()
	player.global_position = player_spawn_pos
	player.global_rotation = deg_to_rad(player_spawn_rot_deg)
	_world_layer.add_child(player)

	hud = SCENE_HUD.instantiate()
	add_child(hud)
	hud.setup_level_info(_level_data)
	hud.update_hp(player.current_hp, player.max_hp)
	hud.update_mirrors(player.mirrors_folded)

	player.hp_changed.connect(hud.update_hp)
	player.mirrors_toggled.connect(hud.update_mirrors)
	player.status_message.connect(func(msg: String, col: Color): hud.show_toast(msg, col, 2.4))
	player.bike_wrecked.connect(_on_bike_wrecked)
	player.park_attempted.connect(_on_park_attempted)

	hud.request_resume.connect(_toggle_pause.bind(false))
	hud.request_restart.connect(func(): GameManager.restart_current_level())
	hud.request_next_level.connect(func(): GameManager.start_level(level_index + 1))
	hud.request_level_select.connect(func(): GameManager.go_to_level_select())
	hud.request_main_menu.connect(func(): GameManager.go_to_main_menu())

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart_level"):
		GameManager.restart_current_level()
		return
	if event.is_action_pressed("pause_game") and not _is_finished:
		_toggle_pause(not get_tree().paused)

func _toggle_pause(should_pause: bool) -> void:
	get_tree().paused = should_pause
	if should_pause:
		AudioManager.stop_engine()
	if hud:
		hud.set_paused_visible(should_pause)

func _process(delta: float) -> void:
	if _is_finished or get_tree().paused:
		return

	_elapsed_time += delta
	var progress := clampf(_elapsed_time / maxf(_time_limit, 1.0), 0.0, 1.0)
	var clock_str := GameManager.format_campus_clock(_start_sec_before_7am, progress)
	var sec_left := maxf(0.0, _time_limit - _elapsed_time)

	if hud and player:
		hud.update_clock(clock_str, sec_left)
		hud.update_speed(player.current_speed)

		var nav_pos: Vector2 = player.global_position
		var nav_title := "MỤC TIÊU: Ô ĐỖ TRỐNG"
		var eval_dict: Dictionary = {}

		if not _card_ok and card_gate != null and is_instance_valid(card_gate):
			nav_pos = (card_gate.global_position as Vector2) + Vector2(0, 32)
			nav_title = "BƯỚC 1: QUẸT THẺ TỪ CỔNG"
		elif target_slot != null and is_instance_valid(target_slot):
			nav_pos = target_slot.global_position
			nav_title = "MỤC TIÊU: " + str(target_slot.slot_label)
			if target_slot.has_method("evaluate_bike"):
				var check: Dictionary = target_slot.evaluate_bike(player)
				if float(check.get("dist", 999.0)) < 95.0:
					eval_dict = check

		hud.update_navigation(player.global_position, nav_pos, nav_title, eval_dict)

	# Update shed roof X-ray transparency when bike drives underneath!
	if player:
		for roof in _shed_roofs:
			var inside: bool = roof.roof_rect.grow(24.0).has_point(player.global_position)
			roof.target_alpha = 0.12 if inside else 0.74

	if _elapsed_time >= _time_limit:
		_trigger_timeout_fail()

func _on_park_attempted() -> void:
	if _is_finished:
		return
	if not _card_ok:
		AudioManager.play_sfx("scrape", 0.9, 1.0, -4.0)
		hud.show_toast("Chưa quẹt Thẻ Sinh Viên qua cổng nhà xe mà đòi đỗ!", DUTTheme.DUT_RED, 2.8)
		return
	if target_slot == null or not is_instance_valid(target_slot):
		return

	var check: Dictionary = target_slot.evaluate_bike(player)
	if not bool(check.get("ready", false)):
		var why := str(check.get("reason", "Chưa vào đúng vị trí ô đỗ!"))
		AudioManager.play_sfx("mirror", 0.8, 0.9, -4.0)
		FloatingText.spawn(_world_layer, player.global_position + Vector2(0, -34), why, DUTTheme.DUT_GOLD)
		hud.show_toast(why, DUTTheme.DUT_GOLD, 2.8)
		return

	# SUCCESSFUL PARKING!!
	_is_finished = true
	player.engage_kickstand()
	FloatingText.spawn(_world_layer, player.global_position + Vector2(0, -42), "CẠCH! ĐỖ XE CHUẨN BÁCH KHOA!", DUTTheme.DUT_GREEN)
	AudioManager.play_sfx("win", 1.0, 1.0, -1.0)

	var progress := clampf(_elapsed_time / maxf(_time_limit, 1.0), 0.0, 0.999)
	var clock_str := GameManager.format_campus_clock(_start_sec_before_7am, progress)
	var hp_ratio: float = float(player.current_hp) / maxf(float(player.max_hp), 1.0)
	var time_left_ratio := clampf(1.0 - progress, 0.0, 1.0)
	var angle_deg := float(check.get("angle_deg", 0.0))

	var grade_info := GameManager.evaluate_grade(hp_ratio, time_left_ratio, angle_deg)
	grade_info["clock"] = clock_str
	grade_info["hp_ratio"] = hp_ratio
	grade_info["angle_deg"] = angle_deg

	GameManager.record_level_win(level_index, grade_info)
	var has_next := (level_index + 1) < GameManager.LEVELS.size()

	var timer := get_tree().create_timer(0.65)
	timer.timeout.connect(func():
		if hud:
			hud.show_win_result(grade_info, has_next)
	)

func _on_bike_wrecked(reason: String) -> void:
	if _is_finished:
		return
	_is_finished = true
	AudioManager.play_sfx("fail", 1.0, 1.0, -1.0)
	hud.show_fail_result(
		"💥 HỎNG NÁT DÀN ÁO – ĐỀN TIỀN SỬA XE!",
		reason + "\nTiền sửa yếm với gương tuần này bằng cả tháng ăn cơm bụi Hòa Khánh rồi!",
		fail_tip
	)

func _trigger_timeout_fail() -> void:
	if _is_finished:
		return
	_is_finished = true
	player.is_disabled = true
	AudioManager.stop_engine()
	AudioManager.play_sfx("fail", 1.0, 1.0, -1.0)
	hud.show_fail_result(
		"⏰ 07:00:00 AM – ĐIỂM DANH VẮNG!",
		"Giảng viên đã khóa cửa phòng học '" + str(_level_data.get("course", "")) + "'!\nBạn vẫn còn loay hoay trong nhà xe khi trống trường đã điểm 07:00 sáng!",
		fail_tip
	)

# ============================================================================
# Level Builder Helpers
# ============================================================================

func add_wall_rect(rect: Rect2, title: String = "", color: Color = Color("#1E3A5F")) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.collision_layer = 5
	body.collision_mask = 0
	body.position = rect.get_center()
	var col := CollisionShape2D.new()
	var shp := RectangleShape2D.new()
	shp.size = rect.size
	col.shape = shp
	body.add_child(col)
	_world_layer.add_child(body)
	_building_rects.append({"rect": rect, "title": title, "color": color})
	return body

func add_shed_roof(rect: Rect2, title: String = "NHÀ XE SINH VIÊN") -> void:
	var roof := ShedRoofOverlay.new()
	roof.roof_rect = rect
	roof.roof_title = title
	_roof_layer.add_child(roof)
	_shed_roofs.append(roof)

func add_painted_bay_strip(origin: Vector2, count: int, step_x: float = 50.0, bay_w: float = 46.0, bay_h: float = 84.0) -> void:
	for i in range(count):
		var cx := origin.x + float(i) * step_x
		_painted_bays.append(Rect2(cx - bay_w * 0.5, origin.y - bay_h * 0.5, bay_w, bay_h))

func add_floor_label(pos: Vector2, text_str: String, color: Color = Color(1, 1, 1, 0.42), size: int = 16) -> void:
	_floor_labels.append({"pos": pos, "text": text_str, "color": color, "size": size})

func add_parked_bike(pos: Vector2, rot_deg: float = 0.0, variant: int = -1) -> StaticBody2D:
	var b = SCENE_PARKED_BIKE.instantiate()
	b.position = pos
	b.rotation = deg_to_rad(rot_deg)
	b.variant_index = variant
	_world_layer.add_child(b)
	return b

func add_parked_row(
	origin: Vector2,
	count: int,
	step: Vector2,
	base_rot_deg: float,
	skip_indices: Array = [],
	messy_deg: float = 4.0,
	jut_indices: Array = [],
	jut_dir: Vector2 = Vector2(0, 14)
) -> void:
	add_painted_bay_strip(origin, count, step.x if absf(step.x) > 1.0 else 50.0)
	for i in range(count):
		if skip_indices.has(i):
			continue
		var pos := origin + step * float(i)
		if jut_indices.has(i):
			pos += jut_dir
		var det_wave := sin(float(i) * 2.37 + origin.y * 0.03)
		var rot := base_rot_deg + det_wave * messy_deg
		add_parked_bike(pos, rot, (i + int(absf(origin.y))) % 6)

func set_target_slot(pos: Vector2, rot_deg: float = 0.0, label_txt: String = "Ô TRỐNG", max_angle: float = 17.5) -> Area2D:
	var s = SCENE_PARKING_SLOT.instantiate()
	s.position = pos
	s.rotation = deg_to_rad(rot_deg)
	s.slot_label = label_txt
	s.max_angle_deg = max_angle
	_world_layer.add_child(s)
	target_slot = s
	return s

func add_card_gate(pos: Vector2, title_txt: String = "TRẠM THẺ TỪ SV") -> Node2D:
	var g = SCENE_CARD_GATE.instantiate()
	g.position = pos
	g.gate_title = title_txt
	g.card_scanned.connect(func(): _card_ok = true)
	_world_layer.add_child(g)
	card_gate = g
	return g

func add_pillar(pos: Vector2) -> StaticBody2D:
	var p = SCENE_PILLAR.instantiate()
	p.position = pos
	_world_layer.add_child(p)
	return p

func add_lecturer_car(pos: Vector2, rot_deg: float = 0.0) -> StaticBody2D:
	var c = SCENE_CAR.instantiate()
	c.position = pos
	c.rotation = deg_to_rad(rot_deg)
	_world_layer.add_child(c)
	return c

func add_pothole(pos: Vector2, sev: float = 6.0) -> Area2D:
	var h = SCENE_POTHOLE.instantiate()
	h.position = pos
	h.severity = sev
	_world_layer.add_child(h)
	return h

func add_puddle(pos: Vector2, hides_hole: bool = false, sev: float = 7.5, sc: Vector2 = Vector2.ONE) -> Area2D:
	var p = SCENE_PUDDLE.instantiate()
	p.position = pos
	p.hides_pothole = hides_hole
	p.pothole_severity = sev
	p.scale = sc
	_world_layer.add_child(p)
	return p

func add_speed_bump(pos: Vector2, rot_deg: float = 0.0, sc_x: float = 1.0) -> Area2D:
	var sb = SCENE_SPEED_BUMP.instantiate()
	sb.position = pos
	sb.rotation = deg_to_rad(rot_deg)
	sb.scale.x = sc_x
	_world_layer.add_child(sb)
	return sb

func add_moving_hazard(pos: Vector2, offset: Vector2, type_str: String = "student_walker", spd: float = 55.0) -> CharacterBody2D:
	var mh = SCENE_MOVING.instantiate()
	mh.position = pos
	mh.patrol_offset = offset
	mh.hazard_type = type_str
	mh.move_speed = spd
	_world_layer.add_child(mh)
	return mh

func _draw() -> void:
	# Outer campus grass / trees margin
	var outer := lot_bounds.grow(420.0)
	draw_rect(outer, Color("#1F3D2B"), true)

	# Tiled concrete / asphalt parking floor
	if TEX_ASPHALT:
		draw_texture_rect(TEX_ASPHALT, lot_bounds, true)
	else:
		draw_rect(lot_bounds, Color("#3E434A"), true)

	# Painted white parking bay markings
	var bay_col := Color(0.94, 0.96, 0.98, 0.28)
	for r in _painted_bays:
		draw_rect(r, bay_col, false, 1.8)

	# Floor stencil labels
	var fnt := DUTTheme.get_bold_font()
	for item in _floor_labels:
		var p: Vector2 = item["pos"]
		draw_string(fnt, p - Vector2(220, 0), str(item["text"]), HORIZONTAL_ALIGNMENT_CENTER, 440, int(item["size"]), item["color"])

	# Campus buildings & perimeter walls
	for b in _building_rects:
		var r: Rect2 = b["rect"]
		var c: Color = b["color"]
		draw_rect(r, c, true)
		draw_rect(r, Color("#F5B700"), false, 2.2)
		var t: String = b["title"]
		if t != "":
			draw_string(
				fnt,
				Vector2(r.position.x, r.get_center().y + 6.0),
				t,
				HORIZONTAL_ALIGNMENT_CENTER,
				r.size.x,
				15,
				Color("#F8FAFC")
			)
