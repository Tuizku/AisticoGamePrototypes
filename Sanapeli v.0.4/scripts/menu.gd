extends Control

# User Data Load and Save calls
onready var userData = data_control.load_user_data()
func _exit_tree(): data_control.save_user_data(userData)

func _ready():
	if userData["sounds"] == true: $VolumeButton/OnTexture.show()
	else: $VolumeButton/OnTexture.hide()


func change_scene(name):
	if get_tree().change_scene("res://scenes/" + name + ".tscn") != OK: print("scene change failed")


func _on_StartButton_pressed():
	change_scene("game")

func _on_VolumeButton_pressed():
	userData["sounds"] = not userData["sounds"]
	if userData["sounds"] == true: $VolumeButton/OnTexture.show()
	else: $VolumeButton/OnTexture.hide()

func _on_WordlistButton_pressed():
	change_scene("wordlist")
