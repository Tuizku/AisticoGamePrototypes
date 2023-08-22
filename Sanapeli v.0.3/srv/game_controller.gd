extends Control

# Exports
export var GameTime : float = 30

# Variables
var handPos : float = -1
var boxSelectedTime : float = 0
var editingCharIndex : int = 0
var word : String = ""
var word_start_chrs
var timeLeft : float = 0
var middleText
var letterRarity : Array = ["aitneslo", "kuämvr", "jhypdögbfcwåqxz"] # x, z not in og data

# Chosen Word Settings
var wordsData
var selectedWord

# Signals
signal word_created(_hint)
signal chrs_created(_chrs)
signal char_box_selected(_box_index)
signal editing_char_selected(_index)
signal char_chosen(_char, _index)
signal change_time(time)


# Word Functions
func load_words():
	var file = File.new()
	if not file.file_exists("res://data/words.json"):
		return
	file.open("res://data/words.json", File.READ)
	var text = file.get_as_text()
	wordsData = parse_json(text)
func select_word():
	# Word
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var index = rng.randi_range(0, len(wordsData) - 1)
	selectedWord = wordsData[index]
func select_chrs():
	
	pass
func new_word():
	select_word()
	select_chrs()
	emit_signal("word_created", word_start_chrs)
	emit_signal("chrs_created", selectedWord["Chars"])

	# Setup word
	word = ""
	for i in len(word_start_chrs): if word_start_chrs[i] != "": word += word_start_chrs[i]
	check_word() # Finds the editingCharIndex
func check_word():
	# Checks the word, if it still has spaces, it selects a new editingCharIndex
	# Else it will check if the word is included in words list
	for i in word.length():
		if word[i] == " ":
			editingCharIndex = i
			emit_signal("editing_char_selected", editingCharIndex)
			return
	# if word is filled, code gets here
	emit_signal("editing_char_selected", -1)
	if word == selectedWord["word"]:
		var points = 0
		for chrI in len(word):
			if word_start_chrs[chrI] == " ":
				if word[chrI] in letterRarity[0]: points += 5
				elif word[chrI] in letterRarity[1]: points += 10
				elif word[chrI] in letterRarity[2]: points += 25
		show_text(str(points) + " pistettä", Color.green)
	else: show_text("Väärin!", Color.lightcoral)


func _ready():
	load_words()
	new_word()	
	timeLeft = GameTime
	middleText = get_node("Middle Text") as RichTextLabel

func _physics_process(delta: float) -> void:
	pc_inputs(delta)
	
	timeLeft -= delta
	emit_signal("change_time", 1 - timeLeft / GameTime)
	if (timeLeft <= 0):
		timeLeft = GameTime
		new_word()


func pc_inputs(delta_param : float):
	# Hand goes down
	if not Input.is_key_pressed(KEY_SPACE) and handPos != -1:
		handPos = -1
		emit_signal("char_box_selected", int(handPos)) # Send signal to boxes
	
	# Hand comes up
	if Input.is_key_pressed(KEY_SPACE) and handPos == -1:
		handPos = 0
		emit_signal("char_box_selected", int(handPos)) # Send signal to boxes
	
	# Change Hand Pos and send signal
	if handPos != -1 and handPos < 3 and Input.is_action_just_pressed("ui_up"):
		handPos += 1
		boxSelectedTime = 0 # Reset Selected Timer
		emit_signal("char_box_selected", int(handPos)) # Send signal to boxes
	if handPos != -1 and handPos > 0 and Input.is_action_just_pressed("ui_down"):
		handPos -= 1
		boxSelectedTime = 0 # Reset Selected Timer
		emit_signal("char_box_selected", int(handPos)) # Send signal to boxes
	
	# Select character (if 2s in the same place)
	if Input.is_key_pressed(KEY_SPACE):
		boxSelectedTime += delta_param
	if boxSelectedTime >= 2:
		emit_signal("char_chosen", selectedWord["Chars"][handPos], editingCharIndex)
		word[editingCharIndex] = selectedWord["Chars"][handPos]
		check_word()
		boxSelectedTime = 0

func show_text(text, color):
	middleText.modulate = color
	middleText.bbcode_text = "[center]" + text
	yield(get_tree().create_timer(5.0), "timeout")
	middleText.bbcode_text = ""
	middleText.modulate = Color.white
