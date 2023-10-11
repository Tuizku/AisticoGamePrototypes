extends Control

export var Type : String = ""

var letterRarity : Array = ["aitneslo", "kuämvr", "jhypdögbfcwåqxz"]
#var normal_texture = ResourceLoader.load("res://sprites/char_box.png")
#var inverted_texture = ResourceLoader.load("res://sprites/char_box_inverted.png")
var gold_texture = ResourceLoader.load("res://sprites/box_gold.png")
var gold_clicked_texture = ResourceLoader.load("res://sprites/box_gold_clicked.png")
var silver_texture = ResourceLoader.load("res://sprites/box_silver.png")
var silver_clicked_texture = ResourceLoader.load("res://sprites/box_silver_clicked.png")

var boxes = []
var boxButtons = []
var boxTexts = []
var boxAnimators = []

var gameController
var wordStartChrs

func _ready():
	for i in get_child_count():
		boxes.append(get_child(i))
		boxButtons.append(boxes[i].get_node("Button"))
		boxTexts.append(boxes[i].get_node("Label"))
		boxAnimators.append(boxes[i].get_node("AnimationPlayer") as AnimationPlayer)
		
		# Fix label bugs
		boxTexts[i].margin_right = 0
		boxTexts[i].margin_bottom = 0


func create_char_boxes(_count):
	# Delete old if there are
	for i in get_child_count():
		get_child(i).queue_free()
	boxes.clear()
	#boxImages.clear()
	boxButtons.clear()
	boxTexts.clear()
	boxAnimators.clear()
	
	# Find the right size for boxes
	var boxSize = 1
	var sum = boxSize * _count + boxSize * 0.5 * (_count + 1)
	boxSize = min(0.18, 1 / sum) # maybe have to change this
	var boxGap = (1 - boxSize * _count) / (_count + 1)
	
	var scene = load("res://scenes/char_button.tscn")
	for i in _count:
		# Create and Setup
		var box = scene.instance()
		#var boxText = box.get_node("Label")
		add_child(box)
		boxes.append(box)
		#boxImages.append(box.get_node("Image"))
		boxButtons.append(box.get_node("Button"))
		boxTexts.append(box.get_node("Label"))
		boxAnimators.append(box.get_node("AnimationPlayer"))
		
		# Set Anchors
		box.anchor_left = boxSize * i + boxGap * (i + 1)
		box.anchor_right = box.anchor_left + boxSize
		box.anchor_bottom = 1
		box.anchor_top = 0
		
		# Fix label bugs
		boxTexts[i].margin_right = 0
		boxTexts[i].margin_bottom = 0
		
		# Colors
		boxTexts[i].modulate = Color("666666")
		#boxButtons[i].texture_normal = silver_texture
		#boxButtons[i].texture_pressed = silver_clicked_texture
	
	if gameController != null: connect_buttons()


func connect_buttons():
	for i in len(boxButtons):
		if Type == "sel":
			boxButtons[i].connect("pressed", gameController, "add_char_to_word", [i])
		if Type == "word" and wordStartChrs[i] == "":
			boxButtons[i].connect("pressed", gameController, "remove_char_from_word", [i])


func _on_Control_chrs_created(_chrs):
	for i in len(boxTexts):
		boxTexts[i].text = _chrs[i].to_upper()


func _on_Control_char_chosen(_char, _index):
	boxTexts[_index].text = _char.to_upper()


func _on_Control_editing_char_selected(_index):
	for i in len(boxes):
		if i == _index:
			#boxes[i].modulate = Color.white
			boxAnimators[i].play("Editing")
		else: 
			boxAnimators[i].play("Stop Editing")
			
		if wordStartChrs[i] == "":
			boxButtons[i].texture_normal = silver_texture
			boxButtons[i].texture_pressed = silver_clicked_texture
		else: 
			#boxes[i].modulate = Color.gray
			boxButtons[i].texture_normal = silver_clicked_texture


func _on_Control_word_created(_word_start):
	wordStartChrs = _word_start
	create_char_boxes(len(_word_start))
	for i in len(_word_start):
		boxTexts[i].text = _word_start[i].to_upper()


func _on_Control_hide_boxes(type):
	if type == Type or type == "all": hide()


func _on_Control_show_boxes(type):
	if type == Type or type == "all": show()


func _on_Control_answer_animation(answer, cor_answer):
	for i in len(boxButtons):
		boxButtons[i].texture_normal = silver_texture
		boxButtons[i].texture_pressed = silver_texture
		boxTexts[i].modulate = Color("666666")
	
	if answer == cor_answer:
		for i in len(boxAnimators):
			boxButtons[i].texture_normal = gold_texture
			boxButtons[i].texture_normal = gold_texture
			boxTexts[i].modulate = Color("957b00")
			boxAnimators[i].play("Jumping")
			yield(get_tree().create_timer(0.2), "timeout")
	else:
		for i in len(boxAnimators):
			boxAnimators[i].play("Fall")
			if answer[i] == cor_answer[i]:
				boxButtons[i].texture_normal = gold_texture
				boxTexts[i].modulate = Color("957b00")
			else: 
				#boxButtons[i].texture_normal = silver_texture
				#boxButtons[i].texture_pressed = silver_clicked_texture
				#boxTexts[i].modulate = Color("8C8C8C")
				boxTexts[i].text = cor_answer[i].to_upper()
			yield(get_tree().create_timer(0.2), "timeout")


func _on_Control_send_gamecontroller(_node):
	gameController = _node
	connect_buttons()
