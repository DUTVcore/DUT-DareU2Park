extends Control

class AnimatedLotBg extends Control:
	var _t: float = 0.0
	var _tex_wave: Texture2D
	var _tex_ex: Texture2D
	var _tex_vis: Texture2D

	func _ready() -> void:
		if ResourceLoader.exists("res://assets/sprites/vehicles/parked_wave_blue.png"):
			_tex_wave = load("res://assets/sprites/vehicles/parked_wave_blue.png")
		if ResourceLoader.exists("res://assets/sprites/vehicles/parked_exciter_gp.png"):
			_tex_ex = load("res://assets/sprites/vehicles/parked_exciter_gp.png")
		if ResourceLoader.exists("res://assets/sprites/vehicles/parked_vision_white.png"):
			_tex_vis = load("res://assets/sprites/vehicles/parked_vision_white.png")

	func _process(delta: float) -> void:
		_t += delta
		queue_redraw()

	func _draw() -> void:
		var s := get_viewport_rect().size
		draw_rect(Rect2(Vector2.ZERO, s), Color("#1E242D"), true)

		# Painted parking bays left & right background decoration
		var line_col := Color(0.95, 0.75, 0.12, 0.16)
		for y in range(40, int(s.y) - 20, 56):
			draw_line(Vector2(24, y), Vector2(140, y), line_col, 2.0)
			draw_line(Vector2(s.x - 140, y), Vector2(s.x - 24, y), line_col, 2.0)

		# Center road dashed divider
		var dash_offset := fmod(_t * 70.0, 48.0)
		for y in range(-48, int(s.y) + 48, 48):
			var py := float(y) + dash_offset
			draw_rect(Rect2(s.x * 0.5 - 3, py, 6, 24), Color(1, 1, 1, 0.08), true)

		# Cruising background bikes
		if _tex_wave:
			var y1 := s.y + 80.0 - fmod(_t * 115.0, s.y + 180.0)
			draw_texture(_tex_wave, Vector2(185, y1), Color(1, 1, 1, 0.35))
		if _tex_ex:
			var y2 := s.y + 80.0 - fmod(_t * 155.0 + 260.0, s.y + 180.0)
			draw_texture(_tex_ex, Vector2(s.x - 245, y2), Color(1, 1, 1, 0.35))
		if _tex_vis:
			var y3 := s.y + 80.0 - fmod(_t * 95.0 + 480.0, s.y + 180.0)
			draw_texture(_tex_vis, Vector2(245, y3), Color(1, 1, 1, 0.28))

		# Subtle dark navy vignette overlay
		draw_rect(Rect2(Vector2.ZERO, s), Color(0.03, 0.08, 0.16, 0.62), true)

var _bike_preview: TextureRect
var _bike_name_lbl: Label
var _bike_sub_lbl: Label
var _bike_desc_lbl: Label
var _bar_speed: ProgressBar
var _bar_steer: ProgressBar
var _bar_hp: ProgressBar
var _bike_buttons: Array[Button] = []
var _mute_btn: Button
var _help_modal: ColorRect

func _ready() -> void:
	theme = DUTTheme.get_theme()
	AudioManager.play_bgm("menu")
	_build_ui()
	_refresh_bike_card()

