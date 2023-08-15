extends Control

# Variables
var handPos : float = -1
var boxSelectedTime : float = 0
var editingCharIndex : int = 0
var word

# Chosen Word Settings
var hint = "s  a"
var words = ["sana", "sula", "sala"]
var chrs = "anlu"

# Signals
signal hint_created(_hint)
signal chrs_created(_chrs)
signal char_box_selected(_box_index)
signal char_chosen(_char, _index)



func _ready():
	emit_signal("hint_created", hint)
	emit_signal("chrs_created", chrs)
	
	word = hint # setups the word, that will be filled by player
	check_word() # finds the addingCharToIndex

# Inputs
func _physics_process(delta: float) -> void:
	# Hand goes down
	if not Input.is_key_pressed(KEY_SPACE) and handPos != -1:
		handPos = -1
		emit_signal("char_box_selected", int(handPos)) # Send signal to boxes
	
	# Hand comes up
	if Input.is_key_pressed(KEY_SPACE) and handPos == -1:
		handPos = 0
		emit_signal("char_box_selected", int(handPos)) # Send signal to boxes
	
	# Change Hand Pos and send signal
	if Input.is_action_just_pressed("ui_up"):
		handPos += 1
		boxSelectedTime = 0 # Reset Selected Timer
		emit_signal("char_box_selected", int(handPos)) # Send signal to boxes
	if Input.is_action_just_pressed("ui_down"):
		handPos -= 1
		boxSelectedTime = 0 # Reset Selected Timer
		emit_signal("char_box_selected", int(handPos)) # Send signal to boxes
	
	# Select character (if 2s in the same place)
	if Input.is_key_pressed(KEY_SPACE):
		boxSelectedTime += delta
	if boxSelectedTime >= 2:
		emit_signal("char_chosen", chrs[handPos], editingCharIndex)
		word[editingCharIndex] = chrs[handPos]
		check_word()
		boxSelectedTime = 0

# Checks the word, if it still has spaces, it selects a new editingCharIndex
# Else it will check if the word is included in words list
func check_word():
	for i in word.length():
		if word[i] == " ":
			editingCharIndex = i
			return
	# if word is filled, code gets here
	if word in words: print("correct")
	else: print("incorrect")
