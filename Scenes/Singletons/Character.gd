extends Node

const file_name = "player_character.dat"

func info(username):
	if not self.has_character(username): self.create_character(username)
	var player_characters = self.player_characters()
	return player_characters[username.to_lower()]


func character_template():
	var character_template = {
		"attack": 100,
		"intelligence": 30,
		"defence": 10,
		"magic_defence": 20,
		"hp": 800,
		"mp": 300,
		"hp_reg": 20,
		"mp_reg": 15,
		"xp": 0
	}
	return character_template


func has_character(username):
	return self.player_characters().has(username.to_lower())


func player_characters():
	return Database.get_var(file_name)


func create_character(username):
	if self.has_character(username): return
	
	var player_character = {username.to_lower(): self.character_template()}
	
	Database.add_or_update_var(file_name, player_character)

remote func remote_character_info():
	var peer_id = get_tree().get_rpc_sender_id()
	var username = AuthController.username(peer_id)
	if username == null: return # TODO: send unauthenticated to client
	
	var character_info = self.info(username)
	rpc_id(peer_id, "remote_character_info", character_info)
