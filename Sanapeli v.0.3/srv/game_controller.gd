extends Control

# Exports
export var GameTime : float = 29
# Data and Nodes
var wordsData
var usedWords : Array = []
var letterRarity : Array = ["aitneslo", "kuämvr", "jhypdögbfcwåqxz"]
var middleText : RichTextLabel
var rng : RandomNumberGenerator

# Whole Game Variables
var difficulty : float = 0.5 # between 0 and 1 (1 is hardest)
var playingWordNum : int = 0
var points : Array

# One Game Variables
var selectedWord
var word : String = ""
var word_start_chrs : Array
var chrs : Array
var editingWord = true
var editingCharIndex : int = 0
var handPos : float = -1
var boxSelectedTime : float = 0
var timeLeft : float = 0

# Signals
signal word_created(_hint) # Creates the char boxes and adds the characters
signal chrs_created(_chrs) # Only adds the characters to boxes
signal char_box_selected(_box_index)
signal editing_char_selected(_index)
signal char_chosen(_char, _index)
signal change_time(time)
signal hide_boxes(type)
signal show_boxes(type)
signal answer_animation(correct) # True or false?

#----------------------------------------------------------------------------#



# Functions
func load_words():
	var file = File.new()
	if not file.file_exists("res://data/words.json"):
		return
	file.open("res://data/words.json", File.READ)
	var text = file.get_as_text()
	wordsData = parse_json(text)
func new_word():
	select_word()
	select_chrs()
	emit_signal("word_created", word_start_chrs)
	emit_signal("chrs_created", chrs)

	# Adds the start characters and empty spaces to "word"
	word = ""
	for i in len(word_start_chrs): 
		if word_start_chrs[i] != "": word += word_start_chrs[i]
		else: word += " "
	check_word() # Finds the editingCharIndex
	
	playingWordNum += 1
func select_word():
	# Selects a random word from data
	var index
	while true:
		index = rng.randi_range(0, len(wordsData) - 1)
		if not index in usedWords: break
	selectedWord = wordsData[index]
	usedWords.append(index)
func select_chrs():
	# Clear old chr data
	word_start_chrs.clear()
	chrs.clear()
	
	
	# Select The Minimum Amount Of Word Start Characters
	# (because if word has more than 4 different chrs, it can't be typed)
	
	for i in len(selectedWord["word"]): word_start_chrs.append("")
	var word_chrs_amount = funcs.chrs_in(selectedWord["word"])
	var single_chrs : Array
	if word_chrs_amount > 4: single_chrs = funcs.single_chrs_in(selectedWord["word"])
	
	# If there are more than 4 different chars in word, show chars in word until 4 are left 
	for i in word_chrs_amount - 4:
		var index = rng.randi_range(0, len(single_chrs) - 1)
		var chrPos = funcs.index_of(single_chrs[index], selectedWord["word"])
		word_start_chrs[chrPos] = single_chrs[index]
		single_chrs.pop_at(index)
	
	
	
	# Add Random Word Start Characters By Using Difficulty
	
	var add_chars_amount = int((len(selectedWord["word"]) - 1) * (1 - difficulty))
	add_chars_amount -= funcs.chrs_in(word_start_chrs)
	for i in add_chars_amount:
		while true: # loops until a character has been added to a random and empty space
			var index = rng.randi_range(0, len(selectedWord["word"]) - 1)
			var chr = selectedWord["word"][index]
			if word_start_chrs[index] == "": 
				word_start_chrs[index] = chr
				break
	
	
	
	# Select The Usable Characters
	
	# Add characters that you need when filling the word
	for i in len(selectedWord["word"]):
		if not selectedWord["word"][i] in chrs and word_start_chrs[i] == "":
			chrs.append(selectedWord["word"][i])
	
	# Adds random characters, if there aren't enough
	for i in 4 - len(chrs):
		while true: # loops until a new different char has been added to chars
			var randomChr = char(rng.randi_range(ord("a"), ord("z")))
			if not randomChr in chrs:
				chrs.append(randomChr)
				break
	chrs.shuffle()
func check_word():
	# Checks the word, if it still has spaces, it selects a new editingCharIndex
	# Else it will check if the word is included in words list
	
	# Tries to find an empty space in word and set editingCharIndex there
	for i in word.length():
		if word[i] == " ":
			editingCharIndex = i
			emit_signal("editing_char_selected", editingCharIndex)
			return
	
	# If the word is filled, code gets here
	editingCharIndex = -1
	emit_signal("editing_char_selected", editingCharIndex)
	
	if playingWordNum >= 6:
		add_points()
		Global.Points = points
		if get_tree().change_scene("res://srv/end.tscn") != OK: print("scene change failed")
	else: cutscene()
