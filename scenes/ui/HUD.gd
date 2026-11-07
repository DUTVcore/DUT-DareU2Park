extends CanvasLayer

signal request_resume()
signal request_restart()
signal request_next_level()
signal request_level_select()
signal request_main_menu()

class CompassWidget extends Control:
	var target_angle: float = 0.0
	var is_ready_green: bool = false

	func _draw() -> void:
		var c := size * 0.5
		var r := minf(c.x, c.y) - 3.0
		draw_circle(c, r, Color(0.05, 0.10, 0.18, 0.92))
		var ring_col := Color("#22C55E") if is_ready_green else Color("#F5B700")
		draw_arc(c, r, 0.0, TAU, 28, ring_col, 2.2)

		var dir := Vector2.UP.rotated(target_angle)
		var perp := dir.orthogonal()
		var tip := c + dir * (r - 5.0)
		var tail_l := c - dir * (r * 0.45) + perp * 6.5
		var tail_r := c - dir * (r * 0.45) - perp * 6.5
		var notch := c - dir * (r * 0.18)
		draw_colored_polygon(PackedVector2Array([tip, tail_l, notch, tail_r]), ring_col)

class RainOverlay extends Control:
	var enabled_rain: bool = false
	var _t: float = 0.0

	func _process(delta: float) -> void:
		if not enabled_rain:
			return
		_t += delta
		queue_redraw()

	func _draw() -> void:
		if not enabled_rain:
			return
		var vp := get_viewport_rect().size
		var col := Color(0.75, 0.88, 1.0, 0.22)
		for i in range(68):
			var seed_x := fmod(float(i) * 97.3 + _t * 260.0, vp.x + 160.0) - 80.0
			var seed_y := fmod(float(i) * 61.7 + _t * 640.0 + float(i % 7) * 83.0, vp.y + 80.0) - 40.0
			var p0 := Vector2(seed_x, seed_y)
			var p1 := p0 + Vector2(-11.0, 26.0)
			draw_line(p0, p1, col, 1.4)

var _root: Control
var _rain: RainOverlay
var _hp_bar: ProgressBar
var _hp_label: Label
var _speed_label: Label
var _mirror_badge: PanelContainer
var _mirror_label: Label
var _course_label: Label
var _clock_label: Label
var _subclock_label: Label
var _compass: CompassWidget
var _target_title_lbl: Label
var _target_dist_lbl: Label
var _align_label: Label
var _toast_label: Label
var _toast_timer: float = 0.0

var _pause_overlay: ColorRect
var _mute_btn: Button
var _result_overlay: ColorRect
var _res_badge_lbl: Label
var _res_title_lbl: Label
var _res_stats_lbl: Label
var _res_comment_lbl: Label
var _next_btn: Button

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 20
	_build_ui()

