extends Node

# TODO: store these in disk instead of vars
var token_player_pairs = {}
var peer_player_pairs  = {}

func username(peer_id):
	if peer_player_pairs.has(peer_id): return peer_player_pairs[peer_id]
	return null
	
func user_peer_id(username):
	var user_peer_id = null
	for peer_id in peer_player_pairs.keys():
		if peer_player_pairs[peer_id] == username: 
			user_peer_id = peer_id
			break
	return user_peer_id
	
func remove_peer(peer_id):
	peer_player_pairs.erase(peer_id)

# TODO: remove prev user tokens
func save_token(token, username):
	token_player_pairs[token] = {
		"username": username.to_lower(),
		"timestamp": OS.get_unix_time()
	}

# returns true if the player is authenticated, otherwise false
func authenticate_player(token, peer_id):
	if not token_player_pairs.has(token): return false
	
	var username = token_player_pairs[token]["username"]
	
	log_out(username)
	
	peer_player_pairs[peer_id] = username
	#token_player_pairs.erase(token)
	
	return true
	
func log_out(username):
	username = username.to_lower()
	if not peer_player_pairs.values().has(username): return

	for peer_id in peer_player_pairs.keys():
		if peer_player_pairs[peer_id] == username: remove_peer(peer_id)
