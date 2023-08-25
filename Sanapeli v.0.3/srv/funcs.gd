
class_name funcs

static func chr_amount_in(chr, word):
	var result = 0
	for i in len(word):
		if word[i] == chr: result += 1
	return result

static func single_chrs_in(word):
	var result : Array = []
	for i in len(word):
		if not word[i] in result and chr_amount_in(word[i], word) == 1: result.append(word[i])
	return result

static func chrs_in(word):
	var chrs : Array = []
	for i in len(word):
		if word[i] != "" and not word[i] in chrs: chrs.append(word[i])
	return len(chrs)

static func index_of(chr, word):
	var result = -1
	for i in len(word):
		if word[i] == chr: result = i
	return result

const correct_sentences = ["Hyvin löydetty!", "Hyvää työtä!", "Oikein!", "Mahtavaa!", "Hienoa!", "Mahtavaa päättelyä!"]
static func random_correct_sentence():
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return correct_sentences[rng.randi_range(0, len(correct_sentences) - 1)]

const wrong_sentences = ["Väärin!", "Ensi kerralla parempi onni!", "Ei osunut tällä kertaa...", "Ei aivan..."]
static func random_wrong_sentence():
	var rng : RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	return wrong_sentences[rng.randi_range(0, len(wrong_sentences) - 1)]
