extends Label

export var FloatingSpeed : float = 0.7
export var ShowTime : float = 3

func _physics_process(_delta):
	rect_position.y -= FloatingSpeed


func start(item_score, multiplier):
	if item_score > 0: 
		#modulate = Color.limegreen
		text = str(item_score) + "x" + str(multiplier)
		yield(get_tree().create_timer(ShowTime * 0.5), "timeout")
		text = str(item_score * multiplier)
		yield(get_tree().create_timer(ShowTime * 0.5), "timeout")
	else: 
		#modulate = Color.red
		text = str(item_score)
		yield(get_tree().create_timer(ShowTime), "timeout")
	queue_free()
