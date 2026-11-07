extends "res://scenes/levels/BaseLevel.gd"

func _init() -> void:
	level_index = 1
	lot_bounds = Rect2(-520, -1040, 1040, 1260)
	player_spawn_pos = Vector2(-320, 130)
	player_spawn_rot_deg = 0.0
	fail_tip = "Bấm [E] hoặc [Shift] GẬP GƯƠNG trước khi chui qua các khe hẹp giữa cột sắt và gương xe bạn nhé!"

func _build_level_layout() -> void:
	add_wall_rect(Rect2(-520, -1040, 1040, 70), "NHÀ GIỮ XE CHÍNH KHU B  •  LỐI LÊN GIẢNG ĐƯỜNG B203", Color("#0F294A"))
	add_floor_label(Vector2(-320, 190), "⬆ LỐI VÀO NHÀ XE KHU B (06:57 AM)", Color("#F5B700"), 15)

	# Two giant corrugated metal sheds of Khu B
	add_shed_roof(Rect2(-470, -410, 940, 440), "NHÀ XE KHU B – DÃY NGOÀI")
	add_shed_roof(Rect2(-470, -935, 940, 465), "NHÀ XE KHU B – RỪNG GƯƠNG CHIẾU HẬU")

	add_speed_bump(Vector2(-320, 50), 0.0, 1.0)

	# Row 1 (South row, full on the right, open entry on the left around x=-320)
	add_parked_row(Vector2(-150, -35), 11, Vector2(50, 0), 0.0, [], 5.0)

	# Aisle 1 going East (y = -155): Pothole + Student walking
	add_floor_label(Vector2(-80, -150), "RẼ PHẢI ➔ CHÚ Ý KHE HẸP GƯƠNG XE!", Color("#38BDF8"), 14)
	add_pothole(Vector2(-60, -165), 5.5)
	add_moving_hazard(Vector2(60, -155), Vector2(220, 0), "student_walker", 50.0)

	# Row 2 (y = -285): Full on left & center, narrow gap on the FAR RIGHT around x = +345!
	# Let's craft Bottleneck #1 at x = +345, y = -285:
	# Left side of gap: GaragePillar at (310, -285) -> right edge at 326.
	# Right side of gap: ParkedBike at (388, -285) -> left mirror at 363.5 (gap = 37.5 px -> requires [E] Fold Mirrors!).
	add_parked_row(Vector2(-410, -285), 14, Vector2(50, 0), 0.0, [], 5.5, [4, 9], Vector2(0, 12))
	add_pillar(Vector2(310, -285))
	add_parked_bike(Vector2(388, -285), 0.0, 4)
	add_parked_bike(Vector2(438, -285), 2.0, 2)
	add_floor_label(Vector2(348, -210), "⚠ KHE 15CM [E]", Color("#F5B700"), 13)

	# Middle Cross Aisle going West (y = -435): Patrolling Security Guard!
	add_moving_hazard(Vector2(180, -435), Vector2(-360, 0), "security_guard", 52.0)
	add_floor_label(Vector2(0, -435), "⬅ LÁCH QUA TRÁI VÀO DÃY TRONG", Color("#38BDF8"), 14)

	# Row 3 (y = -575): Narrow 15cm Mirror Forest Bottleneck #2 on the LEFT around x = -312!
	# Pillar at (-348, -575) -> right edge -332; ParkedBike at (-270, -575) -> left mirror -294.5 (gap = 37.5 px!).
	add_parked_bike(Vector2(-425, -575), -3.0, 1)
	add_pillar(Vector2(-348, -575))
	add_parked_row(Vector2(-270, -575), 14, Vector2(50, 0), 0.0, [], 6.0, [2, 7, 11], Vector2(0, 14))
	add_floor_label(Vector2(-310, -500), "⚠ GẬP GƯƠNG [E]!", Color("#F5B700"), 13)

	# Upper Aisle going East (y = -720) with Bottleneck #3 near x = +40!
	add_pillar(Vector2(40, -682))
	# Bike jutting down from Row 4 or Row 3 creates tight chicane, plus pothole at (-120, -720)
	add_pothole(Vector2(-135, -720), 6.0)

	# Row 4 (Back row, y = -855): Packed full EXCEPT Target Slot at index 13 (x = +240)!
	add_parked_row(Vector2(-410, -855), 17, Vector2(50, 0), 0.0, [13], 5.0)
	set_target_slot(Vector2(240, -855), 0.0, "Ô B-42", 17.0)
