extends Control

func change_scene(name):
	if get_tree().change_scene("res://scenes/" + name + ".tscn") != OK: print("scene change failed")



func _on_LaterButton_pressed():
	change_scene("menu")
