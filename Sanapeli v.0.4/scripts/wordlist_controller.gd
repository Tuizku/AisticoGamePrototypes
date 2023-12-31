extends Control

# User Data Load and Save calls
onready var userData = data_control.load_user_data()
func _exit_tree(): data_control.save_user_data(userData)
#onready var wordsData = data_control.load_words()

var wordScene = load("res://scenes/word.tscn")


func _ready():
	for i in len(userData["words"]):
		var wordObj : Control = wordScene.instance()
		wordObj.setup(userData["words"][i]["word"], userData["words"][i]["stars"])
		$ScrollContainer/VBoxContainer.add_child(wordObj)


func change_scene(name):
	if get_tree().change_scene("res://scenes/" + name + ".tscn") != OK: print("scene change failed")


func _on_BackButton_pressed():
	change_scene("menu")


func _on_MoreWordsButton_pressed():
	change_scene("mail")
