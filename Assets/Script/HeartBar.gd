extends HBoxContainer
class_name HeartBar

signal hearts_changed(current: int, max: int)

@export var max_hearts: int = 5 : set = set_max_hearts
@export var value: int = 5 : set = set_value
@export var heart_full: Texture2D
@export var heart_empty: Texture2D
@export var heart_size: Vector2i = Vector2i(32, 32)
@export var spacing: int = 4 : set = set_spacing

func _ready() -> void:
	add_theme_constant_override("separation", spacing)
	rebuild()

func set_spacing(s: int) -> void:
	spacing = s
	add_theme_constant_override("separation", spacing)

func set_max_hearts(n: int) -> void:
	max_hearts = max(0, n)
	value = clamp(value, 0, max_hearts)
	rebuild()
	emit_signal("hearts_changed", value, max_hearts)

func set_value(v: int) -> void:
	value = clamp(v, 0, max_hearts)
	update_icons()
	emit_signal("hearts_changed", value, max_hearts)
	queue_redraw()

func rebuild() -> void:
	for c in get_children():
		remove_child(c)
		c.queue_free()

	for i in range(max_hearts):
		var tr := TextureRect.new()
		tr.stretch_mode = TextureRect.StretchMode.STRETCH_KEEP_ASPECT_CENTERED
		tr.custom_minimum_size = heart_size
		tr.texture = heart_full if i < value else heart_empty
		add_child(tr)

func update_icons() -> void:
	var i := 0
	for c in get_children():
		if c is TextureRect:
			c.texture = heart_full if i < value else heart_empty
			i += 1

func heal(amount: int = 1) -> void:
	set_value(value + amount)
