extends Control

var boxes = []
var boxTexts = []
var originalPoses = []

func _ready():
	for i in get_child_count():
		boxes.append(get_child(i))
		boxTexts.append(boxes[i].get_child(0).get_child(0))
		originalPoses.append(boxes[i].rect_position)
		#boxTexts[i].bbcode = true
		boxTexts[i].bbcode_enabled = true

func changeText(_richtext, _str):
	_richtext.bbcode_text = "[center]" + _str.to_upper()

func create_char_boxes(_count):
	# Find the right size for boxes
	var boxSize = 1
	var sum = boxSize * _count + boxSize * 0.5 * (_count + 1)
	boxSize = 1 / sum
	print(boxSize)
	
	var scene = load("res://srv/char_box.tscn")
	for i in _count:
		# Create and Setup
		var box = scene.instance()
		var boxText = box.get_child(0).get_child(0)
		add_child(box)
		boxes.append(box)
		boxTexts.append(boxText)
		
		# Set Anchors		
		box.anchor_left = boxSize * i + boxSize * 0.5 * (i + 1)
		box.anchor_right = box.anchor_left + boxSize
		box.anchor_top = 0.25
		box.anchor_bottom = box.anchor_top + boxSize
		# Fixes stuff with the text centering (NOT FINISHED)
		box.margin_right = 0
		box.margin_bottom = box.rect_size.x / 2


func _on_Control_hint_created(_hint):
	create_char_boxes(len(_hint))
	for i in len(_hint):		
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
