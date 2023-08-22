extends Control

var fill

func _ready():
	fill = get_child(1)

func _on_Control_change_time(timeAnchor):
	fill.anchor_right = timeAnchor