func _build_ui() -> void:
	var bg := AnimatedLotBg.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var root_margin := MarginContainer.new()
	root_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 42)
	root_margin.add_theme_constant_override("margin_right", 42)
	root_margin.add_theme_constant_override("margin_top", 24)
	root_margin.add_theme_constant_override("margin_bottom", 20)
	add_child(root_margin)

	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 16)
	root_margin.add_child(main_vbox)

	# University Header Banner
	var uni_banner := PanelContainer.new()
	uni_banner.add_theme_stylebox_override("panel", DUTTheme.make_box(DUTTheme.DUT_NAVY, DUTTheme.DUT_GOLD, 2, 14))
	main_vbox.add_child(uni_banner)

	var head_vbox := VBoxContainer.new()
	head_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	head_vbox.add_theme_constant_override("separation", 3)
	uni_banner.add_child(head_vbox)

	var uni_lbl := Label.new()
	uni_lbl.text = "TRƯỜNG ĐẠI HỌC BÁCH KHOA – ĐẠI HỌC ĐÀ NẴNG  •  54 NGUYỄN LƯƠNG BẰNG"
	uni_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	uni_lbl.add_theme_font_override("font", DUTTheme.get_bold_font())
	uni_lbl.add_theme_font_size_override("font_size", 13)
	uni_lbl.add_theme_color_override("font_color", DUTTheme.DUT_LIGHT_BLUE)
	head_vbox.add_child(uni_lbl)

	var title_lbl := Label.new()
	title_lbl.text = "🛵 D.U.T : DARE U TO PARK"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_override("font", DUTTheme.get_bold_font())
	title_lbl.add_theme_font_size_override("font_size", 36)
	title_lbl.add_theme_color_override("font_color", DUTTheme.DUT_GOLD)
	head_vbox.add_child(title_lbl)

	var tag_lbl := Label.new()
	tag_lbl.text = "Đại chiến sinh tồn Nhà xe Bách Khoa: Quẹt thẻ từ, né ổ voi Liên Chiểu, gập gương lách khe 15cm & gạt chống trước 07:00 AM!"
	tag_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tag_lbl.add_theme_font_size_override("font_size", 14)
	tag_lbl.add_theme_color_override("font_color", DUTTheme.DUT_MUTED)
	head_vbox.add_child(tag_lbl)

	# Content Split: Left (Action Menu) | Right (Student ID & Bike Selection Card)
	var body_hbox := HBoxContainer.new()
	body_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_hbox.add_theme_constant_override("separation", 24)
	main_vbox.add_child(body_hbox)

	# Left Menu Column
	var left_card := PanelContainer.new()
	left_card.custom_minimum_size = Vector2(430, 0)
	left_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_hbox.add_child(left_card)

	var left_vbox := VBoxContainer.new()
	left_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	left_vbox.add_theme_constant_override("separation", 14)
	left_card.add_child(left_vbox)

	var stars_lbl := Label.new()
	stars_lbl.text = "⭐ Thành tích tích lũy: %d / %d Sao Tín Chỉ" % [GameManager.get_total_stars(), GameManager.LEVELS.size() * 3]
	stars_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stars_lbl.add_theme_font_override("font", DUTTheme.get_bold_font())
	stars_lbl.add_theme_color_override("font_color", DUTTheme.DUT_GOLD)
	left_vbox.add_child(stars_lbl)

	var play_btn := Button.new()
	var next_lvl := GameManager.get_level_data(GameManager.unlocked_level)
	play_btn.text = "▶ VÀO ĐỖ XE NGAY (%s)" % next_lvl["code"]
	play_btn.custom_minimum_size = Vector2(0, 54)
	play_btn.add_theme_font_size_override("font_size", 18)
	DUTTheme.style_accent_button(play_btn, Color("#15803D"), DUTTheme.DUT_GOLD)
	play_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		GameManager.start_level(GameManager.unlocked_level)
	)
	left_vbox.add_child(play_btn)

	var map_btn := Button.new()
	map_btn.text = "🗺 BẢN ĐỒ 5 KHU NHÀ XE BÁCH KHOA"
	map_btn.custom_minimum_size = Vector2(0, 48)
	map_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		GameManager.go_to_level_select()
	)
	left_vbox.add_child(map_btn)

	var help_btn := Button.new()
	help_btn.text = "📖 CẨM NANG GỬI XE TÂN SINH VIÊN"
	help_btn.custom_minimum_size = Vector2(0, 46)
	help_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		_help_modal.visible = true
	)
	left_vbox.add_child(help_btn)

	_mute_btn = Button.new()
	_mute_btn.custom_minimum_size = Vector2(0, 44)
	_refresh_mute_btn()
	_mute_btn.pressed.connect(func():
		AudioManager.toggle_mute()
		if not AudioManager.is_muted:
			AudioManager.play_bgm("menu")
		_refresh_mute_btn()
	)
	left_vbox.add_child(_mute_btn)

	# Right Student Bike Garage Card
	var right_card := PanelContainer.new()
	right_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_hbox.add_child(right_card)

	var right_vbox := VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 12)
	right_card.add_child(right_vbox)

	var id_header := Label.new()
	id_header.text = "🪪 THẺ GỬI XE SINH VIÊN TÍCH HỢP  •  CHỌN CHIẾN MÃ ĐẾN TRƯỜNG"
	id_header.add_theme_font_override("font", DUTTheme.get_bold_font())
	id_header.add_theme_font_size_override("font_size", 16)
	id_header.add_theme_color_override("font_color", DUTTheme.DUT_GOLD)
	right_vbox.add_child(id_header)

	# Bike selector tabs
	var tab_row := HBoxContainer.new()
	tab_row.add_theme_constant_override("separation", 10)
	right_vbox.add_child(tab_row)

	for b in GameManager.BIKES:
		var b_id: String = b["id"]
		var btn := Button.new()
		btn.text = b["name"]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.pressed.connect(func():
			AudioManager.play_sfx("click")
			GameManager.selected_bike_id = b_id
			GameManager.save_progress()
			_refresh_bike_card()
		)
		tab_row.add_child(btn)
		_bike_buttons.append(btn)

	# Preview + Stats
	var detail_hbox := HBoxContainer.new()
	detail_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	detail_hbox.add_theme_constant_override("separation", 20)
	right_vbox.add_child(detail_hbox)

	var preview_panel := PanelContainer.new()
	preview_panel.custom_minimum_size = Vector2(165, 190)
	preview_panel.add_theme_stylebox_override("panel", DUTTheme.make_box(Color(0.04, 0.08, 0.14, 0.95), DUTTheme.DUT_LIGHT_BLUE, 2, 12))
	detail_hbox.add_child(preview_panel)

	var prev_center := CenterContainer.new()
	preview_panel.add_child(prev_center)

	_bike_preview = TextureRect.new()
	_bike_preview.custom_minimum_size = Vector2(96, 132)
	_bike_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_bike_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	prev_center.add_child(_bike_preview)

	var stats_vbox := VBoxContainer.new()
	stats_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	stats_vbox.add_theme_constant_override("separation", 8)
	detail_hbox.add_child(stats_vbox)

	_bike_name_lbl = Label.new()
	_bike_name_lbl.add_theme_font_override("font", DUTTheme.get_bold_font())
	_bike_name_lbl.add_theme_font_size_override("font_size", 20)
	stats_vbox.add_child(_bike_name_lbl)

	_bike_sub_lbl = Label.new()
	_bike_sub_lbl.add_theme_font_override("font", DUTTheme.get_bold_font())
	_bike_sub_lbl.add_theme_font_size_override("font_size", 14)
	_bike_sub_lbl.add_theme_color_override("font_color", DUTTheme.DUT_LIGHT_BLUE)
	stats_vbox.add_child(_bike_sub_lbl)

	_bike_desc_lbl = Label.new()
	_bike_desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bike_desc_lbl.add_theme_font_size_override("font_size", 14)
	_bike_desc_lbl.add_theme_color_override("font_color", DUTTheme.DUT_MUTED)
	stats_vbox.add_child(_bike_desc_lbl)

	_bar_speed = _create_stat_row(stats_vbox, "⚡ Tốc độ tối đa:", Color("#F59E0B"))
	_bar_steer = _create_stat_row(stats_vbox, "🔄 Độ dẻo tay lái:", Color("#38BDF8"))
	_bar_hp = _create_stat_row(stats_vbox, "🛡 Độ bền dàn áo:", Color("#22C55E"))

	var footer := Label.new()
	footer.text = "Vé lượt xe máy: 3.000đ  •  Nhà xe mở cửa 06:00 – 21:15 (Không nhận giữ xe qua đêm, nhớ dắt qua KTX Ngô Sĩ Liên!)"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 12)
	footer.add_theme_color_override("font_color", Color(0.72, 0.80, 0.90, 0.85))
	main_vbox.add_child(footer)

	_build_help_modal()

