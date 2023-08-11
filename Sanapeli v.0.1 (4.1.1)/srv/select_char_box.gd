extends TextureRect

@export var index = 0
var originalPos : Vector2

func _ready() -> void:
	originalPos = position

func _on_control_char_box_selected(box_index) -> void:
	if box_index == index:
		scale = Vector2(1.25, 1.25)
		position -= Vector2(110 * (scale.x - 1) / 2, 110 * (scale.y - 1) / 2)
	else: 
		scale = Vector2(1, 1)
		position = originalPos
