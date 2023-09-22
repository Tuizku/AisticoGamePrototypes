extends RigidBody2D

export var Speed : int = 75
export var Score = 0

var items = [
	{
		"friendly" : true,
		"texture" : load("res://sprites/check.png"),
		"score" : 2
	},
	{
		"friendly" : true,
		"texture" : load("res://sprites/x.png"),
		"score" : -4
	}
]


func _ready():
	linear_velocity = Vector2(0, Speed)


func _on_Item_body_entered(_body):
	queue_free()

func create_item(item_data):
	get_node("Sprite").texture = load(item_data["texture"])
	Score = item_data["score"]
	# Finds possible item choices by a friendly bool and selects one of them, then it setups the item
	#var possibleChoices = []
	#for i in len(items):
		#if items[i]["friendly"] == friendly: possibleChoices.append(items[i])
	#var choice = items[randi() % len(items)]
	#get_node("Sprite").texture = choice["texture"]
	#Score = choice["score"]
