extends Node

const SAVE_PATH := "user://dut_dare_u_to_park.cfg"

const BIKES := [
	{
		"id": "wave",
		"name": "Wave Alpha 110",
		"nickname": "Chiến Thần Tân Sinh Viên",
		"plate": "43-K1 547.89",
		"desc": "Nhỏ gọn, đánh lái cực dẻo trong nhà xe Khu B, tiết kiệm xăng cuối tháng.",
		"sprite": "res://assets/sprites/vehicles/bike_wave.png",
		"acceleration": 430.0,
		"max_speed": 245.0,
		"reverse_speed": 84.0,
		"friction": 265.0,
		"steer_speed": 3.85,
		"max_hp": 100.0,
		"pothole_resist": 1.0,
		"color_hex": "#186CD4",
	},
	{
		"id": "exciter",
		"name": "Exciter 150 Côn Tay",
		"nickname": "Idol Khoa Cơ Khí",
		"plate": "92-F1 686.86",
		"desc": "Đề-pa cực bốc cứu nguy sát 06:59 AM! Nhưng bán kính cua rộng, coi chừng quẹt gương.",
		"sprite": "res://assets/sprites/vehicles/bike_exciter.png",
		"acceleration": 545.0,
		"max_speed": 295.0,
		"reverse_speed": 86.0,
		"friction": 250.0,
		"steer_speed": 3.30,
		"max_hp": 90.0,
		"pothole_resist": 0.92,
		"color_hex": "#DC2A30",
	},
	{
		"id": "vision",
		"name": "Vision Smartkey",
		"nickname": "Trùm Cốp Đựng Giáo Trình",
		"plate": "75-G1 246.80",
		"desc": "Thân xe đầm chắc, phuộc êm ít trẹo lái khi sụp ổ gà Liên Chiểu, độ bền cao nhất.",
		"sprite": "res://assets/sprites/vehicles/bike_vision.png",
		"acceleration": 395.0,
		"max_speed": 232.0,
		"reverse_speed": 80.0,
		"friction": 275.0,
		"steer_speed": 3.60,
		"max_hp": 125.0,
		"pothole_resist": 1.30,
		"color_hex": "#E05880",
	},
]

