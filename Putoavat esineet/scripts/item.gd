extends RigidBody2D

export var Speed : int = 75
export var Score = 0

var good_item_texture = load("res://sprites/check.png")
var bad_item_texture = load("res://sprites/x.png")


func _ready():
	linear_velocity = Vector2(0, Speed)


func _on_Item_body_entered(_body):
	queue_free()

func create_item(friendly):
	if friendly:
		get_node("Sprite").texture = good_item_texture
		Score = 2
	else:
		get_node("Sprite").texture = bad_item_texture
		Score = -2
