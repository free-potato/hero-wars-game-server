extends Node

const SERVER_PORT = 1909
const MAX_PLAYERS = 1000

var network = NetworkedMultiplayerENet.new()
var waiting_list = {} # {peer_id: {timestamp: 1234}}

# Called when the node enters the scene tree for the first time.
func _ready():
	start_server()

func start_server():
	network.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = network
	
	print("Server started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")
	

func _peer_connected(peer_id):
	print("peer connected: " + str(peer_id))
	waiting_list[peer_id] = {"timestamp": OS.get_unix_time()}

func _peer_disconnected(peer_id):
	print("peed disconnected: " + str(peer_id))
	waiting_list.erase(peer_id)
	AuthController.remove_peer(peer_id)

remote func remote_authenticate_player(token):
	var peer_id      = get_tree().get_rpc_sender_id()
	var request_time = OS.get_unix_time()
	var result       = false
	
	# 6 second timeout
	while (OS.get_unix_time() - request_time) <= 6:
		result = AuthController.authenticate_player(token, peer_id)
		if result == true: break
		yield(get_tree().create_timer(2), "timeout")
		
	waiting_list.erase(peer_id)
	if not Array(get_tree().get_network_connected_peers()).has(peer_id): return
	
	return_authentication_result(peer_id, result)
	
	if result == false:
		network.disconnect_peer(peer_id)
	
func return_authentication_result(peer_id, result):
	rpc_id(peer_id, "remote_authentication_result", result)
