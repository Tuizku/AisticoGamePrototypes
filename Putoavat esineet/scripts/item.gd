extends RigidBody2D

export var Speed : int = 75
export var Score = -2

func _ready():
	linear_velocity = Vector2(0, Speed)


func _on_Item_body_entered(_body):
	queue_free()

func getsmth():
	return 20