func _create_stat_row(parent: VBoxContainer, label_txt: String, fill_col: Color) -> ProgressBar:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	parent.add_child(row)

	var lbl := Label.new()
	lbl.text = label_txt
	lbl.custom_minimum_size = Vector2(145, 0)
	lbl.add_theme_font_size_override("font_size", 13)
	row.add_child(lbl)

	var bar := ProgressBar.new()
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.custom_minimum_size = Vector2(120, 14)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.max_value = 100.0
	bar.show_percentage = false
	var bg := DUTTheme.make_box(Color(0.12, 0.16, 0.24), Color(0.28, 0.34, 0.44), 1, 5)
	bg.shadow_size = 0
	var fg := DUTTheme.make_box(fill_col, fill_col, 0, 5)
	fg.shadow_size = 0
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fg)
	row.add_child(bar)
	return bar

func _refresh_bike_card() -> void:
	var b := GameManager.get_selected_bike_data()
	var path: String = b["sprite"]
	if ResourceLoader.exists(path):
		_bike_preview.texture = load(path)
	_bike_name_lbl.text = "%s — \"%s\"" % [b["name"], b["nickname"]]
	_bike_sub_lbl.text = "Biển số miền Trung: %s   •   Độ bền: %d HP" % [b["plate"], int(b["max_hp"])]
	_bike_desc_lbl.text = b["desc"]
	_bar_speed.value = clampf((float(b["max_speed"]) - 180.0) / 1.30, 20.0, 100.0)
	_bar_steer.value = clampf((float(b["steer_speed"]) - 2.6) * 72.0, 20.0, 100.0)
	_bar_hp.value = clampf(float(b["max_hp"]) / 1.30, 20.0, 100.0)

	for i in range(GameManager.BIKES.size()):
		var is_sel: bool = GameManager.BIKES[i]["id"] == GameManager.selected_bike_id
		if is_sel:
			DUTTheme.style_accent_button(_bike_buttons[i], Color("#1D4ED8"), DUTTheme.DUT_GOLD)
		else:
			DUTTheme.style_accent_button(_bike_buttons[i], Color(0.10, 0.18, 0.30, 0.9), Color(0.25, 0.38, 0.58))

