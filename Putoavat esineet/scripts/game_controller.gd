extends Node2D

# Exports
export var StartSpawnTime : float = 5
export var StartItemSpeed : float = 200

# Variables
var wave = 1
var combo = 0
var comboMultiplier : int = 1
var points = 0
var itemScene = load("res://scenes/item.tscn")
var floatingLabelScene = load("res://scenes/floating_label.tscn")
onready var pointsText : Label = get_node("UI/HBoxContainer/PointsBox/Label")
onready var comboText : Label = get_node("UI/HBoxContainer/MultiplierBox/Label")
onready var waveText : Label = get_node("UI/WaveText")

func _ready():
	randomize()
	
	#for i in 20:
		#print(str(i + 1) + " " + str((i + 1) / 5))
	
	# Adjust players
	var screenSizeX = get_viewport_rect().size.x
	get_node("Player").position.x = screenSizeX / 6 * 1
	get_node("Player2").position.x = screenSizeX / 6 * 3
	get_node("Player3").position.x = screenSizeX / 6 * 5
	
	pointsText.text = "0"
	comboText.text = "x1"
	
	waveText.text = "Wave 1"
	yield(get_tree().create_timer(4), "timeout")
	waveText.text = ""
	waves()

func _physics_process(_delta):
	pass
	#print("wave: " + str(wave) + " | combo: " + str(combo))



func waves():
	for i in 10: # Run 10 waves
		var screenSizeX = get_viewport_rect().size.x
		var spawnTime
		var speed
		
		# Spawn items 5 times in ONE wave
		for itemGroupIndex in 5:
			var itemPositions = get_random_item_positions(1 + randi() % 3)
			spawnTime = (StartSpawnTime - 0.2 * wave)
			spawnTime -= spawnTime * 0.1 * comboMultiplier
			spawnTime -= rand_range(0, spawnTime * 0.5)
			speed = (StartItemSpeed + 15 * wave) + 40 * comboMultiplier
			
			for itemIndex in len(itemPositions):
				var instance = itemScene.instance()
				instance.Speed = speed
				instance.position = Vector2(screenSizeX / 6 * (1 + itemPositions[itemIndex] * 2), -50)
				instance.create_item(randi() % 2 == 1)
				add_child(instance)
			
			print(str(spawnTime) + " " + str(rand_range(0, 1)))
			yield(get_tree().create_timer(spawnTime), "timeout")
		
		# Wave Break Time
		wave += 1
		yield(get_tree().create_timer(4), "timeout")
		if wave <= 10: waveText.text = "Wave " + str(wave)
		yield(get_tree().create_timer(3), "timeout")
		waveText.text = ""


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
	if amount > 0: points += amount * comboMultiplier
	else: points += amount
	if points < 0: points = 0
	pointsText.text = str(points)
	
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
