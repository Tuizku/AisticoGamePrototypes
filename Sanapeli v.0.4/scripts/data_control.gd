class_name data_control

const path = "user://user_data.json"
#const defaultData = {
#	"stars": [],
#	"highscore" : 0,
#	"sounds" : true,
#	"mailSceneShown": false
#}
const defaultData = {
	"words" : [
		{
			"word" : "",
			"definition" : "",
			"stars" : 0
		}
	],
	"highscore" : 0,
	"difficulty" : 0.3,
	"sounds" : true,
	"mailSceneShown": false
}

static func save_user_data(data):
	var file = File.new()
	var saveData
	if data != null: saveData = data
	else: 
		saveData = defaultData.duplicate()
		var wordsData = load_words()
		for i in len(wordsData):
			var word
			if i >= len(saveData["words"]):
				word = defaultData["words"][0].duplicate()
				saveData["words"].append(word)
			saveData["words"][i]["word"] = wordsData[i]["word"]
			saveData["words"][i]["definition"] = wordsData[i]["definition"]
	file.open(path, File.WRITE)
	file.store_var(to_json(saveData))
	file.close()

static func load_user_data():
	var file = File.new()
	if file.file_exists(path):
		file.open(path, File.READ)
		var loadedData = parse_json(file.get_var())
		file.close()
		if loadedData != null:
			return loadedData
	else: save_user_data(null)
	return null

static func load_words():
	var file = File.new()
	if not file.file_exists("res://data/words.json.tres"):
		return null
	file.open("res://data/words.json.tres", File.READ)
	var text = file.get_as_text()
	return parse_json(text)
