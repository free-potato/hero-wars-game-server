extends Node

var searching_peers = []

func start_battle(peer_id_1, peer_id_2):
	var player_username_1 = AuthController.username(peer_id_1)
	var player_username_2 = AuthController.username(peer_id_2)
	var battle_id = Battle.create_battle(player_username_1, player_username_2)
	var battle = Battle.find(battle_id)
	battle["player_1"].erase("username")
	battle["player_2"].erase("username")
	rpc_id(peer_id_1, "remote_start_battle", battle_id, battle)
	rpc_id(peer_id_2, "remote_start_battle", battle_id, battle)
	

remote func remote_search_battle():
	var peer_id = get_tree().get_rpc_sender_id()
	if searching_peers.size() < 1:
		searching_peers.push_back(peer_id)
		return
	self.start_battle(peer_id, searching_peers.pop_front())
	
remote func remote_cancel_search_battle():
	var peer_id = get_tree().get_rpc_sender_id()
	self.searching_peers.erase(peer_id)
	rpc_id(peer_id, "remote_cancel_search_battle")
	
# TODO: refactor
remote func remote_searching_players():
	var peer_id = get_tree().get_rpc_sender_id()
	var players = Player.players()
	var searching_players = []
	for s_peer_id in searching_peers:
		searching_players.append(players[AuthController.username(s_peer_id)])
	
	rpc_id(peer_id, "remote_searching_players", searching_players)
	
	
