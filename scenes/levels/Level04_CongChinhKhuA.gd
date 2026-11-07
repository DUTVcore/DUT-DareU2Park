extends "res://scenes/levels/BaseLevel.gd"

func _init() -> void:
	level_index = 3
	lot_bounds = Rect2(-580, -1120, 1160, 1360)
	player_spawn_pos = Vector2(-260, 165)
	player_spawn_rot_deg = 0.0
	fail_tip = "Ở nhà xe Khu A bắt buộc QUAY ĐẦU XE RA NGOÀI (mũi tên hướng xuống)! Hãy mở gương [E] để thấy vạch xanh hỗ trợ LÙI CHUỒNG [S]!"

func _build_level_layout() -> void:
	add_floor_label(Vector2(-260, 220), "⬆ CỔNG CHÍNH 54 NGUYỄN LƯƠNG BẰNG – ĐH BÁCH KHOA ĐÀ NẴNG", Color("#F5B700"), 15)

	# Main Gate 54 Nguyen Luong Bang at (-260, 10)
	add_card_gate(Vector2(-260, 10), "CỔNG 54 N.L.BẰNG")
	add_wall_rect(Rect2(-580, -18, 200, 56), "TƯỜNG CỔNG CHÍNH", Color("#1E3A5F"))
	add_wall_rect(Rect2(-192, -18, 772, 56), "HÀNG RÀO MẶT TIỀN NGUYỄN LƯƠNG BẰNG", Color("#1E3A5F"))

	# Campus Buildings: Khu A Admin Building & Smart Building Khu S
	add_wall_rect(Rect2(-580, -1120, 480, 280), "KHU HÀNH CHÍNH A (VĂN PHÒNG KHOA)", Color("#0F294A"))
	add_wall_rect(Rect2(-100, -1120, 680, 74), "TRUNG TÂM HỌC LIỆU & TRUYỀN THÔNG (SMART BUILDING KHU S)", Color("#0F294A"))

	add_speed_bump(Vector2(-260, -105), 0.0, 1.15)

	# Lecturer & VIP Cars parked along Khu A avenue (DO NOT SCRATCH!)
	add_floor_label(Vector2(-440, -340), "Ô TÔ GIẢNG VIÊN\n(CẤM VA QUẸT!)", Color("#EF4444"), 13)
	add_lecturer_car(Vector2(-460, -240), 0.0)
	add_lecturer_car(Vector2(-460, -450), 0.0)
	add_lecturer_car(Vector2(-85, -310), 180.0)

	add_pothole(Vector2(-255, -355), 5.5)
	add_speed_bump(Vector2(-260, -540), 0.0, 1.25)

	# Boulevard turns East at y = -710 directly into Khu A-S Shed!
	add_floor_label(Vector2(-220, -715), "RẼ PHẢI SANG NHÀ XE KHU A-S ➔", Color("#38BDF8"), 15)

	# Patrolling Security Guard reminding students to back in!
	add_moving_hazard(Vector2(20, -675), Vector2(300, 0), "security_guard", 50.0)

	# Covered Shed Khu A - S on the Northeast side
	add_shed_roof(Rect2(-40, -995, 580, 485), "NHÀ XE KHU A - SMART BUILDING (QUAY ĐẦU RA NGOÀI)")

	# South row of Khu A-S shed (y = -555)
	add_parked_row(Vector2(20, -555), 11, Vector2(48, 0), 0.0, [], 2.5)

	# Wide maneuvering lane (y = -640 .. -810) with clear reverse-parking instructions!
	add_floor_label(Vector2(260, -745), "⬇ QUAY ĐẦU XE RA NGOÀI – BẤM [S] LÙI ĐUÔI VÀO Ô!", Color("#F5B700"), 14)
	add_pillar(Vector2(115, -735))
	add_pillar(Vector2(435, -735))

	# North row (y = -905): All bikes neatly parked facing OUTWARD (180 deg)!
	# Target slot at index 6 (x = +308), facing 180.0 deg!
	add_parked_row(Vector2(20, -905), 11, Vector2(48, 0), 180.0, [6], 2.0)
	set_target_slot(Vector2(308, -905), 180.0, "QUAY ĐẦU RA", 17.5)
