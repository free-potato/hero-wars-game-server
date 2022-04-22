extends Node

# TODO: refactor
func leaderboard_data():
	var players = Player.players()
	var battle_points = []
	
	for value in players.values():
		if value["battle_points"] > 0: battle_points.push_back(value["battle_points"])
	
	battle_points.sort()
	battle_points.invert()
	battle_points.slice(0, 9)
	var min_battle_point = battle_points.min()
	var leaderboard_data = {}
	
	for value in players.values():
		if value["battle_points"] >= min_battle_point:
			leaderboard_data[value["id"]] = value
			
	return leaderboard_data
	

remote func remote_leaderboard_data_request():
	var peer_id = get_tree().get_rpc_sender_id()
	var leaderboard_data = self.leaderboard_data()
	rpc_id(peer_id, "remote_leaderboard_data", leaderboard_data)
	
