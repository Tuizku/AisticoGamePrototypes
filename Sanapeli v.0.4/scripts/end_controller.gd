extends Control
class_name end_controller

var userData = data_control.load_user_data()
var wordScene : PackedScene = load("res://scenes/word.tscn")
var gameOverview = []
var time : float = 0
var wordsShown = 0
var wordsRevealed = 0
var objs = []

func _ready():
	gameOverview = Global.GameOverview
	var correct = 0
	var total_points = 0
	for i in len(gameOverview):
		total_points += gameOverview[i]["points"]
		if gameOverview[i]["points"] != 0: correct += 1
	$CorrectLabel.text = str(correct) + "/6 oikein"
	$PointsLabel.text = str(total_points) + " pistettä"

func _physics_process(delta):
	time += delta
	if time < len(gameOverview) and time > wordsShown:
		wordsShown += 1
		objs.append(wordScene.instance())
		$WordsContainer.add_child(objs[-1])
		objs[-1].get_node("AnimationPlayer").play("SlideToScreen")
	if time - 1 < len(gameOverview) and time > wordsRevealed + 1:
		var word = gameOverview[len(objs) - 2]["word"]
		var wordIndex = 0
		for i in len(userData["words"]):
			if userData["words"][i]["word"] == word: wordIndex = i
		objs[-2].setup(word, userData["words"][wordIndex]["stars"])


func _on_Button_pressed():
	if get_tree().change_scene("res://scenes/menu.tscn") != OK: print("scene change failed")
