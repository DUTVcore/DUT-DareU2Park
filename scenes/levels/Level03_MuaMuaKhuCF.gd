extends "res://scenes/levels/BaseLevel.gd"

func _init() -> void:
	level_index = 2
	lot_bounds = Rect2(-540, -1080, 1080, 1300)
	player_spawn_pos = Vector2(0, 145)
	player_spawn_rot_deg = 0.0
	fail_tip = "Né các vũng nước MÀU XANH ĐỤC SẪM (có ổ voi ngầm bên dưới) và rà phanh sớm vì đường mưa Liên Chiểu rất trơn!"

func _build_level_layout() -> void:
	add_wall_rect(Rect2(-540, -1080, 1080, 72), "HỘI TRƯỜNG KHU F & GIẢNG ĐƯỜNG KHU C (MÙA MƯA ĐÀ NẴNG)", Color("#0F294A"))
	add_wall_rect(Rect2(-540, -520, 140, 520), "DÃY NHÀ KHU C", Color("#1E3A5F"))
	add_wall_rect(Rect2(400, -520, 140, 520), "SÂN HỘI TRƯỜNG F", Color("#1E3A5F"))

	add_floor_label(Vector2(0, 195), "🌧 ĐƯỜNG NỘI BỘ KHU C - F (CẨN THẬN VŨNG NƯỚC SẪM MÀU!)", Color("#38BDF8"), 14)

	# Rainy internal road hazards (y = +80 down to -540)
	add_puddle(Vector2(-75, 25), false, 5.0, Vector2(1.1, 1.0))
	add_puddle(Vector2(65, -55), true, 8.0, Vector2(1.15, 1.1)) # Deep hidden pothole!
	add_speed_bump(Vector2(0, -145), 0.0, 1.3)

	add_puddle(Vector2(-95, -235), true, 8.5, Vector2(1.2, 1.1)) # Deep hidden pothole!
	add_puddle(Vector2(90, -250), false, 5.0, Vector2(1.1, 1.0))
	add_pothole(Vector2(5, -325), 6.5)

	add_puddle(Vector2(-40, -415), false, 5.0, Vector2(1.25, 1.1))
	add_puddle(Vector2(115, -430), true, 8.5, Vector2(1.1, 1.1)) # Deep hidden pothole!

	# Another student bike rushing across near the shed entrance (Honk [F] to make them stop!)
	add_moving_hazard(Vector2(-260, -565), Vector2(520, 0), "moving_bike", 78.0)
	add_floor_label(Vector2(0, -530), "BẤM CÒI [F] NHẮC XE KHÁC NHƯỜNG ĐƯỜNG!", Color("#F5B700"), 13)

	# Covered Khu F Shed at the north end
	add_shed_roof(Rect2(-480, -985, 960, 380), "NHÀ XE HỘI TRƯỜNG KHU F")

	# Shed front row (y = -685): Two narrow entry gaps at index 3 (x=-250) and index 13 (x=+250), plus mirror squeeze!
	add_pillar(Vector2(-286, -685))
	add_parked_row(Vector2(-400, -685), 17, Vector2(50, 0), 0.0, [2, 3, 13], 5.5, [6, 10], Vector2(0, 12))

	# Wet puddle blown inside the shed aisle + walking student
	add_puddle(Vector2(-80, -785), false, 4.0, Vector2(0.95, 0.9))
	add_moving_hazard(Vector2(20, -790), Vector2(280, 0), "student_walker", 46.0)
	add_pillar(Vector2(0, -830))

	# Shed back row (y = -900): Target slot at index 3 (x = -250)
	add_parked_row(Vector2(-400, -900), 17, Vector2(50, 0), 0.0, [3], 5.0)
	set_target_slot(Vector2(-250, -900), 0.0, "Ô F-18", 17.5)
