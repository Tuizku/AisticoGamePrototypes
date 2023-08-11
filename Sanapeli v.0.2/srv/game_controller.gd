extends Control

var handPos : float = -1
var boxSelectedTime : float = 0

# Sana, sula, sala - A, L, U, N
var hint = "s  a"
var words

signal words_selected(hint_chrs)
signal char_box_selected(box_index)

func _ready():
	emit_signal("words_selected", hint)

func _physics_process(delta: float) -> void:
	# Is "joystick" is not touched after it was?
	if not Input.is_key_pressed(KEY_SPACE) and handPos != -1:
		handPos = -1
		emit_signal("char_box_selected", int(handPos)) # Send signal to boxes
	
	# Is "joystick" touched after it wasn't?
	if Input.is_key_pressed(KEY_SPACE) and handPos == -1:
		handPos = 0
		emit_signal("char_box_selected", int(handPos)) # Send signal to boxes
	
	# Change Hand Pos and send signal
	if Input.is_action_just_pressed("ui_up"):
		handPos += 1
		boxSelectedTime = 0 # Reset Selected Timer
		emit_signal("char_box_selected", int(handPos)) # Send signal to boxes
	if Input.is_action_just_pressed("ui_down"):
		handPos -= 1
		boxSelectedTime = 0 # Reset Selected Timer
		emit_signal("char_box_selected", int(handPos)) # Send signal to boxes
	
	#boxSelectedTime += delta
	#if (boxSelectedTime >= 2):
		