func _refresh_mute_btn() -> void:
	if _mute_btn:
		_mute_btn.text = "🔇 Âm Thanh: ĐANG TẮT [M]" if AudioManager.is_muted else "🔊 Âm Thanh: ĐANG BẬT [M]"

func _build_help_modal() -> void:
	_help_modal = ColorRect.new()
	_help_modal.set_anchors_preset(Control.PRESET_FULL_RECT)
	_help_modal.color = Color(0.02, 0.05, 0.12, 0.85)
	_help_modal.visible = false
	add_child(_help_modal)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	_help_modal.add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(680, 440)
	card.add_theme_stylebox_override("panel", DUTTheme.make_box(DUTTheme.DUT_PANEL_BG, DUTTheme.DUT_GOLD, 2, 16))
	center.add_child(card)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 12)
	card.add_child(vb)

	var h_title := Label.new()
	h_title.text = "📖 CẨM NANG SINH TỒN NHÀ XE ĐH BÁCH KHOA ĐÀ NẴNG"
	h_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	h_title.add_theme_font_override("font", DUTTheme.get_bold_font())
	h_title.add_theme_font_size_override("font_size", 20)
	h_title.add_theme_color_override("font_color", DUTTheme.DUT_GOLD)
	vb.add_child(h_title)

	var guide := Label.new()
	guide.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	guide.add_theme_font_size_override("font_size", 15)
	guide.text = (
		"1. ĐIỀU KHIỂN XE MÁY:\n" +
		"   • [W / ↑] Vặn ga tiến   • [S / ↓] Phanh gấp & Lùi chân   • [A / D hoặc ← / →] Đánh lái trái/phải\n\n" +
		"2. KỸ NĂNG ĐẶC SẢN NHÀ XE BÁCH KHOA:\n" +
		"   • [E hoặc Shift] GẬP / MỞ GƯƠNG: Gập gương giúp thu gọn bề ngang xe để lách qua 'Rừng gương chiếu hậu' khe hẹp 15cm mà không bị trừ HP! Mở gương giúp chạy nhanh hơn và có vạch căn lùi xe.\n" +
		"   • [F hoặc H] BÓP CÒI: Nhắc các bạn sinh viên đi bộ hoặc xe máy đang chạy trước mặt dừng lại nhường đường.\n" +
		"   • TRẠM THẺ TỪ: Chạy vào ô xanh trước Barie để tự động quẹt Thẻ Sinh Viên mở cổng.\n" +
		"   • ĐỊA HÌNH: Đi chậm qua gờ giảm tốc & né ổ gà, đặc biệt coi chừng vũng nước sẫm màu mùa mưa Liên Chiểu ngụy trang ổ voi sâu!\n\n" +
		"3. GẠT CHÂN CHỐNG HOÀN THÀNH:\n" +
		"   • Đưa xe lọt vào Ô ĐỖ TRỐNG đúng chiều mũi tên chỉ hướng, dừng xe và bấm [SPACE] trước 07:00:00 AM!"
	)
	vb.add_child(guide)

	var close_btn := Button.new()
	close_btn.text = "Đã Hiểu – Sẵn Sàng Vào Trường!"
	DUTTheme.style_accent_button(close_btn, Color("#15803D"), DUTTheme.DUT_GOLD)
	close_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		_help_modal.visible = false
	)
	vb.add_child(close_btn)
