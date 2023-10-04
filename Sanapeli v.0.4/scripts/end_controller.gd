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
	$CorrectLabel.text = str(correct) + "/6 oikein"
	$PointsLabel.text = str(total_points) + " pistettä"


func _on_Button_pressed():
	if get_tree().change_scene("res://scenes/menu.tscn") != OK: print("scene change failed")
