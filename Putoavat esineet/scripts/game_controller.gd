extends Node2D

# Loaded stuff
onready var pointsText : Label = get_node("UI/HBoxContainer/PointsBox/Label")
onready var comboText : Label = get_node("UI/HBoxContainer/MultiplierBox/Label")
onready var centerText : Label = get_node("UI/CenterText")
var floatingLabelScene = load("res://scenes/floating_label.tscn")
var itemScene = load("res://scenes/item.tscn")
var itemRows

# Exports
export var LevelAmount : int = 3
export var SelectRowsAmount : int = 3
export var FastModeSettings = {
	"startSpeed": 250,
	"startSpawnTime": 4,
	"valueFlickeringPercentage": 0.2,
	"speedIncByTime": 10,
	"spawnTimeDecByTime": 0.15,
	"speedIncByMultiplier": 30,
	"spawnTimeDecByMultiplier": 0.25
}

# Variables
var selectedRows # holds all rows that will be played in this level
var STATE = 0 # game state
var time : float = 0 # used time in current state
var rowsGenerated = 0
var lastRowSpawnedTime : float = -FastModeSettings["startSpawnTime"]

var learningRowsLeft : Array = [] # holds all the rows that haven't been learned yet
var fastModeSpeed = FastModeSettings["startSpeed"]
var fastModeSpawnTime = FastModeSettings["startSpawnTime"]

var score = 0 # total score
var multiplier = 1 # multiplies catched scores
var combo = 0 # multiplier increases by every 5 combos


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
	if amount > 0: score += amount * multiplier
	else: score += amount
	if score < 0: score = 0
	pointsText.text = str(score)
	
	# Floating Label Effect
	var screen = get_viewport_rect().size
	var instance : Label = floatingLabelScene.instance()
	instance.rect_position = Vector2(screen.x / 6 * (1 + player_index * 2), screen.y * 0.75)
	instance.rect_position.x -= instance.rect_size.x * 0.5
	add_child(instance)
	instance.start(amount, multiplier)

func inc_combo():
	combo += 1
	multiplier = 1 + combo / 5
	if multiplier > 5: multiplier = 5
	comboText.text = "x" + str(multiplier)

func lose_combo():
	combo = 0
	multiplier = 1
	comboText.text = "x1"

var callsByRow = 0
var correctCallItems = 0
func was_row_learned(_score, _row_data):
	# This gets called by the collected and freed items. When all row's items have called here,
	# the row gets either erased from learningRowsLeft or nothing happens to it
	if len(learningRowsLeft) == 0: return
	
	callsByRow += 1
	if _score < 0: correctCallItems = -1
	elif correctCallItems != -1 and _score > 0: correctCallItems += 1
	
	if callsByRow >= len(_row_data): # If all items have called here
		if correctCallItems >= 1: learningRowsLeft.erase(_row_data)
		callsByRow = 0
		correctCallItems = 0

func control_state(input, waitTime):
	if input == "next": STATE += 1
	elif input == "reset": 
		STATE = 0
		LevelAmount -= 1
		if LevelAmount <= 0:
			datamanager.add_int_to_save_var(score, "placements")
			var _sceneInstance = get_tree().change_scene("res://scenes/end.tscn")
	if waitTime > 0:
		var oldState = STATE
		STATE = -1
		
		var timer = Timer.new()
		timer.wait_time = waitTime
		timer.one_shot = true
		add_child(timer)
		timer.start()
		yield(timer, "timeout")
		timer.queue_free()
		STATE = oldState
	
	time = 0

#---------------------------Controlling-Functions-------------------------------#

func _ready():
	randomize()
	
	# Load itemRows data
	var file = File.new()
	if file.open("res://data/itemrows_data.json", File.READ) == OK:
		var text = file.get_as_text()
		itemRows = parse_json(text)
	
	# Setup texts
	pointsText.text = "0"
	comboText.text = "x1"


func _process(delta):
	time += delta
	
	if STATE == 0:
		# Reset values
		fastModeSpawnTime = FastModeSettings["startSpawnTime"]
		lastRowSpawnedTime = -FastModeSettings["startSpawnTime"]
		
		# Select new rows to be played
		selectedRows = []
		var rows : Array = itemRows
		rows.shuffle()
		for i in range(SelectRowsAmount):
			selectedRows.append(rows[i])
		
		# Setup the learningRowsLeft and go to the next state
		learningRowsLeft = selectedRows.duplicate()
		control_state("next", 0)
	if STATE == 1: show_text("Nyt harkiten!")
	elif STATE == 2: learn_item_spawning()
	elif STATE == 3: show_text("answers should be here...")
	elif STATE == 4: show_text("Nyt tarkkana!")
	elif STATE == 5: fast_item_spawning(10)
	elif STATE == 6: show_text("Hyvä hyvä!")
	elif STATE == 7: control_state("reset", 3)


func show_text(text):
	if centerText.text != text: centerText.text = text
	if time > 4:
		centerText.text = ""
		control_state("next", 0)


func learn_item_spawning():
	var speed = 200
	var spawnTime = 7
	
	# Spawn a row of items when spawnTime amount elapsed after last row spawning
	if time >= rowsGenerated * spawnTime:
		# If all rows have been learned, go to next state
		if len(learningRowsLeft) == 0:
			rowsGenerated = 0
			control_state("next", 3)
			return
		
		var selectedRow = learningRowsLeft[randi() % len(learningRowsLeft)]
		var itemPositions = get_random_item_positions(len(selectedRow))
		
		# Spawn the items
		for itemIndex in len(selectedRow):
			var itemData = selectedRow[itemIndex]
			var instance = itemScene.instance()
			instance.Speed = speed
			instance.position = Vector2(itemPositions[itemIndex], -100)
			instance.create_item(itemData, selectedRow)
			add_child(instance)
		rowsGenerated += 1


func fast_item_spawning(spawn_rows_amount):
	# Spawn a row of items when spawnTime amount elapsed after last row spawning
	if time >= lastRowSpawnedTime + fastModeSpawnTime:
		# If enough items are spawned, go to next state
		if rowsGenerated >= spawn_rows_amount:
			rowsGenerated = 0
			control_state("next", 3)
			return
		
		# Update speed and spawnTime
		var flickering = FastModeSettings["valueFlickeringPercentage"]
		fastModeSpeed = FastModeSettings["startSpeed"] # SPEED:
		fastModeSpeed += FastModeSettings["speedIncByTime"] * rowsGenerated
		fastModeSpeed += FastModeSettings["speedIncByMultiplier"] * (multiplier - 1)
		fastModeSpeed += fastModeSpeed * rand_range(flickering * -0.5, flickering * 0.5)
		fastModeSpawnTime = FastModeSettings["startSpawnTime"] # SPAWNTIME:
		fastModeSpawnTime -= FastModeSettings["spawnTimeDecByTime"] * rowsGenerated
		fastModeSpawnTime -= FastModeSettings["spawnTimeDecByMultiplier"] * (multiplier - 1)
		fastModeSpawnTime += fastModeSpawnTime * rand_range(flickering * -0.5, flickering * 0.5)
		
		var selectedRow = selectedRows[randi() % len(selectedRows)]
		var itemPositions = get_random_item_positions(len(selectedRow))
		
		# Spawn the items
		for itemIndex in len(selectedRow):
			var item_data = selectedRow[itemIndex]
			var instance = itemScene.instance()
			instance.Speed = fastModeSpeed
			instance.position = Vector2(itemPositions[itemIndex], -100)
			instance.create_item(item_data, selectedRow)
			add_child(instance)
			
		rowsGenerated += 1
		lastRowSpawnedTime = time
