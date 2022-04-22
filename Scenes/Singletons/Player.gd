extends Node

const player_id_filename = "player_id.dat"
const player_info_filename = "player_info.dat"

func player_exists(username):
	return self.players().has(username.to_lower())
	
func player_info(username):
	username = username.to_lower()
	var players = self.players()
	var player_info = players[username] if players.has(username) else {}
	return player_info

func players():
	return Database.get_var(player_info_filename)
	
func player_id_pairs():
	return Database.get_var(player_id_filename)

func find_by_id(player_id):
	var player_id_pairs = self.player_id_pairs()
	if player_id_pairs.has(player_id):
		return PlayerClass.new(player_id_pairs[player_id])
	return null
	
	
func update_player_info(username, new_data):
	if not self.player_exists(username): return
	username = username.to_lower()
	var player_info = {username: new_data}
	Database.add_or_update_var(player_info_filename, player_info)
	
func create_player(username):
	username = username.to_lower()
	if self.player_exists(username): return false
	
	var player_id = self.create_player_id(username)
	var player_info = {
		"display_name": null,
		"id": player_id,
		"battle_points": 0,
		"wins": 0,
		"losses": 0
	}
	
	var player = {username: player_info}
	
	Database.add_or_update_var(player_info_filename, player)
	
	Character.create_character(username)
	Chest.create_chest(username)
	Inventory.create_inventory(username)
	
	return true
	
func create_player_id(username):
	var player_id_pairs = self.player_id_pairs()
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var player_id = rng.randi_range(1000, 1000000)
	while player_id_pairs.has(player_id):
		player_id = rng.randi_range(1000, 1000000)
	
	var player_id_pair = {player_id: username.to_lower()}
	Database.add_or_update_var(player_id_filename, player_id_pair)
	
	return player_id
	
remote func remote_player_info():
	var peer_id = get_tree().get_rpc_sender_id()
	var username = AuthController.username(peer_id)
	if username == null: return # TODO: send unauthenticated to client
	
	var player_info = self.player_info(username)
	rpc_id(peer_id, "remote_player_info", player_info)
	
func update_display_name(username, new_name):
	if not self.player_exists(username): return
	if (new_name.length() > 32 || new_name.length() < 1): return
	var player_info = self.player_info(username)
	player_info["display_name"] = new_name
	self.update_player_info(username, player_info)
	
	
remote func remote_update_display_name(new_name):
	var peer_id = get_tree().get_rpc_sender_id()
	var username = AuthController.username(peer_id)
	if username == null: return # TODO: send unauthenticated to client
	self.update_display_name(username, new_name)
	
	
