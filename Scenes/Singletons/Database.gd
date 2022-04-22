extends Node

const path_to_directory = "res://data/"

func get_var(filename):
	var file = File.new()
	file.open(path_to_directory + filename, File.READ)
	var data = file.get_var()
	file.close()
	
	if data == null: data = {}
	
	return data


func add_or_update_var(filename, dict):
	if typeof(dict) != TYPE_DICTIONARY: return
	
	var data = self.get_var(filename)
	for dict_key in dict.keys():
		data[dict_key] = dict[dict_key]
	
	var file = File.new()
	file.open(path_to_directory + filename, File.WRITE)
	file.store_var(data)
	file.close()
	
