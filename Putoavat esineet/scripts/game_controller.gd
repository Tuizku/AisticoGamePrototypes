extends Node2D

# Exports
export var StartSpawnTime : float = 5
export var StartItemSpeed : float = 200
export var WaveCount : int = 10

# Variables
var wave = 1
var combo = 0
var comboMultiplier : int = 1
var score = 0

var itemRows
var itemScene = load("res://scenes/item.tscn")
var floatingLabelScene = load("res://scenes/floating_label.tscn")
onready var pointsText : Label = get_node("UI/HBoxContainer/PointsBox/Label")
onready var comboText : Label = get_node("UI/HBoxContainer/MultiplierBox/Label")
onready var waveText : Label = get_node("UI/WaveText")


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
	waveText.text = "Wave 1"
	yield(get_tree().create_timer(4), "timeout")
	waveText.text = ""
	waves()


func waves():
	# Run WaveCount amount of waves
	for i in WaveCount: 
		var screenSizeX = get_viewport_rect().size.x
		var spawnTime
		var speed
		
		# Spawn items 5 times in ONE wave
		for itemGroupIndex in 5:
			# Select 1-3 item positions randomly, then adjust spawnTime and speed of items
			var itemPositions = get_random_item_positions(1 + randi() % 3)
			spawnTime = (StartSpawnTime - 0.2 * wave)
			spawnTime -= spawnTime * 0.1 * comboMultiplier
			spawnTime -= rand_range(0, spawnTime * 0.5)
			speed = (StartItemSpeed + 15 * wave) + 40 * comboMultiplier
			
			# Spawn the row of items
			for itemIndex in len(itemPositions):
				var instance = itemScene.instance()
				instance.Speed = speed
				instance.position = Vector2(screenSizeX / 6 * (1 + itemPositions[itemIndex] * 2), -50)
				instance.create_item(randi() % 2 == 1)
				add_child(instance)
			
			# Wait for spawnTime
			yield(get_tree().create_timer(spawnTime), "timeout")
		
		# Wave Break Time (Timeouts and show next wave text)
		wave += 1
		yield(get_tree().create_timer(4), "timeout")
		if wave <= WaveCount: waveText.text = "Wave " + str(wave)
		yield(get_tree().create_timer(3), "timeout")
		waveText.text = ""
	
	# Game ended, save score and go to the end scene
	datamanager.add_int_to_save_var(score, "placements")
	var _sceneInstance = get_tree().change_scene("res://scenes/end.tscn")



func get_random_item_positions(amount):
	# If amount is 1, select a random position. If 2-3, then select a possible
	# notIncluded position and select everything else
	var result = []
	if amount == 1:
		result.append(randi() % 3)
	else:
		var notIncluded = -1
		if amount == 2: notIncluded = randi() % 3
		for i in 3:
			if i != notIncluded: result.append(i)
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
