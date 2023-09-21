class_name datamanager


# Adds int to a save file that holds one variable (a list of ints)
static func add_int_to_save_var(number, file_name):
	var save = File.new()
	var list : Array = []
	
	# First try to load old data, then setups for writing data
	if save.open("user://" + str(file_name) + ".data", File.READ) == OK:
		list = save.get_var()
		save.close()
	save.open("user://" + str(file_name) + ".data", File.WRITE)
	
	# Add new number to list that will be saved
	list.append(number)
	save.store_var(list)
	save.close()


# Load the only variable in a save file
static func load_save_var(file_name):
	var save = File.new()
	if save.open("user://" + str(file_name) + ".data", File.READ) == OK:
		var result = save.get_var()
		save.close()
		return result
