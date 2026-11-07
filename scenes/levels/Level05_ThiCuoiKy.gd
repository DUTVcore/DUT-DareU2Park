extends "res://scenes/levels/BaseLevel.gd"

func _init() -> void:
	level_index = 4
	lot_bounds = Rect2(-600, -1320, 1200, 1560)
	player_spawn_pos = Vector2(0, 165)
	player_spawn_rot_deg = 0.0
	fail_tip = "Bình tĩnh quẹt thẻ, né vũng nước đục, gập gương [E] qua 2 nút thắt cổ chai và lách tới góc Tây-Bắc cuối nhà xe trước 07:00!"

func _build_level_layout() -> void:
	add_floor_label(Vector2(0, 220), "🚨 06:58:20 AM – NGÀY THI CUỐI KỲ! CÒN ĐÚNG 1 CHỖ ĐỖ CUỐI NHÀ XE!", Color("#EF4444"), 15)

	# Phase 1: Gate + Rainy Pothole Gauntlet
	add_card_gate(Vector2(0, 15), "CỔNG THI CUỐI KỲ")
	add_wall_rect(Rect2(-600, -13, 478, 56), "TƯỜNG RÀO BÁCH KHOA", Color("#1E3A5F"))
	add_wall_rect(Rect2(68, -13, 532, 56), "TƯỜNG RÀO BÁCH KHOA", Color("#1E3A5F"))

	add_wall_rect(Rect2(-600, -1320, 1200, 72), "PHÒNG THI C205 – CẤU TRÚC DỮ LIỆU & GIẢI THUẬT (ĐÓNG CỬA 07:00 AM)", Color("#0F294A"))

	add_speed_bump(Vector2(0, -95), 0.0, 1.2)
	add_puddle(Vector2(-55, -180), true, 8.5, Vector2(1.15, 1.05))
	add_puddle(Vector2(65, -235), false, 5.0, Vector2(1.1, 1.0))
	add_pothole(Vector2(-10, -280), 6.5)

	# Phase 2: Shed 1 (100% FULL DEC0Y LOT + Frantic Moving Bikes + Right Squeeze!)
	add_shed_roof(Rect2(-530, -740, 1060, 390), "DÃY NHÀ XE NGOÀI (ĐÃ KÍN HẾT CHỖ!)")
	add_floor_label(Vector2(0, -340), "DÃY NGOÀI HẾT SẠCH CHỖ RỒI – LÁCH SANG PHẢI RA DÃY SAU!", Color("#F5B700"), 14)

	# Row 1 (y = -425): Open middle entry (indices 9, 10), full everywhere else!
	add_parked_row(Vector2(-475, -425), 20, Vector2(50, 0), 0.0, [9, 10], 5.5, [4, 15], Vector2(0, 12))

	# Frantic student bike cruising aisle 1
	add_moving_hazard(Vector2(-320, -545), Vector2(580, 0), "moving_bike", 86.0)
	add_puddle(Vector2(130, -545), true, 8.0, Vector2(1.0, 1.0))

	# Row 2 (y = -665): Packed EXCEPT a 15cm Mirror Squeeze on the FAR RIGHT (x = +412)!
	# Pillar at (376, -665) -> right edge 392; ParkedBike at (454, -665) -> left mirror 429.5 (gap = 37.5 px!).
	add_parked_row(Vector2(-475, -665), 17, Vector2(50, 0), 0.0, [], 6.0, [3, 8, 13], Vector2(0, 14))
	add_pillar(Vector2(376, -665))
	add_parked_bike(Vector2(454, -665), 0.0, 4)
	add_parked_bike(Vector2(504, -665), -3.0, 1)
	add_floor_label(Vector2(414, -595), "⚠ KHE 15CM [E]", Color("#F5B700"), 13)

	# Phase 3: Cross-avenue with Lecturer Car, Guard & Rain Puddles (y = -795)
	add_lecturer_car(Vector2(175, -805), 90.0)
	add_puddle(Vector2(-40, -795), false, 5.0, Vector2(1.2, 1.0))
	add_moving_hazard(Vector2(-120, -825), Vector2(-320, 0), "security_guard", 56.0)
	add_speed_bump(Vector2(412, -765), 0.0, 0.95)

	# Deepest Shed 2 (y = -900 .. -1230)
	add_shed_roof(Rect2(-530, -1235, 1060, 330), "DÃY NHÀ XE SÂU NHẤT – CÒN ĐÚNG 1 Ô TRỐNG!")

	# Row 3 (y = -965): Narrow 15cm Mirror Squeeze near center-left (x = -138)!
	# Pillar at (-174, -965) -> right edge -158; ParkedBike at (-96, -965) -> left mirror -120.5 (gap = 37.5 px!).
	add_parked_row(Vector2(-475, -965), 6, Vector2(50, 0), 0.0, [], 5.5)
	add_pillar(Vector2(-174, -965))
	add_parked_row(Vector2(-96, -965), 13, Vector2(50, 0), 0.0, [], 5.5, [4, 9], Vector2(0, 13))
	add_floor_label(Vector2(-136, -895), "⚠ GẬP GƯƠNG [E]!", Color("#F5B700"), 13)

	# Final aisle (y = -1075): One more frantic student walker + pothole!
	add_moving_hazard(Vector2(-380, -1075), Vector2(310, 0), "student_walker", 54.0)
	add_pothole(Vector2(-235, -1075), 6.0)

	# Final Back Row 4 (y = -1175): Every single slot taken EXCEPT index 2 (x = -375)!
	add_parked_row(Vector2(-475, -1175), 20, Vector2(50, 0), 0.0, [2], 4.5)
	set_target_slot(Vector2(-375, -1175), 0.0, "CHỖ CUỐI!", 16.5)
