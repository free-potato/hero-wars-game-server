extends Node

const file_name = "player_inventory.dat"

func content(username):
	if not self.has_inventory(username): self.create_inventory(username)
	var player_inventories = self.player_inventories()
	return player_inventories[username.to_lower()]


func player_inventories():
	return Database.get_var(file_name)


func has_inventory(username):
	return self.player_inventories().has(username.to_lower())


func create_inventory(username):
	if self.has_inventory(username): return
	var inventory = {username.to_lower(): {}}
	Database.add_or_update_var(file_name, inventory)
