extends Control
class_name end_controller

var userData = data_control.load_user_data()
var wordScene : PackedScene = load("res://scenes/word.tscn")
var gameOverview = []
var correctWords = []
var time : float = 0
var wordsShown = 0
var objs = []

func _ready():
	gameOverview = Global.GameOverview
	var correct = 0
	var total_points = 0
	for i in len(gameOverview):
		total_points += gameOverview[i]["points"]
		if gameOverview[i]["points"] != 0: 
			correct += 1
			correctWords.append(gameOverview[i])
	$CorrectLabel.text = str(correct) + "/6 oikein"
	$PointsLabel.text = str(total_points) + " pistettä"

func _physics_process(delta):
	time += delta
	if time < len(correctWords) and time > wordsShown:
		objs.append(wordScene.instance())
		$WordsContainer.add_child(objs[-1])
		objs[-1].get_node("AnimationPlayer").play("SlideToScreen")
		
		var word = correctWords[wordsShown]["word"]
		var wordIndex = 0
		for i in len(userData["words"]):
			if userData["words"][i]["word"] == word: wordIndex = i
		objs[-1].reveal_after_delay(correctWords[wordsShown]["word"], userData["words"][wordIndex]["stars"], 1)
		wordsShown += 1



func _on_MenuButton_pressed():
	if get_tree().change_scene("res://scenes/menu.tscn") != OK: print("scene change failed")


func _on_WordlistButton_pressed():
	if get_tree().change_scene("res://scenes/wordlist.tscn") != OK: print("scene change failed")