const LEVELS := [
	{
		"index": 0,
		"code": "KHU E",
		"title": "Cổng Phụ Ngô Sĩ Liên – Nhà Xe Khu E",
		"course": "Giải Tích 1 (Phòng E104)",
		"difficulty": "★☆☆☆☆  Tân Sinh Viên",
		"scene": "res://scenes/levels/Level01_KhuE.tscn",
		"start_seconds_before_7am": 210, # 06:56:30 AM
		"real_time_limit": 75.0,
		"requires_card": true,
		"is_rainy": false,
		"brief": "Sáng đầu tuần qua cổng phụ 60 Ngô Sĩ Liên! Nhớ giảm tốc quẹt Thẻ Sinh Viên ở bốt bảo vệ, né ổ gà sân trường và dựng thẳng hàng trong nhà xe Khu E.",
	},
	{
		"index": 1,
		"code": "KHU B",
		"title": "Nhà Xe Khu B – Rừng Gương Cao Điểm",
		"course": "Vật Lý Đại Cương 1 (Phòng B203)",
		"difficulty": "★★☆☆☆  Khe Hẹp 15cm",
		"scene": "res://scenes/levels/Level02_KhuB.tscn",
		"start_seconds_before_7am": 180, # 06:57:00 AM
		"real_time_limit": 70.0,
		"requires_card": false,
		"is_rainy": false,
		"brief": "Nhà xe Khu B huyền thoại đông nghẹt lúc 06:57! Hàng trăm xe đỗ thò đuôi chĩa gương ra lối đi. Nhấn [E] hoặc [Shift] GẬP GƯƠNG để lách qua khe 15cm!",
	},
	{
		"index": 2,
		"code": "KHU C - F",
		"title": "Mùa Mưa Liên Chiểu – Lối Vào Khu C & Hội Trường F",
		"course": "Cơ Học Kỹ Thuật (Hội trường F)",
		"difficulty": "★★★☆☆  Trơn Trượt & Ổ Voi Ngầm",
		"scene": "res://scenes/levels/Level03_MuaMuaKhuCF.tscn",
		"start_seconds_before_7am": 165, # 06:57:15 AM
		"real_time_limit": 70.0,
		"requires_card": false,
		"is_rainy": true,
		"brief": "Đặc sản mưa dầm tháng 10 Đà Nẵng! Mặt sân trơn trượt, coi chừng những vũng nước đục sẫm màu ngụy trang ổ voi sâu bên dưới. Bấm còi [F] nhắc xe khác nhường đường!",
	},
	{
		"index": 3,
		"code": "KHU A - S",
		"title": "54 Nguyễn Lương Bằng – Khu A & Smart Building",
		"course": "Bảo Vệ Đồ Án (Khu A)",
		"difficulty": "★★★★☆  Quay Đầu Xe Ra Ngoài",
		"scene": "res://scenes/levels/Level04_CongChinhKhuA.tscn",
		"start_seconds_before_7am": 150, # 06:57:30 AM
		"real_time_limit": 68.0,
		"requires_card": true,
		"is_rainy": false,
		"brief": "Cổng chính 54 Nguyễn Lương Bằng ngày bảo vệ đồ án! Tuyệt đối đừng quẹt trúng ô tô giảng viên trước Khu A, và nhớ LÙI ĐUÔI / QUAY ĐẦU XE RA NGOÀI đúng hướng mũi tên!",
	},
	{
		"index": 4,
		"code": "FINAL EXAM",
		"title": "Đại Chiến Thi Cuối Kỳ – Nhà Xe Tổng Hợp DUT",
		"course": "Thi Cuối Kỳ Cấu Trúc Dữ Liệu (C205)",
		"difficulty": "★★★★★  Còn Đúng 1 Chỗ Đỗ!",
		"scene": "res://scenes/levels/Level05_ThiCuoiKy.tscn",
		"start_seconds_before_7am": 100, # 06:58:20 AM
		"real_time_limit": 65.0,
		"requires_card": true,
		"is_rainy": true,
		"brief": "Ngủ quên ở trọ Hòa Khánh, phi tới cổng trường lúc 06:58:20 AM dưới mưa! Mọi dãy đầu đều kín mít, chỉ còn duy nhất 1 ô trống sâu tít cuối nhà xe. Trễ 07:00 là CẤM THI!",
	},
]

var selected_bike_id: String = "wave"
var current_level_index: int = 0
var unlocked_level: int = 0
var level_records: Dictionary = {}

func _ready() -> void:
	_setup_input_actions()
	load_progress()

func _setup_input_actions() -> void:
	_register_keys("move_forward", [KEY_W, KEY_UP])
	_register_keys("move_backward", [KEY_S, KEY_DOWN])
	_register_keys("steer_left", [KEY_A, KEY_LEFT])
	_register_keys("steer_right", [KEY_D, KEY_RIGHT])
	_register_keys("kickstand", [KEY_SPACE])
	_register_keys("fold_mirrors", [KEY_E, KEY_SHIFT])
	_register_keys("horn", [KEY_F, KEY_H])
	_register_keys("restart_level", [KEY_R])
	_register_keys("pause_game", [KEY_ESCAPE, KEY_P])
	_register_keys("toggle_mute", [KEY_M])

