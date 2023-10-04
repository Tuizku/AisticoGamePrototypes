extends Control

var starFilledTexture = load("res://sprites/star_filled_glow.png")

func setup(word, stars_amount):
	if stars_amount == 0: return
	$Word.text = word
	for starIndex in range(stars_amount):
		get_node("Star" + str(starIndex + 1)).texture = starFilledTexture
