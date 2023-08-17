extends Control

export var GameTime : float = 30

# Variables
var handPos : float = -1
var boxSelectedTime : float = 0
var editingCharIndex : int = 0
var word : String = ""
var timeLeft : float = 0

# Chosen Word Settings
var wordsData
var selectedWord

# Signals
signal hint_created(_hint)
signal chrs_created(_chrs)
signal char_box_selected(_box_index)
signal editing_char_selected(_index)
signal char_chosen(_char, _index)
signal change_time(time)



func _ready():
	load_words()
	new_word()	
	timeLeft = GameTime
func load_words():
	var file = File.new()
	if not file.file_exists("res://data/words.json"):
		return
	file.open("res://data/words.json", File.READ)
	var text = file.get_as_text()
	wordsData = parse_json(text)
func select_word():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var index = rng.randi_range(0, len(wordsData) - 1)
	selectedWord = wordsData[index]
func new_word():
	select_word()
	emit_signal("hint_created", selectedWord["Hint"])
	emit_signal("chrs_created", selectedWord["Chars"])

	# Setup word
	word = ""
	for i in len(selectedWord["Hint"]): if selectedWord["Hint"][i] != "": word += selectedWord["Hint"][i]
	check_word() # Finds the editingCharIndex

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

# Checks the word, if it still has spaces, it selects a new editingCharIndex
# Else it will check if the word is included in words list
func check_word():
	for i in word.length():
		if word[i] == " ":
			editingCharIndex = i
			emit_signal("editing_char_selected", editingCharIndex)
			return
	# if word is filled, code gets here
	emit_signal("editing_char_selected", -1)
	if word in selectedWord["Words"]: print("correct")
	else: print("incorrect")