func _register_keys(action: String, keycodes: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for kc in keycodes:
		var exists := false
		for ev in InputMap.action_get_events(action):
			if ev is InputEventKey and (ev.physical_keycode == kc or ev.keycode == kc):
				exists = true
				break
		if not exists:
			var kev := InputEventKey.new()
			kev.keycode = kc
			kev.physical_keycode = kc
			InputMap.action_add_event(action, kev)

func get_selected_bike_data() -> Dictionary:
	for b in BIKES:
		if b["id"] == selected_bike_id:
			return b
	return BIKES[0]

func get_level_data(idx: int = -1) -> Dictionary:
	var target := current_level_index if idx < 0 else idx
	target = clampi(target, 0, LEVELS.size() - 1)
	return LEVELS[target]

func start_level(idx: int) -> void:
	current_level_index = clampi(idx, 0, LEVELS.size() - 1)
	get_tree().paused = false
	var scene_path: String = LEVELS[current_level_index]["scene"]
	get_tree().change_scene_to_file(scene_path)

func restart_current_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func go_to_main_menu() -> void:
	get_tree().paused = false
	AudioManager.stop_engine()
	get_tree().change_scene_to_file("res://scenes/ui/MainMenu.tscn")

func go_to_level_select() -> void:
	get_tree().paused = false
	AudioManager.stop_engine()
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelect.tscn")

func unlock_all_levels() -> void:
	unlocked_level = LEVELS.size() - 1
	save_progress()

func format_campus_clock(start_sec_before_7am: int, progress_ratio: float) -> String:
	var p := clampf(progress_ratio, 0.0, 1.0)
	if p >= 1.0:
		return "07:00:00 AM"
	var sec_left := int(round(float(start_sec_before_7am) * (1.0 - p)))
	var total_sec_from_6am := 3600 - sec_left
	@warning_ignore("integer_division")
	var mins := total_sec_from_6am / 60
	var secs := total_sec_from_6am % 60
	return "06:%02d:%02d AM" % [clampi(mins, 0, 59), clampi(secs, 0, 59)]

func evaluate_grade(hp_ratio: float, time_left_ratio: float, angle_error_deg: float) -> Dictionary:
	var score := int(round(hp_ratio * 500.0 + time_left_ratio * 350.0 + clampf(1.0 - angle_error_deg / 18.0, 0.0, 1.0) * 150.0))
	var stars := 1
	var grade := "C"
	var comment := "Vớt vát qua môn! Lần sau gập gương căn góc chuẩn hơn nhé!"

	if hp_ratio >= 0.80 and time_left_ratio >= 0.25 and angle_error_deg <= 8.0:
		stars = 3
		grade = "A"
		comment = "Đỗ xe thượng thừa chuẩn dân Kỹ thuật Bách Khoa! Lên lớp ngồi bàn đầu luôn!"
	elif hp_ratio >= 0.50 and (time_left_ratio >= 0.12 or angle_error_deg <= 11.0):
		stars = 2
		grade = "B"
		comment = "Đỗ xe khá gọn, kịp chạy bộ lên cầu thang giảng đường trước khi thầy gọi tên!"

	return {
		"score": score,
		"stars": stars,
		"grade": grade,
		"comment": comment,
	}

func record_level_win(idx: int, result: Dictionary) -> void:
	if idx + 1 > unlocked_level and idx + 1 < LEVELS.size():
		unlocked_level = idx + 1

	var prev: Dictionary = level_records.get(idx, {})
	var best_stars: int = maxi(int(prev.get("stars", 0)), int(result.get("stars", 1)))
	var best_score: int = maxi(int(prev.get("score", 0)), int(result.get("score", 0)))
	var best_grade: String = str(result.get("grade", "C"))
	if prev.has("grade"):
		var rank_order := {"A": 3, "B": 2, "C": 1}
		if rank_order.get(prev["grade"], 0) > rank_order.get(best_grade, 0):
			best_grade = prev["grade"]

	level_records[idx] = {
		"stars": best_stars,
		"score": best_score,
		"grade": best_grade,
		"clock": str(result.get("clock", "06:59:00 AM")),
	}
	save_progress()

func get_level_record(idx: int) -> Dictionary:
	return level_records.get(idx, {})

func get_total_stars() -> int:
	var total := 0
	for k in level_records.keys():
		total += int(level_records[k].get("stars", 0))
	return total

func save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("player", "selected_bike_id", selected_bike_id)
	cfg.set_value("player", "unlocked_level", unlocked_level)
	for k in level_records.keys():
		cfg.set_value("records", str(k), level_records[k])
	cfg.save(SAVE_PATH)

func load_progress() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	selected_bike_id = str(cfg.get_value("player", "selected_bike_id", "wave"))
	unlocked_level = int(cfg.get_value("player", "unlocked_level", 0))
	level_records.clear()
	if cfg.has_section("records"):
		for key in cfg.get_section_keys("records"):
			level_records[int(key)] = cfg.get_value("records", key, {})
