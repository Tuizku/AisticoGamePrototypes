extends Control

var placement_label = load("res://scenes/placement_label.tscn")

# This is used to sort the placements data from biggest to smallest
func biggest_to_smallest(a, b):
	return b - a

func _ready():
	# Load placements data, sort and show top 5 or under
	var data = datamanager.load_save_var("placements")
	data.sort()
	data.sort_custom(self, "biggest_to_smallest")
	for i in int(min(len(data), 5)): # Show placements up to top 5
		var instance = placement_label.instance()
		instance.text = str(i + 1) + ".  " + str(data[i])
		get_node("VBoxContainer").add_child(instance)

func _physics_process(_delta):
	if Input.is_key_pressed(KEY_SPACE):
		var _sceneInstance = get_tree().change_scene("res://scenes/main.tscn")
