extends TextureRect

export var index = 0
var originalPos : Vector2


func _on_Control_char_box_selected(box_index):
	if box_index == index:
		originalPos = rect_position
		rect_scale = Vector2(1.25, 1.25)
		rect_position -= Vector2(110 * (rect_scale.x - 1) / 2, 110 * (rect_scale.y - 1) / 2)
	elif (rect_scale == Vector2(1.25, 1.25)):
		rect_scale = Vector2(1, 1)
		rect_position = originalPos


func _on_Control_words_selected(hint_chrs):
	if hint_chrs[index] != " ": get_child(0).text = hint_chrs[index]
