extends "res://scenes/levels/BaseLevel.gd"

func _init() -> void:
	level_index = 0
	lot_bounds = Rect2(-480, -860, 960, 1120)
	player_spawn_pos = Vector2(0, 175)
	player_spawn_rot_deg = 0.0
	fail_tip = "Chạy vào ô xanh trước Barie để tự quẹt thẻ SV, né ổ gà và dựng xe thẳng theo mũi tên vàng ở Ô E-09!"

func _build_level_layout() -> void:
	add_floor_label(Vector2(0, 230), "⬆ CỔNG PHỤ 60 NGÔ SĨ LIÊN – ĐH BÁCH KHOA ĐÀ NẴNG", Color("#F5B700"), 16)

	# Gate perimeter wall forcing passage through the RFID CardGate at (0, 0)
	add_card_gate(Vector2(0, 0), "CỔNG NGÔ SĨ LIÊN")
	add_wall_rect(Rect2(-480, -28, 358, 56), "TƯỜNG RÀO NGÔ SĨ LIÊN", Color("#1E3A5F"))
	add_wall_rect(Rect2(68, -28, 412, 56), "LỐI KÝ TÚC XÁ BÁCH KHOA", Color("#1E3A5F"))

	# Campus building at far north
	add_wall_rect(Rect2(-480, -860, 960, 72), "GIẢNG ĐƯỜNG KHU E  •  PHÒNG E104 (GIẢI TÍCH 1 - 07:00 AM)", Color("#0F294A"))

	# Driveway speed bump & potholes
	add_speed_bump(Vector2(0, -115), 0.0, 1.15)
	add_floor_label(Vector2(0, -78), "GIẢM TỐC ĐỘ KHI QUA GỜ", Color(1, 1, 1, 0.40), 13)

	add_pothole(Vector2(-46, -210), 5.5)
	add_pothole(Vector2(52, -285), 5.5)
	add_pothole(Vector2(-155, -315), 5.0)

	# Friendly freshman walking across yard (test horn [F]!)
	add_moving_hazard(Vector2(-170, -345), Vector2(340, 0), "student_walker", 48.0)

	# Khu E Covered Shed Roof
	add_shed_roof(Rect2(-420, -745, 840, 350), "MÁI TÔN NHÀ XE SINH VIÊN KHU E")
	add_floor_label(Vector2(0, -565), "LỐI ĐI NHÀ XE KHU E – DỰNG THẲNG HÀNG", Color(1, 1, 1, 0.35), 14)

	# Support pillars
	add_pillar(Vector2(-250, -565))
	add_pillar(Vector2(250, -565))

	# Front parked row (leaving wide central entrance at indices 6, 7, 8)
	add_parked_row(Vector2(-350, -455), 15, Vector2(50, 0), 0.0, [6, 7, 8], 3.5)

	# Back parked row (skipping index 9 at x = +100 for Target ParkingSlot!)
	add_parked_row(Vector2(-350, -675), 15, Vector2(50, 0), 0.0, [9], 3.0)
	set_target_slot(Vector2(100, -675), 0.0, "Ô E-09", 18.0)
