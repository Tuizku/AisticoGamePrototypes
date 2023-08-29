extends Control

export var Type : String = ""

var letterRarity : Array = ["aitneslo", "kuämvr", "jhypdögbfcwåqxz"]


var boxes = []
var boxTexts = []
var boxAnimators = []
var originalPoses = []

func _ready():
	for i in get_child_count():
		boxes.append(get_child(i))
		boxTexts.append(boxes[i].get_node("VBoxContainer").get_node("Text"))
		boxAnimators.append(boxes[i].get_node("AnimationPlayer") as AnimationPlayer)
		originalPoses.append(boxes[i].rect_position)
		boxTexts[i].bbcode_enabled = true

func changeText(_richtext, _str):
	_richtext.bbcode_text = "[center]" + _str.to_upper()

func create_char_boxes(_count):
	# Delete old if there are
	for i in get_child_count():
		get_child(i).queue_free()
	boxes.clear()
	boxTexts.clear()
	
	# Find the right size for boxes
	var boxSize = 1
	var sum = boxSize * _count + boxSize * 0.5 * (_count + 1)
	boxSize = min(0.13, 1 / sum)
	var boxGap = (1 - boxSize * _count) / (_count + 1)
	#print(boxSize)
	
	var scene = load("res://srv/char_box.tscn")
	for i in _count:
		# Create and Setup
		var box = scene.instance()
		var boxText = box.get_node("VBoxContainer").get_node("Text")
		add_child(box)
		boxes.append(box)
		boxTexts.append(boxText)
		
		# Set Anchors
		box.anchor_left = boxSize * i + boxGap * (i + 1)
		box.anchor_right = box.anchor_left + boxSize
		box.anchor_bottom = 0.3
		box.anchor_top = box.anchor_bottom - boxSize
		
		# Fixes stuff with the text centering (NOT FINISHED)
		box.margin_right = 0
		box.margin_bottom = box.rect_size.x / 2



func _on_Control_chrs_created(_chrs):
	for i in len(boxTexts):
		changeText(boxTexts[i], _chrs[i])
		#if _chrs[i] in letterRarity[0]: boxes[i].modulate = Color.white
		#elif _chrs[i] in letterRarity[1]: boxes[i].modulate = Color.hotpink
		#elif _chrs[i] in letterRarity[2]: boxes[i].modulate = Color.yellow


func _on_Control_char_box_selected(_box_index):
	for i in len(boxes):
		if _box_index == i:
			boxAnimators[i].play("Selecting")
		elif boxAnimators[i].is_playing():
			boxAnimators[i].stop(0)
			#originalPoses[i] = boxes[i].rect_position
			#boxes[i].rect_scale = Vector2(1.25, 1.25)
			#var _scale = boxes[i].rect_scale
			#boxes[i].rect_position -= Vector2(110 * (_scale.x - 1) / 2, 110 * (_scale.y - 1) / 2)
		#elif (boxes[i].rect_scale == Vector2(1.25, 1.25)):
			#boxes[i].rect_scale = Vector2(1, 1)
			#boxes[i].rect_position = originalPoses[i]


func _on_Control_char_chosen(_char, _index):
	changeText(boxTexts[_index], _char)


func _on_Control_editing_char_selected(_index):
	for i in len(boxes):
		if i == _index:
			boxes[i].modulate = Color.white
		else: boxes[i].modulate = Color.gray


func _on_Control_word_created(_word_start):
	create_char_boxes(len(_word_start))
	for i in len(_word_start):
		changeText(boxTexts[i], _word_start[i])


func _on_Control_hide_boxes(type):
	if type == Type or type == "all": hide()


func _on_Control_show_boxes(type):
	if type == Type or type == "all": show()
