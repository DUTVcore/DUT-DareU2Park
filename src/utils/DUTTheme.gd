class_name DUTTheme
extends RefCounted

const DUT_NAVY := Color("#092C59")
const DUT_BLUE := Color("#1456A8")
const DUT_LIGHT_BLUE := Color("#38BDF8")
const DUT_GOLD := Color("#F5B700")
const DUT_GREEN := Color("#22C55E")
const DUT_RED := Color("#EF4444")
const DUT_CARD_BG := Color(0.06, 0.11, 0.20, 0.92)
const DUT_PANEL_BG := Color(0.08, 0.15, 0.27, 0.95)
const DUT_TEXT := Color("#F8FAFC")
const DUT_MUTED := Color("#CBD5E1")

static var _cached_theme: Theme = null
static var _cached_font: SystemFont = null
static var _cached_bold_font: SystemFont = null

static func get_regular_font() -> SystemFont:
	if _cached_font == null:
		_cached_font = SystemFont.new()
		_cached_font.font_names = PackedStringArray(["Segoe UI", "Roboto", "Noto Sans", "Tahoma", "Arial"])
		_cached_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	return _cached_font

static func get_bold_font() -> SystemFont:
	if _cached_bold_font == null:
		_cached_bold_font = SystemFont.new()
		_cached_bold_font.font_names = PackedStringArray(["Segoe UI", "Roboto", "Noto Sans", "Tahoma", "Arial"])
		_cached_bold_font.font_weight = 700
		_cached_bold_font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	return _cached_bold_font

static func get_theme() -> Theme:
	if _cached_theme != null:
		return _cached_theme

	var t := Theme.new()
	var reg := get_regular_font()
	t.default_font = reg
	t.default_font_size = 16

	t.set_color("font_color", "Label", DUT_TEXT)
	t.set_color("font_color", "RichTextLabel", DUT_TEXT)

	var btn_normal := make_box(DUT_BLUE, DUT_LIGHT_BLUE, 2, 10)
	btn_normal.content_margin_left = 18
	btn_normal.content_margin_right = 18
	btn_normal.content_margin_top = 10
	btn_normal.content_margin_bottom = 10

	var btn_hover := make_box(Color("#1D6FD6"), DUT_GOLD, 2, 10)
	btn_hover.content_margin_left = 18
	btn_hover.content_margin_right = 18
	btn_hover.content_margin_top = 10
	btn_hover.content_margin_bottom = 10

	var btn_pressed := make_box(DUT_NAVY, DUT_GOLD, 2, 10)
	btn_pressed.content_margin_left = 18
	btn_pressed.content_margin_right = 18
	btn_pressed.content_margin_top = 10
	btn_pressed.content_margin_bottom = 10

	var btn_disabled := make_box(Color(0.18, 0.22, 0.28, 0.8), Color(0.35, 0.40, 0.48, 0.6), 1, 10)
	btn_disabled.content_margin_left = 18
	btn_disabled.content_margin_right = 18
	btn_disabled.content_margin_top = 10
	btn_disabled.content_margin_bottom = 10

	t.set_stylebox("normal", "Button", btn_normal)
	t.set_stylebox("hover", "Button", btn_hover)
	t.set_stylebox("pressed", "Button", btn_pressed)
	t.set_stylebox("focus", "Button", btn_hover)
	t.set_stylebox("disabled", "Button", btn_disabled)
	t.set_font("font", "Button", get_bold_font())
	t.set_color("font_color", "Button", DUT_TEXT)
	t.set_color("font_hover_color", "Button", Color("#FFFBEB"))
	t.set_color("font_pressed_color", "Button", DUT_GOLD)
	t.set_color("font_disabled_color", "Button", Color(0.58, 0.63, 0.70))

	var panel_box := make_box(DUT_PANEL_BG, Color(0.24, 0.48, 0.82, 0.75), 2, 14)
	panel_box.content_margin_left = 16
	panel_box.content_margin_right = 16
	panel_box.content_margin_top = 14
	panel_box.content_margin_bottom = 14
	t.set_stylebox("panel", "PanelContainer", panel_box)

	_cached_theme = t
	return t

static func make_box(bg: Color, border: Color, border_w: int = 2, radius: int = 10) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(border_w)
	sb.set_corner_radius_all(radius)
	sb.shadow_color = Color(0, 0, 0, 0.32)
	sb.shadow_size = 4
	return sb

static func style_accent_button(btn: Button, bg: Color, border: Color) -> void:
	var normal := make_box(bg, border, 2, 10)
	normal.content_margin_left = 18
	normal.content_margin_right = 18
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	var hover := make_box(bg.lightened(0.14), Color.WHITE, 2, 10)
	hover.content_margin_left = 18
	hover.content_margin_right = 18
	hover.content_margin_top = 10
	hover.content_margin_bottom = 10
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("focus", hover)
