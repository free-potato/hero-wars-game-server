extends Node

const file_name = "player_chest.dat"

func content(username):
	if not self.has_chest(username): self.create_chest(username)
	var player_chests = self.player_chests()
	return player_chests[username.to_lower()]


func has_chest(username):
	return player_chests().has(username.to_lower())


func player_chests():
	return Database.get_var(file_name)


func chest_template():
	var template = {
		"gold": 1000,
		"diamond": 5
	}
	return template


func create_chest(username):
	if self.has_chest(username): return
	var player_chest = {username.to_lower(): self.chest_template()}
	Database.add_or_update_var(file_name, player_chest)