func _build_ui() -> void:
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.theme = DUTTheme.get_theme()
	add_child(_root)

	_rain = RainOverlay.new()
	_rain.set_anchors_preset(Control.PRESET_FULL_RECT)
	_rain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_rain)

	# Top bar HBox
	var top_margin := MarginContainer.new()
	top_margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_margin.add_theme_constant_override("margin_left", 14)
	top_margin.add_theme_constant_override("margin_right", 14)
	top_margin.add_theme_constant_override("margin_top", 10)
	top_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(top_margin)

	var top_hbox := HBoxContainer.new()
	top_hbox.add_theme_constant_override("separation", 12)
	top_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_margin.add_child(top_hbox)

	# 1. Left Bike Card
	var left_panel := PanelContainer.new()
	left_panel.custom_minimum_size = Vector2(325, 96)
	left_panel.add_theme_stylebox_override("panel", DUTTheme.make_box(DUTTheme.DUT_CARD_BG, Color(0.22, 0.50, 0.88, 0.8), 2, 12))
	top_hbox.add_child(left_panel)

	var left_vbox := VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 5)
	left_panel.add_child(left_vbox)

	var bike_data := GameManager.get_selected_bike_data()
	var bike_title := Label.new()
	bike_title.text = "🛵 %s  •  %s" % [bike_data["name"], bike_data["plate"]]
	bike_title.add_theme_font_override("font", DUTTheme.get_bold_font())
	bike_title.add_theme_font_size_override("font_size", 14)
	bike_title.add_theme_color_override("font_color", DUTTheme.DUT_GOLD)
	left_vbox.add_child(bike_title)

	var hp_row := HBoxContainer.new()
	hp_row.add_theme_constant_override("separation", 8)
	left_vbox.add_child(hp_row)

	_hp_bar = ProgressBar.new()
	_hp_bar.custom_minimum_size = Vector2(185, 16)
	_hp_bar.show_percentage = false
	_hp_bar.max_value = 100.0
	_hp_bar.value = 100.0
	_hp_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var bg_sb := DUTTheme.make_box(Color(0.12, 0.16, 0.22, 0.95), Color(0.3, 0.36, 0.45), 1, 6)
	bg_sb.shadow_size = 0
	_hp_bar.add_theme_stylebox_override("background", bg_sb)
	hp_row.add_child(_hp_bar)

	_hp_label = Label.new()
	_hp_label.text = "100/100 HP"
	_hp_label.add_theme_font_override("font", DUTTheme.get_bold_font())
	_hp_label.add_theme_font_size_override("font_size", 13)
	hp_row.add_child(_hp_label)

	var bottom_row := HBoxContainer.new()
	bottom_row.add_theme_constant_override("separation", 10)
	left_vbox.add_child(bottom_row)

	_speed_label = Label.new()
	_speed_label.text = "00 km/h"
	_speed_label.custom_minimum_size = Vector2(74, 0)
	_speed_label.add_theme_font_override("font", DUTTheme.get_bold_font())
	_speed_label.add_theme_font_size_override("font_size", 14)
	bottom_row.add_child(_speed_label)

	_mirror_badge = PanelContainer.new()
	_mirror_badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_vbox.remove_child(bottom_row)
	left_vbox.add_child(bottom_row)
	bottom_row.add_child(_mirror_badge)

	_mirror_label = Label.new()
	_mirror_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mirror_label.add_theme_font_override("font", DUTTheme.get_bold_font())
	_mirror_label.add_theme_font_size_override("font_size", 12)
	_mirror_badge.add_child(_mirror_label)
	update_mirrors(false)

	# Spacer
	var sp1 := Control.new()
	sp1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_hbox.add_child(sp1)

	# 2. Center Campus Clock Panel
	var center_panel := PanelContainer.new()
	center_panel.custom_minimum_size = Vector2(370, 96)
	center_panel.add_theme_stylebox_override("panel", DUTTheme.make_box(DUTTheme.DUT_CARD_BG, DUTTheme.DUT_GOLD, 2, 12))
	top_hbox.add_child(center_panel)

	var center_vbox := VBoxContainer.new()
	center_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center_vbox.add_theme_constant_override("separation", 2)
	center_panel.add_child(center_vbox)

	_course_label = Label.new()
	_course_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_course_label.add_theme_font_override("font", DUTTheme.get_bold_font())
	_course_label.add_theme_font_size_override("font_size", 13)
	_course_label.add_theme_color_override("font_color", DUTTheme.DUT_LIGHT_BLUE)
	center_vbox.add_child(_course_label)

	_clock_label = Label.new()
	_clock_label.text = "06:56:30 AM"
	_clock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_clock_label.add_theme_font_override("font", DUTTheme.get_bold_font())
	_clock_label.add_theme_font_size_override("font_size", 26)
	_clock_label.add_theme_color_override("font_color", Color.WHITE)
	center_vbox.add_child(_clock_label)

	_subclock_label = Label.new()
	_subclock_label.text = "Điểm danh lúc 07:00:00 AM"
	_subclock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subclock_label.add_theme_font_size_override("font_size", 12)
	_subclock_label.add_theme_color_override("font_color", DUTTheme.DUT_MUTED)
	center_vbox.add_child(_subclock_label)

	# Spacer
	var sp2 := Control.new()
	sp2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sp2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_hbox.add_child(sp2)

	# 3. Right Target Radar & Alignment Panel
	var right_panel := PanelContainer.new()
	right_panel.custom_minimum_size = Vector2(335, 96)
	right_panel.add_theme_stylebox_override("panel", DUTTheme.make_box(DUTTheme.DUT_CARD_BG, Color(0.22, 0.50, 0.88, 0.8), 2, 12))
	top_hbox.add_child(right_panel)

	var right_hbox := HBoxContainer.new()
	right_hbox.add_theme_constant_override("separation", 10)
	right_panel.add_child(right_hbox)

	_compass = CompassWidget.new()
	_compass.custom_minimum_size = Vector2(54, 54)
	_compass.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	right_hbox.add_child(_compass)

	var right_vbox := VBoxContainer.new()
	right_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.add_theme_constant_override("separation", 3)
	right_hbox.add_child(right_vbox)

	_target_title_lbl = Label.new()
	_target_title_lbl.text = "MỤC TIÊU: Ô ĐỖ TRỐNG"
	_target_title_lbl.add_theme_font_override("font", DUTTheme.get_bold_font())
	_target_title_lbl.add_theme_font_size_override("font_size", 13)
	_target_title_lbl.add_theme_color_override("font_color", DUTTheme.DUT_GOLD)
	right_vbox.add_child(_target_title_lbl)

	_target_dist_lbl = Label.new()
	_target_dist_lbl.text = "Khoảng cách: 15.0m"
	_target_dist_lbl.add_theme_font_size_override("font_size", 13)
	right_vbox.add_child(_target_dist_lbl)

	_align_label = Label.new()
	_align_label.text = "Căn xe vào vạch & gạt chống [SPACE]"
	_align_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_align_label.add_theme_font_override("font", DUTTheme.get_bold_font())
	_align_label.add_theme_font_size_override("font_size", 12)
	_align_label.add_theme_color_override("font_color", DUTTheme.DUT_MUTED)
	right_vbox.add_child(_align_label)

	# Bottom Toast + Key Hints
	var bot_vbox := VBoxContainer.new()
	bot_vbox.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bot_vbox.offset_top = -68
	bot_vbox.offset_bottom = -8
	bot_vbox.alignment = BoxContainer.ALIGNMENT_END
	bot_vbox.add_theme_constant_override("separation", 4)
	bot_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(bot_vbox)

	_toast_label = Label.new()
	_toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast_label.add_theme_font_override("font", DUTTheme.get_bold_font())
	_toast_label.add_theme_font_size_override("font_size", 16)
	_toast_label.add_theme_color_override("font_color", DUTTheme.DUT_GOLD)
	_toast_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.92))
	_toast_label.add_theme_constant_override("outline_size", 5)
	bot_vbox.add_child(_toast_label)

	var hint_bar := Label.new()
	hint_bar.text = "[W/S] Ga / Phanh-Lùi   •   [A/D] Đánh lái   •   [E / Shift] Gập gương   •   [F] Bóp còi   •   [SPACE] Gạt chân chống   •   [R] Đỗ lại   •   [Esc] Tạm dừng"
	hint_bar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_bar.add_theme_font_size_override("font_size", 13)
	hint_bar.add_theme_color_override("font_color", Color(0.90, 0.94, 0.98, 0.90))
	hint_bar.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	hint_bar.add_theme_constant_override("outline_size", 4)
	bot_vbox.add_child(hint_bar)

	_build_pause_modal()
	_build_result_modal()

