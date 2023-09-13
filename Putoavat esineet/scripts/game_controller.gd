extends Node2D

# Exports
export var SpawnTime : float = 5
export var ItemSpeed : float = 200
export (float, 0, 1) var DifficultyIncreasePercentage = 0.1

# Variables
var points = 0
var itemScene
var pointsText : RichTextLabel

func _ready():
	randomize()
	itemScene = load("res://scenes/item.tscn")
	pointsText = get_node("PointsText")
	
	# Adjust players
	var screenSizeX = get_viewport_rect().size.x
	get_node("Player").position.x = screenSizeX / 6 * 1
	get_node("Player2").position.x = screenSizeX / 6 * 3
	get_node("Player3").position.x = screenSizeX / 6 * 5
	
	waves()

func _process(_delta):
	# Spawn items when the SpawnTime has elapsed. SpawnTime decreases over time and ItemSpeed increases
	"""currentSpawnTime -= delta
	if currentSpawnTime <= 0:
		spawn_items()
		SpawnTime -= SpawnTime * DifficultyIncreasePercentage
		currentSpawnTime = SpawnTime
		ItemSpeed += ItemSpeed * DifficultyIncreasePercentage"""



func waves():
	while true:
		var screenSizeX = get_viewport_rect().size.x
		for itemGroupIndex in 5:
			yield(get_tree().create_timer(SpawnTime + rand_range(-0.5, 0.5)), "timeout")
			
			var itemPositions = get_random_item_positions(1 + randi() % 3)
			for itemIndex in len(itemPositions):
				var instance = itemScene.instance()
				instance.Speed = ItemSpeed
				instance.position = Vector2(screenSizeX / 6 * (1 + itemPositions[itemIndex] * 2), -50)
				instance.create_item(randi() % 2 == 1)
				add_child(instance)
		
		# Wave Break Time
		yield(get_tree().create_timer(7), "timeout")
		SpawnTime -= SpawnTime * DifficultyIncreasePercentage
		ItemSpeed += ItemSpeed * DifficultyIncreasePercentage

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
	pointsText.bbcode_text = "[center]" + str(points)
