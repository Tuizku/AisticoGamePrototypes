extends Node2D

# Loaded stuff
onready var pointsText : Label = get_node("UI/HBoxContainer/PointsBox/Label")
onready var comboText : Label = get_node("UI/HBoxContainer/MultiplierBox/Label")
onready var centerText : Label = get_node("UI/CenterText")
var floatingLabelScene = load("res://scenes/floating_label.tscn")
var itemScene = load("res://scenes/item.tscn")
var itemRows

# Exports
export var StartSpawnTime : float = 5
export var StartItemSpeed : float = 200
export var LevelCount : int = 3
export var RowsToSpawn : Array = [3, 10] # Rows to spawn in slow and fast mode

# Variables
var STATE = 1
var time : float = 0
var rowsGenerated = 0

var score = 0
var combo = 0
var comboMultiplier : int = 1


#---------------------------------Functions-------------------------------------#

func get_random_item_positions(amount):
	# If amount is 1, select a random position. If 2-3, then select a possible
	# notIncluded position and select everything else
	var screenSizeX = get_viewport_rect().size.x
	var result = []
	if amount == 1:
		result.append(screenSizeX / 6 * (1 + randi() % 3 * 2))
	else:
		var notIncluded = -1
		if amount == 2: notIncluded = randi() % 3
		for i in 3:
			if i != notIncluded: result.append(screenSizeX / 6 * (1 + i * 2))
		result.shuffle()
	return result

func change_points(amount, player_index):
	if amount > 0: score += amount * comboMultiplier
	else: score += amount
	if score < 0: score = 0
	pointsText.text = str(score)
	
	# Floating Label Effect
	var screen = get_viewport_rect().size
	var instance : Label = floatingLabelScene.instance()
	instance.rect_position = Vector2(screen.x / 6 * (1 + player_index * 2), screen.y * 0.75)
	instance.rect_position.x -= instance.rect_size.x * 0.5
	add_child(instance)
	instance.start(amount, comboMultiplier)

func inc_combo():
	combo += 1
	comboMultiplier = 1 + combo / 5
	if comboMultiplier > 5: comboMultiplier = 5
	comboText.text = "x" + str(comboMultiplier)

func lose_combo():
	combo = 0
	comboMultiplier = 1
	comboText.text = "x1"

func control_state(input):
	if input == "next": STATE += 1
	elif input == "reset": STATE = 1
	time = 0

#---------------------------Controlling-Functions-------------------------------#

func _ready():
	randomize()
	
	# Load itemRows data
	var file = File.new()
	if file.open("res://data/itemrows_data.json", File.READ) == OK:
		var text = file.get_as_text()
		itemRows = parse_json(text)
	
	# Setup texts, show wave text for 4 seconds and start wave
	pointsText.text = "0"
	comboText.text = "x1"


func _process(delta):
	time += delta
	
	if STATE == 1: show_text("Nyt harkiten!") # Nopea: Nyt Tarkkana!
	elif STATE == 2: do_item_spawning(RowsToSpawn[0])
	elif STATE == 3: show_text("answers should be here...")
	elif STATE == 4: show_text("Nyt tarkkana!")
	elif STATE == 5: do_item_spawning(RowsToSpawn[1])
	elif STATE == 6: show_text("Hyvä hyvä!")
	elif STATE == 7: control_state("reset")
	


func show_text(text):
	if centerText.text != text: centerText.text = text
	if time > 4:
		centerText.text = ""
		control_state("next")



func do_item_spawning(spawn_rows_amount):
	var speed = 200
	var spawnTime = 5
	
	print(str(time) + "  " + str(rowsGenerated * spawnTime))
	# Spawn a row of items when spawnTime amount elapsed after last row spawning
	if time >= rowsGenerated * spawnTime:
		# If enough items are spawned, go to next state
		if rowsGenerated >= spawn_rows_amount:
			rowsGenerated = 0
			control_state("next")
			return
		
		var selectedRow = itemRows[randi() % len(itemRows)]
		var itemPositions = get_random_item_positions(len(selectedRow))
		
		# Spawn the items
		for itemIndex in len(selectedRow):
			var item_data = selectedRow[itemIndex]
			var instance = itemScene.instance()
			instance.Speed = speed
			instance.position = Vector2(itemPositions[itemIndex], -50)
			instance.create_item(item_data)
			add_child(instance)
			
		rowsGenerated += 1
