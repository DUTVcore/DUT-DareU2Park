extends Control

var _cards_container: VBoxContainer
var _unlock_btn: Button

func _ready() -> void:
	theme = DUTTheme.get_theme()
	AudioManager.play_bgm("menu")
	_build_ui()
	_populate_levels()

func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color("#071529")
	add_child(bg)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 14)
	margin.add_child(vbox)

	# Top Header Row
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 14)
	vbox.add_child(top_row)

	var back_btn := Button.new()
	back_btn.text = "⬅ Cổng Trường"
	back_btn.pressed.connect(func():
		AudioManager.play_sfx("click")
		GameManager.go_to_main_menu()
	)
	top_row.add_child(back_btn)

	var title := Label.new()
	title.text = "🗺 SƠ ĐỒ NHÀ XE ĐẠI HỌC BÁCH KHOA ĐÀ NẴNG (54 NGUYỄN LƯƠNG BẰNG)"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", DUTTheme.get_bold_font())
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", DUTTheme.DUT_GOLD)
	top_row.add_child(title)

	_unlock_btn = Button.new()
	_unlock_btn.text = "🔓 Mở Tất Cả Khu"
	_unlock_btn.visible = GameManager.unlocked_level < GameManager.LEVELS.size() - 1
	_unlock_btn.pressed.connect(func():
		AudioManager.play_sfx("card_beep")
		GameManager.unlock_all_levels()
		_unlock_btn.visible = false
		_populate_levels()
	)
	top_row.add_child(_unlock_btn)

	var sub_info := Label.new()
	var bike := GameManager.get_selected_bike_data()
	sub_info.text = "Chiến mã hiện tại: %s (%s)   •   Tổng sao đạt được: ★ %d / %d" % [
		bike["name"], bike["plate"], GameManager.get_total_stars(), GameManager.LEVELS.size() * 3
	]
	sub_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_info.add_theme_color_override("font_color", DUTTheme.DUT_LIGHT_BLUE)
	vbox.add_child(sub_info)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(scroll)

	_cards_container = VBoxContainer.new()
	_cards_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cards_container.add_theme_constant_override("separation", 12)
	scroll.add_child(_cards_container)

func _populate_levels() -> void:
	for ch in _cards_container.get_children():
		ch.queue_free()

	for i in range(GameManager.LEVELS.size()):
		var lv: Dictionary = GameManager.LEVELS[i]
		var unlocked: bool = i <= GameManager.unlocked_level
		var rec: Dictionary = GameManager.get_level_record(i)

		var card := PanelContainer.new()
		var border_col := DUTTheme.DUT_GOLD if unlocked else Color(0.28, 0.34, 0.44, 0.7)
		card.add_theme_stylebox_override("panel", DUTTheme.make_box(DUTTheme.DUT_PANEL_BG, border_col, 2, 12))
		_cards_container.add_child(card)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 16)
		card.add_child(row)

		# Left Code Badge
		var badge := PanelContainer.new()
		badge.custom_minimum_size = Vector2(115, 76)
		badge.add_theme_stylebox_override("panel", DUTTheme.make_box(DUTTheme.DUT_NAVY, border_col, 2, 10))
		row.add_child(badge)

		var badge_vb := VBoxContainer.new()
		badge_vb.alignment = BoxContainer.ALIGNMENT_CENTER
		badge.add_child(badge_vb)

		var code_lbl := Label.new()
		code_lbl.text = lv["code"]
		code_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		code_lbl.add_theme_font_override("font", DUTTheme.get_bold_font())
		code_lbl.add_theme_font_size_override("font_size", 16)
		code_lbl.add_theme_color_override("font_color", DUTTheme.DUT_GOLD)
		badge_vb.add_child(code_lbl)

		var stars_cnt := int(rec.get("stars", 0))
		var rec_lbl := Label.new()
		rec_lbl.text = ("Hạng %s • " % rec["grade"] + "★".repeat(stars_cnt) + "☆".repeat(3 - stars_cnt)) if stars_cnt > 0 else "Chưa đỗ"
		rec_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		rec_lbl.add_theme_font_size_override("font_size", 12)
		rec_lbl.add_theme_color_override("font_color", DUTTheme.DUT_GREEN if stars_cnt > 0 else DUTTheme.DUT_MUTED)
		badge_vb.add_child(rec_lbl)

		# Center Description
		var info_vb := VBoxContainer.new()
		info_vb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info_vb.add_theme_constant_override("separation", 3)
		row.add_child(info_vb)

		var name_lbl := Label.new()
		name_lbl.text = "%s   |   %s" % [lv["title"], lv["difficulty"]]
		name_lbl.add_theme_font_override("font", DUTTheme.get_bold_font())
		name_lbl.add_theme_font_size_override("font_size", 16)
		info_vb.add_child(name_lbl)

		var course_lbl := Label.new()
		var start_clk := GameManager.format_campus_clock(int(lv["start_seconds_before_7am"]), 0.0)
		course_lbl.text = "📚 Tiết 1: %s   •   Xuất phát lúc: %s" % [lv["course"], start_clk]
		course_lbl.add_theme_font_size_override("font_size", 13)
		course_lbl.add_theme_color_override("font_color", DUTTheme.DUT_LIGHT_BLUE)
		info_vb.add_child(course_lbl)

		var brief_lbl := Label.new()
		brief_lbl.text = lv["brief"]
		brief_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		brief_lbl.add_theme_font_size_override("font_size", 13)
		brief_lbl.add_theme_color_override("font_color", DUTTheme.DUT_MUTED)
		info_vb.add_child(brief_lbl)

		# Right Play Button
		var go_btn := Button.new()
		go_btn.custom_minimum_size = Vector2(148, 52)
		go_btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		if unlocked:
			go_btn.text = "VÀO ĐỖ XE ➔"
			DUTTheme.style_accent_button(go_btn, Color("#15803D"), DUTTheme.DUT_GOLD)
			var target_idx := i
			go_btn.pressed.connect(func():
				AudioManager.play_sfx("click")
				GameManager.start_level(target_idx)
			)
		else:
			go_btn.text = "🔒 Chưa Mở"
			go_btn.disabled = true
		row.add_child(go_btn)