func _build_pause_modal() -> void:
	_pause_overlay = ColorRect.new()
	_pause_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.color = Color(0.02, 0.05, 0.12, 0.78)
	_pause_overlay.visible = false
	_root.add_child(_pause_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(420, 340)
	card.add_theme_stylebox_override("panel", DUTTheme.make_box(DUTTheme.DUT_PANEL_BG, DUTTheme.DUT_GOLD, 2, 16))
	center.add_child(card)

	var vb := VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 12)
	card.add_child(vb)

	var title := Label.new()
	title.text = "⏸ TẠM DỪNG GIỮA NHÀ XE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", DUTTheme.get_bold_font())
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", DUTTheme.DUT_GOLD)
	vb.add_child(title)

	var resume_btn := Button.new()
	resume_btn.text = "▶ Tiếp Tục Luồn Lách"
	resume_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		request_resume.emit()
	)
	vb.add_child(resume_btn)

	var restart_btn := Button.new()
	restart_btn.text = "↻ Chơi Lại Khu Này (R)"
	restart_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		request_restart.emit()
	)
	vb.add_child(restart_btn)

	_mute_btn = Button.new()
	_update_mute_text()
	_mute_btn.pressed.connect(func():
		AudioManager.toggle_mute()
		_update_mute_text()
	)
	vb.add_child(_mute_btn)

	var lvl_btn := Button.new()
	lvl_btn.text = "🗺 Chọn Khu Nhà Xe Khác"
	lvl_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		request_level_select.emit()
	)
	vb.add_child(lvl_btn)

	var menu_btn := Button.new()
	menu_btn.text = "🏠 Về Cổng Trường (Menu Chính)"
	menu_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		request_main_menu.emit()
	)
	vb.add_child(menu_btn)

