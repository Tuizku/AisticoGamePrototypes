extends Control
class_name end_controller

var points : Array = []
var tryAgainTimer : int = 0
var sensor_button_time : float = 0

func _ready():
	points = Global.Points
	var correct = 0
	var total_points = 0
	for i in len(points):
		total_points += points[i]
		if points[i] != 0: correct += 1
	get_node("Main Text").bbcode_text = "[center]" + str(correct) + "/6 oikein!"
	get_node("Points Text").bbcode_text = "[center]" + str(total_points) + " pistettä"

func _physics_process(delta):
	if Input.is_action_pressed("sensor button"): sensor_button_time += delta
	else: sensor_button_time = 0
	
	if Input.is_action_just_pressed("ui_up") or sensor_button_time > 1:
		if get_tree().change_scene("res://srv/game.tscn") != OK: print("scene change failed")
