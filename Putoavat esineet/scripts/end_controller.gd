extends Control

var placement_label = load("res://scenes/placement_label.tscn")

func _ready():
	# Load placements rawData and sort from smallest to biggest
	var rawData = datamanager.load_save_var("placements")
	rawData.sort()
	
	# Add values to data from biggest to smallest
	var data : Array = []
	for i in len(rawData): # sort from biggest to smallest
		data.append(rawData[len(rawData) - 1 - i])
	
	
	# Show placements up to top 5
	for i in int(min(len(data), 5)):
		var instance = placement_label.instance()
		instance.text = str(i + 1) + ".  " + str(data[i])
		get_node("VBoxContainer").add_child(instance)

func _physics_process(_delta):
	if Input.is_key_pressed(KEY_SPACE):
		var _sceneInstance = get_tree().change_scene("res://scenes/main.tscn")
