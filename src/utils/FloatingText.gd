class_name FloatingText
extends Node2D

var message: String = ""
var text_color: Color = Color.WHITE
var lifetime: float = 1.15
var elapsed: float = 0.0
var _label: Label

static func spawn(parent: Node, world_pos: Vector2, msg: String, color: Color = Color("#F5B700")) -> void:
	if parent == null or not is_instance_valid(parent):
		return
	var ft := FloatingText.new()
	ft.global_position = world_pos
	ft.message = msg
	ft.text_color = color
	ft.z_index = 90
	parent.add_child(ft)

func _ready() -> void:
	_label = Label.new()
	_label.text = message
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.position = Vector2(-140, -14)
	_label.custom_minimum_size = Vector2(280, 28)
	_label.add_theme_font_override("font", DUTTheme.get_bold_font())
	_label.add_theme_font_size_override("font_size", 15)
	_label.add_theme_color_override("font_color", text_color)
	_label.add_theme_color_override("font_outline_color", Color(0.03, 0.05, 0.10, 0.95))
	_label.add_theme_constant_override("outline_size", 5)
	add_child(_label)

func _process(delta: float) -> void:
	elapsed += delta
	position.y -= 28.0 * delta
	var t := clampf(elapsed / lifetime, 0.0, 1.0)
	modulate.a = 1.0 - pow(t, 2.0)
	if elapsed >= lifetime:
		queue_free()