func _build_result_modal() -> void:
	_result_overlay = ColorRect.new()
	_result_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_result_overlay.color = Color(0.02, 0.05, 0.12, 0.82)
	_result_overlay.visible = false
	_root.add_child(_result_overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_result_overlay.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(540, 390)
	card.add_theme_stylebox_override("panel", DUTTheme.make_box(DUTTheme.DUT_PANEL_BG, DUTTheme.DUT_GOLD, 3, 18))
	center.add_child(card)

	var vb := VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 12)
	card.add_child(vb)

	_res_badge_lbl = Label.new()
	_res_badge_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_res_badge_lbl.add_theme_font_override("font", DUTTheme.get_bold_font())
	_res_badge_lbl.add_theme_font_size_override("font_size", 36)
	vb.add_child(_res_badge_lbl)

	_res_title_lbl = Label.new()
	_res_title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_res_title_lbl.add_theme_font_override("font", DUTTheme.get_bold_font())
	_res_title_lbl.add_theme_font_size_override("font_size", 22)
	vb.add_child(_res_title_lbl)

	_res_stats_lbl = Label.new()
	_res_stats_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_res_stats_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_res_stats_lbl.add_theme_font_size_override("font_size", 15)
	_res_stats_lbl.add_theme_color_override("font_color", DUTTheme.DUT_TEXT)
	vb.add_child(_res_stats_lbl)

	_res_comment_lbl = Label.new()
	_res_comment_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_res_comment_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_res_comment_lbl.add_theme_font_override("font", DUTTheme.get_bold_font())
	_res_comment_lbl.add_theme_font_size_override("font_size", 15)
	_res_comment_lbl.add_theme_color_override("font_color", DUTTheme.DUT_GOLD)
	vb.add_child(_res_comment_lbl)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 12)
	vb.add_child(btn_row)

	_next_btn = Button.new()
	_next_btn.text = "Khu Tiếp Theo ➔"
	DUTTheme.style_accent_button(_next_btn, Color("#15803D"), Color("#4ADE80"))
	_next_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		request_next_level.emit()
	)
	btn_row.add_child(_next_btn)

	var retry_btn := Button.new()
	retry_btn.text = "↻ Đỗ Lại [R]"
	retry_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		request_restart.emit()
	)
	btn_row.add_child(retry_btn)

	var map_btn := Button.new()
	map_btn.text = "🗺 Chọn Khu"
	map_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		request_level_select.emit()
	)
	btn_row.add_child(map_btn)

func _update_mute_text() -> void:
	if _mute_btn:
		_mute_btn.text = "🔇 Âm Thanh: ĐANG TẮT [M]" if AudioManager.is_muted else "🔊 Âm Thanh: ĐANG BẬT [M]"

func setup_level_info(level_data: Dictionary) -> void:
	_course_label.text = "%s  •  %s" % [level_data.get("code", "DUT"), level_data.get("course", "")]
	_rain.enabled_rain = bool(level_data.get("is_rainy", false))
	show_toast(str(level_data.get("brief", "")), DUTTheme.DUT_GOLD, 5.5)

func update_hp(cur: float, max_val: float) -> void:
	_hp_bar.max_value = maxf(max_val, 1.0)
	_hp_bar.value = cur
	_hp_label.text = "%d/%d HP" % [int(round(cur)), int(round(max_val))]
	var ratio := cur / maxf(max_val, 1.0)
	var col := DUTTheme.DUT_GREEN if ratio > 0.6 else (DUTTheme.DUT_GOLD if ratio > 0.3 else DUTTheme.DUT_RED)
	var fill_sb := DUTTheme.make_box(col, col.lightened(0.2), 0, 5)
	fill_sb.shadow_size = 0
	_hp_bar.add_theme_stylebox_override("fill", fill_sb)

func update_speed(px_per_sec: float) -> void:
	var kmh := int(round(absf(px_per_sec) * 0.12))
	var gear := "LÙI " if px_per_sec < -3.0 else ""
	_speed_label.text = "%s%02d km/h" % [gear, kmh]

func update_mirrors(folded: bool) -> void:
	if folded:
		_mirror_label.text = "[E] GƯƠNG: ĐÃ GẬP ><"
		_mirror_label.add_theme_color_override("font_color", Color("#E0F2FE"))
		var sb := DUTTheme.make_box(Color("#0369A1"), Color("#38BDF8"), 1, 6)
		sb.shadow_size = 0
		_mirror_badge.add_theme_stylebox_override("panel", sb)
	else:
		_mirror_label.text = "[E] GƯƠNG: ĐANG MỞ ↔"
		_mirror_label.add_theme_color_override("font_color", Color("#FEF3C7"))
		var sb := DUTTheme.make_box(Color(0.24, 0.20, 0.08, 0.9), DUTTheme.DUT_GOLD, 1, 6)
		sb.shadow_size = 0
		_mirror_badge.add_theme_stylebox_override("panel", sb)

