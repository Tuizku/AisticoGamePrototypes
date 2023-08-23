
class_name funcs

static func chr_amount_in(chr, word):
	var result = 0
	for i in len(word):
		if word[i] == chr: result += 1
	return result

static func single_chrs_in(word):
	var result : Array
	for i in len(word):
		if not word[i] in result and chr_amount_in(word[i], word) == 1: result.append(word[i])
	return result

static func chrs_in(word):
	var chrs : Array
	for i in len(word):
		if word[i] != "" and not word[i] in chrs: chrs.append(word[i])
	return len(chrs)

static func index_of(chr, word):
	var result = -1
	for i in len(word):
		if word[i] == chr: result = i
	return result

#static func random_new_chr_from_str(shown_chrs, word):
	#var rng = RandomNumberGenerator.new()
	#rng.randomize()
	#var loop = true
	#while loop:
		#var index = rng.randi_range(0, len(word) - 1)
		#if 