func cutscene():
	# START OF CUTSCENE
	
	add_points()
	change_difficulty()
	editingWord = false
	var time = max(0, timeLeft - 3)
	
	# Show the correct word and if you were correct
	emit_signal("hide_boxes", "sel")
	emit_signal("word_created", selectedWord["word"])
	if points[len(points) - 1] != 0:
		#middleText.modulate = Color.green
		middleText.bbcode_text = "[center]" + funcs.random_correct_sentence()
		emit_signal("answer_animation", true)
	else:
		#middleText.modulate = Color.lightcoral
		middleText.bbcode_text = "[center]" + funcs.random_wrong_sentence()
		emit_signal("answer_animation", false)
	yield(get_tree().create_timer(3), "timeout")
	
	
	
	# MIDDLE OF CUTSCENE (new word and possibly an early hint)
	var parent : BoxContainer = middleText.get_parent()
	#middleText.modulate = Color.white
	
	# if early hint cutscene would take more than 1 seconds, display it
	if time >= 1:
		new_word()
		#parent.alignment = BoxContainer.ALIGN_BEGIN
		middleText.bbcode_text = "[center]" + selectedWord["definition"]
		emit_signal("hide_boxes", "word")
		yield(get_tree().create_timer(time), "timeout")
		
	# there wasn't time for early hint, so just show the next word
	else:
		yield(get_tree().create_timer(time), "timeout")
		new_word()
		middleText.bbcode_text = "[center]" + selectedWord["definition"]
	
	
	
	# END OF CUTSCENE
	#parent.alignment = BoxContainer.ALIGN_CENTER
	editingWord = true
	emit_signal("show_boxes", "all")
func add_points():
	points.append(0)
	if word == selectedWord["word"]:
		var pointsIndex = len(points) - 1
		for i in len(word):
			if word_start_chrs[i] == "":
				if word[i] in letterRarity[0]: points[pointsIndex] += 5
				elif word[i] in letterRarity[1]: points[pointsIndex] += 10
				elif word[i] in letterRarity[2]: points[pointsIndex] += 15
		points[pointsIndex] += int(timeLeft / 2)
		print(points[pointsIndex])
func change_difficulty():
	if word == selectedWord["word"]:
		difficulty += 0.003 * timeLeft * len(word)
	else: difficulty -= 0.35 - (len(word) - 4) * 0.05
	difficulty = clamp(difficulty, 0, 1)
	print("difficulty: ", difficulty)



func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	
	load_words()
	new_word()
	timeLeft = GameTime
	
	middleText = get_node("Middle Text Container").get_node("Middle Text") as RichTextLabel
	middleText.bbcode_text = "[center]" + str(selectedWord["definition"])

func _physics_process(delta: float) -> void:
	# Run inputs if editing a word, else reset box selections to avoid bugs in next word
	if editingWord: pc_inputs(delta)
	elif handPos != -1:
		boxSelectedTime = 0
		handPos = -1
		emit_signal("char_box_selected", int(handPos))
	
	timeLeft -= delta
	emit_signal("change_time", 1 - timeLeft / GameTime)
	
	# Start a new word by calling cutscene
	if (timeLeft <= 0):
		
		if editingWord == true:
			if playingWordNum >= 6:
				Global.Points = points
				if get_tree().change_scene("res://srv/end.tscn") != OK: print("scene change failed")
			
			editingCharIndex = -1
			emit_signal("editing_char_selected", editingCharIndex)
			cutscene()
		timeLeft = GameTime


func pc_inputs(delta_param : float):
	# Change Hand Position (resets boxSelectedTime and sends signal to boxes about handPos)
	if Input.is_action_just_pressed("ui_up"):
		if handPos < 3: handPos += 1
		else: handPos = 0
		boxSelectedTime = 0
		emit_signal("char_box_selected", int(handPos))
	
	# When character is set, boxSelectedTime goes up by delta
	if handPos != -1: boxSelectedTime += delta_param
	
	# Character selected
	if boxSelectedTime >= 2:
		emit_signal("char_chosen", chrs[handPos], editingCharIndex)
		word[editingCharIndex] = chrs[handPos]
		check_word()
		
		boxSelectedTime = 0
		handPos = -1
		emit_signal("char_box_selected", int(handPos))