func update_clock(clock_str: String, sec_left: float) -> void:
	_clock_label.text = clock_str
	_subclock_label.text = "Trước 07:00 AM  •  Còn %.1fs thực" % maxf(0.0, sec_left)
	if sec_left <= 15.0:
		var flash := int(sec_left * 4.0) % 2 == 0
		_clock_label.add_theme_color_override("font_color", DUTTheme.DUT_RED if flash else Color("#FCA5A5"))
	else:
		_clock_label.add_theme_color_override("font_color", Color.WHITE)

func update_navigation(bike_pos: Vector2, target_pos: Vector2, target_title: String, slot_eval: Dictionary) -> void:
	_target_title_lbl.text = target_title
	var vec := target_pos - bike_pos
	var meters := vec.length() / 38.0
	_target_dist_lbl.text = "Khoảng cách: %.1fm" % meters
	_compass.target_angle = vec.angle() + PI * 0.5
	var ready := bool(slot_eval.get("ready", false))
	_compass.is_ready_green = ready
	_compass.queue_redraw()

	if slot_eval.is_empty():
		_align_label.text = "Lái xe theo hướng mũi tên vàng"
		_align_label.add_theme_color_override("font_color", DUTTheme.DUT_MUTED)
	elif ready:
		_align_label.text = "✅ CHUẨN GÓC! BẤM [SPACE] GẠT CHỐNG!"
		_align_label.add_theme_color_override("font_color", DUTTheme.DUT_GREEN)
	else:
		_align_label.text = str(slot_eval.get("reason", "Căn thẳng xe vào vạch sơn"))
		_align_label.add_theme_color_override("font_color", DUTTheme.DUT_GOLD)

func show_toast(msg: String, color: Color = DUTTheme.DUT_GOLD, duration: float = 2.8) -> void:
	_toast_label.text = msg
	_toast_label.add_theme_color_override("font_color", color)
	_toast_label.modulate.a = 1.0
	_toast_timer = duration

func set_paused_visible(vis: bool) -> void:
	_update_mute_text()
	_pause_overlay.visible = vis

func show_win_result(data: Dictionary, has_next_level: bool) -> void:
	_pause_overlay.visible = false
	_result_overlay.visible = true
	var stars_int := int(data.get("stars", 1))
	var stars_str := "★".repeat(stars_int) + "☆".repeat(3 - stars_int)
	_res_badge_lbl.text = "ĐIỂM TÍN CHỈ: %s   %s" % [data.get("grade", "A"), stars_str]
	_res_badge_lbl.add_theme_color_override("font_color", DUTTheme.DUT_GREEN)
	_res_title_lbl.text = "🎉 ĐỖ XE THÀNH CÔNG – KỊP ĐIỂM DANH!"
	_res_title_lbl.add_theme_color_override("font_color", Color.WHITE)
	_res_stats_lbl.text = "Đồng hồ lúc gạt chống: %s\nĐộ bền xe còn lại: %d%%   •   Độ lệch góc đỗ: %.1f°   •   Tổng điểm: %d" % [
		data.get("clock", "06:59:00 AM"),
		int(round(float(data.get("hp_ratio", 1.0)) * 100.0)),
		float(data.get("angle_deg", 0.0)),
		int(data.get("score", 0)),
	]
	if has_next_level:
		_res_comment_lbl.text = "💬 Giảng viên: \"%s\"" % data.get("comment", "")
		_next_btn.text = "Khu Tiếp Theo ➔"
		_next_btn.visible = true
	else:
		_res_comment_lbl.text = "🎓 HUYỀN THOẠI NHÀ XE BÁCH KHOA ĐÀ NẴNG! Bạn đã chinh phục toàn bộ 5 khu nhà xe trước 07:00 AM!"
		_next_btn.visible = false

func show_fail_result(title_str: String, reason_str: String, tip_str: String) -> void:
	_pause_overlay.visible = false
	_result_overlay.visible = true
	_res_badge_lbl.text = "ĐIỂM TÍN CHỈ: F  (HỌC LẠI!)"
	_res_badge_lbl.add_theme_color_override("font_color", DUTTheme.DUT_RED)
	_res_title_lbl.text = title_str
	_res_title_lbl.add_theme_color_override("font_color", Color("#FCA5A5"))
	_res_stats_lbl.text = reason_str
	_res_comment_lbl.text = "💡 Mẹo sinh tồn DUT: " + tip_str
	_next_btn.visible = false

func _process(delta: float) -> void:
	if _toast_timer > 0.0:
		_toast_timer -= delta
		if _toast_timer < 0.5:
			_toast_label.modulate.a = clampf(_toast_timer / 0.5, 0.0, 1.0)
	elif _toast_label != null and _toast_label.modulate.a > 0.0:
		_toast_label.modulate.a = 0.0
