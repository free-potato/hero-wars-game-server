extends Node

const SERVER_PORT = 1912
const SERVER_IP = "127.0.0.1"

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	connect_to_server()

func _process(delta):
	if get_custom_multiplayer() == null:
		return
	if not custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()
	

func connect_to_server():
	network.create_client(SERVER_IP, SERVER_PORT)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	
	network.connect("connection_succeeded", self, "_on_connection_succeeded")
	network.connect("connection_failed", self, "_on_connection_failed")
	

func _on_connection_succeeded():
	print("Connected to the Game Server Hub")
	
func _on_connection_failed():
	print("Connection to the Game Server Hub has failed")
	
remote func remote_receive_player_auth_details(details):
	AuthController.save_token(details["token"], details["username"])
	if not Player.player_exists(details["username"]): 
		Player.create_player(details["username"])
	
