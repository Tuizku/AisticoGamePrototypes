extends Control

var boxes = []
var boxTexts = []
var originalPoses = []

func _ready():
	for i in get_child_count():
		boxes.append(get_child(i))
		boxTexts.append(boxes[i].get_child(0))
		originalPoses.append(boxes[i].rect_position)
		#boxTexts[i].bbcode = true
		boxTexts[i].bbcode_enabled = true

func changeText(_richtext, _str):
	_richtext.bbcode_text = "[center]" + _str.to_upper()

func _on_Control_hint_created(_hint):
	for i in len(boxTexts):
		changeText(boxTexts[i], _hint[i])


func _on_Control_chrs_created(_chrs):
	for i in len(boxTexts):
		changeText(boxTexts[i], _chrs[i])


func _on_Control_char_box_selected(_box_index):
	for i in len(boxes):		
		if _box_index == i:
			originalPoses[i] = boxes[i].rect_position
			boxes[i].rect_scale = Vector2(1.25, 1.25)
			var _scale = boxes[i].rect_scale
			boxes[i].rect_position -= Vector2(110 * (_scale.x - 1) / 2, 110 * (_scale.y - 1) / 2)
		elif (boxes[i].rect_scale == Vector2(1.25, 1.25)):
			boxes[i].rect_scale = Vector2(1, 1)
			boxes[i].rect_position = originalPoses[i]


func _on_Control_char_chosen(_char, _index):
	changeText(boxTexts[_index], _char)


func _on_Control_editing_char_selected(_index):
	for i in len(boxes):
		if i == _index:
			boxes[i].modulate = Color.white
		else: boxes[i].modulate = Color.gray
