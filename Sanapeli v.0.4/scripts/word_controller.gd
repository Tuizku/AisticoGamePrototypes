extends Control

var starFilledTexture = load("res://sprites/star_filled_glow.png")


func setup(word, stars_amount):
	if stars_amount == 0: return
	$Word.text = word
	for starIndex in range(stars_amount):
		get_node("Star" + str(starIndex + 1)).texture = starFilledTexture

func reveal_after_delay(word, stars_amount, delay_time):
	var timer = Timer.new()
	timer.wait_time = delay_time
	timer.one_shot = true
	add_child(timer)
	timer.start()
	yield(timer, "timeout")
	timer.queue_free()
	setup(word, stars_amount)
