extends Node

class_name PlayerClass

var username: String

func _init(username:String):
	if not Player.player_exists(username):
		push_error("PlayerNotFound")
		return
	self.username = username
	
func username():
	return self.username

func info():
	return Player.player_info(self.username)
	
func id():
	return Player.player_info(self.username)["id"]

func peer_id():
	return AuthController.user_peer_id(self.username) 
	
func display_name():
	return Player.player_info(self.username)["display_name"]

func character():
	return Character.info(self.username)
	
func battle_won():
	var player_info = self.info()
	player_info["wins"] = int(player_info["wins"]) + 1
	player_info["battle_points"] = int(player_info["battle_points"]) + 100
	Player.update_player_info(self.username, player_info)
	
func battle_lost():
	var player_info = self.info()
	player_info["losses"] = int(player_info["losses"]) + 1
	player_info["battle_points"] = int(player_info["battle_points"]) - 20
	if int(player_info["battle_points"]) < 0: player_info["battle_points"] = 0
	Player.update_player_info(self.username, player_info)

