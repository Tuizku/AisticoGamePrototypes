extends Node2D

# Exports
export var StartSpawnTime : float = 5
export var StartItemSpeed : float = 200

# Variables
var wave = 0
var combo = 0
var points = 0
var itemScene = load("res://scenes/item.tscn")
onready var pointsText : RichTextLabel = get_node("PointsText")

func _ready():
	randomize()
	
	# Adjust players
	var screenSizeX = get_viewport_rect().size.x
	get_node("Player").position.x = screenSizeX / 6 * 1
	get_node("Player2").position.x = screenSizeX / 6 * 3
	get_node("Player3").position.x = screenSizeX / 6 * 5
	
	yield(get_tree().create_timer(4), "timeout")
	waves()

func _physics_process(_delta):
	print("wave: " + str(wave) + " | combo: " + str(combo))



func waves():
	while true:
		var screenSizeX = get_viewport_rect().size.x
		var spawnTime
		var speed
		
		# Spawn items 5 times in ONE wave
		for itemGroupIndex in 5:
			var itemPositions = get_random_item_positions(1 + randi() % 3)
			spawnTime = (StartSpawnTime - 0.2 * wave) - (1 / 15) * combo
			speed = (StartItemSpeed + 15 * wave) + 5 * combo
			
			for itemIndex in len(itemPositions):
				var instance = itemScene.instance()
				instance.Speed = speed
				instance.position = Vector2(screenSizeX / 6 * (1 + itemPositions[itemIndex] * 2), -50)
				instance.create_item(randi() % 2 == 1)
				add_child(instance)
			
			yield(get_tree().create_timer(spawnTime), "timeout")
		
		# Wave Break Time
		yield(get_tree().create_timer(7), "timeout")
		wave += 1


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


func change_points(amount):
	points += amount
	if points < 0: points = 0
	pointsText.bbcode_text = "[center]" + str(points)

func inc_combo():
	combo += 1
	# some visuals later here

func lose_combo():
	combo = 0
	# some visuals later here
