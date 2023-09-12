extends Area2D

export var PlayerIndex : int = 0
var keys = ["ui_left", "ui_down", "ui_right"]

func _physics_process(_delta):
	if Input.is_action_just_pressed(keys[PlayerIndex]):
		if visible:
			hide()
		else: 
			show()


func _on_Player_body_entered(body):
	if visible and body.is_in_group("item"):
		print(body.Score)
		body.queue_free()
