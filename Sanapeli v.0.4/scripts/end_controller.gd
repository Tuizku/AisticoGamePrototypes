extends Control
class_name end_controller

var gameOverview = []
var tryAgainTimer : int = 0
var sensor_button_time : float = 0

func _ready():
	gameOverview = Global.GameOverview
	var correct = 0
	var total_points = 0
	for i in len(gameOverview):
		total_points += gameOverview[i]["points"]
		if gameOverview[i]["points"] != 0: correct += 1
	$CorrectLabel.text = str(correct) + "/6 oikein"
	$PointsLabel.text = str(total_points) + " pistettä"


func _on_Button_pressed():
	if get_tree().change_scene("res://scenes/menu.tscn") != OK: print("scene change failed")
