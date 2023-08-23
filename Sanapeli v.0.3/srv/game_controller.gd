extends Control

# Exports
export var GameTime : float = 30

# Variables
var middleText
var letterRarity : Array = ["aitneslo", "kuämvr", "jhypdögbfcwåqxz"] # x, z not in og data
var handPos : float = -1
var boxSelectedTime : float = 0
var editingCharIndex : int = 0
var timeLeft : float = 0
var difficulty : float = 1 # between 0 and 1 (1 is hardest)


var word : String = ""
var word_start_chrs : Array
var chrs : Array

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
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Clear old chr data
	word_start_chrs.clear()
	chrs.clear()
	
	# Select the minimum amount of word start characters
	# (because if word has more than 4 different chrs, it can't be typed)
	for i in len(selectedWord["word"]): word_start_chrs.append("")
	
	var word_chrs_amount = funcs.chrs_in(selectedWord["word"])
	if word_chrs_amount > 4: # If there are more than 4 chars in word, show chars in word until 4 are left
		var single_chrs : Array = funcs.single_chrs_in(selectedWord["word"])
		for i in word_chrs_amount - 4:
			var index = rng.randi_range(0, len(single_chrs) - 1)
			var chrPos = funcs.index_of(single_chrs[index], selectedWord["word"])
			word_start_chrs[chrPos] = single_chrs[index]
			single_chrs.pop_at(index)
	
	# Add random word start characters
	var add_chars_amount = int((len(selectedWord["word"]) - 2) * (1 - difficulty))
	print(add_chars_amount)
	add_chars_amount -= funcs.chrs_in(word_start_chrs)
	print(add_chars_amount)
	print(word_start_chrs)
	for i in add_chars_amount:
		var loop = true
		while loop:
			var index = rng.randi_range(0, len(selectedWord["word"]) - 1)
			var chr = selectedWord["word"][index]
			if word_start_chrs[index] == "": 
				word_start_chrs[index] = chr
				loop = false
	
	# Select the usable characters
	for i in len(selectedWord["word"]):
		if not selectedWord["word"][i] in chrs and word_start_chrs[i] == "":
			chrs.append(selectedWord["word"][i])
	for i in 4 - len(chrs):
		var randomChr = char(rng.randi_range(ord("a"), ord("z")))
		chrs.append(randomChr)
	chrs.shuffle()
func new_word():
	select_word()
	select_chrs()
	emit_signal("word_created", word_start_chrs)
	emit_signal("chrs_created", chrs)

	# Setup word
	word = ""
	for i in len(word_start_chrs): 
		if word_start_chrs[i] != "": word += word_start_chrs[i]
		else: word += " "
	check_word() # Finds the editingCharIndex
	
	# Hint
	middleText.bbcode_text = "[center]" + str(selectedWord["definition"])
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
		#var points = 0
		#for chrI in len(word):
			#if word_start_chrs[chrI] == " ":
				#if word[chrI] in letterRarity[0]: points += 5
				#elif word[chrI] in letterRarity[1]: points += 10
				#elif word[chrI] in letterRarity[2]: points += 25
		#show_text(str(points) + " pistettä", Color.green)
		show_text("Oikein!", Color.green)
	else: show_text("Väärin!", Color.lightcoral)


func _ready():
	middleText = get_node("Middle Text") as RichTextLabel
	load_words()
	new_word()
	timeLeft = GameTime

func _physics_process(delta: float) -> void:
	pc_inputs(delta)
	
	timeLeft -= delta
	emit_signal("change_time", 1 - timeLeft / GameTime)
	if (timeLeft <= 0):
		timeLeft = GameTime
		new_word()


func pc_inputs(delta_param : float):
	# Change Hand Position (resets boxSelectedTime and sends signal to boxes about handPos)
	if handPos < 3 and Input.is_action_just_pressed("ui_up"):
		handPos += 1
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

func show_text(text, color):
	middleText.modulate = color
	middleText.bbcode_text = "[center]" + text
	yield(get_tree().create_timer(5.0), "timeout")
	middleText.bbcode_text = ""
	middleText.modulate = Color.white
