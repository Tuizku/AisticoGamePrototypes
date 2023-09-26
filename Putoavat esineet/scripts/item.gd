extends RigidBody2D

export var Speed : int = 75
export var Score = 0

var rowData
onready var gameController = get_parent()



func _ready():
	linear_velocity = Vector2(0, Speed)


func _on_Item_body_entered(_body):
	gameController.was_row_learned(0, rowData)
	queue_free()


func create_item(item_data, row_data):
	get_node("Sprite").texture = load(item_data["texture"])
	Score = item_data["score"]
	rowData = row_data
