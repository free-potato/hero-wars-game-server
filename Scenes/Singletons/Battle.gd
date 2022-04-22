extends Node
# TODO: save battles locally once completed

# battle_id: {player_1: {}, player_2: {}, rounds{}}
var battles = {}
var all_attack_methods = ["head", "body", "legs", "d_head", "d_body", "d_legs"]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func create_battle(username_1, username_2):
	var battle_id = self.generate_battle_id()
	var battle = {}
	var player_1 = PlayerClass.new(username_1)
	var player_2 = PlayerClass.new(username_2)
	battle["player_1"] = player_1.character()
	battle["player_1"]["username"] = player_1.username()
	battle["player_1"]["display_name"] = player_1.display_name()
	battle["player_1"]["id"] = player_1.id()
	battle["player_2"] = player_2.character()
	battle["player_2"]["username"] = player_2.username()
	battle["player_2"]["display_name"] = player_2.display_name()
	battle["player_2"]["id"] = player_2.id()
	battle["rounds"] = {}
	battle["is_finished"] = false
	battles[battle_id] = battle
	return battle_id
	
func find(battle_id):
	if not battles.has(battle_id): return null
	return battles[battle_id]
	
func generate_battle_id():
	var battle_id = str(randi()).sha256_text()
	if battles.has(battle_id): battle_id = self.generate_battle_id()
	return battle_id

# TODO: refactor
func proccess_round(battle_id, method, username):
	var player = PlayerClass.new(username)
	var battle = self.battles[battle_id]
	if not all_attack_methods.has(method): method = all_attack_methods.front()
	
	if battle["rounds"].size() < 1 || battle["rounds"][battle["rounds"].size()]["is_finished"]:
		battle["rounds"][battle["rounds"].size() + 1] = {"is_finished": false}
	
	var battle_round = battle["rounds"].size()
	if battle["player_1"]["id"] == player.id():
		battle["rounds"][battle_round]["player_1"] = {"attack_method": method}
	elif battle["player_2"]["id"] == player.id():
		battle["rounds"][battle_round]["player_2"] = {"attack_method": method}
	else:
		return
	
	if battle["rounds"][battle_round].has_all(["player_1", "player_2"]):
		battle = self.finish_round(battle)
		battle["rounds"][battle_round]["is_finished"] = true
		self.return_round_results(battle)
	
	self.battles[battle_id] = battle

func finish_round(battle):
	battle = self.perform_attack(battle, "player_1", "player_2")
	battle = self.perform_attack(battle, "player_2", "player_1")
	
	var player_hp_1 = battle["player_1"]["hp"]
	var player_hp_2 = battle["player_2"]["hp"]
	
	if player_hp_1 < 1 || player_hp_2 < 1:
		battle["is_finished"] = true
		var winner_no = "player_1" if player_hp_1 > player_hp_2 else "player_2"
		var looser_no = "player_2" if winner_no == "player_1" else "player_1"
		battle["winner"] = winner_no
		if player_hp_1 == player_hp_2:
			battle["winner"] = "draw"
		else:
			var winner = Player.find_by_id(battle[battle["winner"]]["id"])
			var looser = Player.find_by_id(battle[looser_no]["id"])
			winner.battle_won()
			looser.battle_lost()
			
	return battle

# TODO: refactor
func perform_attack(battle, attacker, defender):
	var battle_round = battle["rounds"].size()
	var attacker_a_method = battle["rounds"][battle_round][attacker]["attack_method"]
	var defender_a_method = battle["rounds"][battle_round][defender]["attack_method"]
	var damage_dealt = 0
	var hp_reg       = int(battle[attacker]["hp_reg"])
	var mp_reg       = int(battle[attacker]["mp_reg"])
	
	if attacker_a_method == "head" && !["legs", "d_head"].has(defender_a_method):
		damage_dealt = int(battle[attacker]["attack"]) * 2
	elif attacker_a_method == "body" && defender_a_method != "d_body":
		damage_dealt = int(battle[attacker]["attack"])
		if defender_a_method == "legs": damage_dealt = damage_dealt * 2
	elif attacker_a_method == "legs" && defender_a_method != "d_legs":
		damage_dealt = int(battle[attacker]["attack"]) / 2
	elif attacker_a_method == ("d_" + defender_a_method):
		hp_reg = hp_reg * 2
	elif attacker_a_method.find("d_") == 0 && defender_a_method.find("d_") == 0:
		hp_reg = hp_reg * 2
	
	damage_dealt = damage_dealt - int(battle[defender]["defence"])
	if damage_dealt < 0: damage_dealt = 0
	
	battle["rounds"][battle_round][attacker]["damage_dealt"] = int(damage_dealt)
	battle["rounds"][battle_round][attacker]["hp_reg"] = hp_reg
	battle["rounds"][battle_round][attacker]["mp_reg"] = mp_reg
	
	battle[attacker]["hp"] = int(battle[attacker]["hp"]) + hp_reg
	battle[attacker]["mp"] = int(battle[attacker]["mp"]) + mp_reg
	
	battle[defender]["hp"] = int(battle[defender]["hp"]) - damage_dealt
	
	return battle
	

# TODO: add timeout
remote func remote_attack_details(attack_details):
	var peer_id   = get_tree().get_rpc_sender_id()
	var username  = AuthController.username(peer_id)
	var battle_id = attack_details["battle_id"]
	if username == null || !self.battles.has(battle_id): return
	self.proccess_round(attack_details["battle_id"], attack_details["method"], username)
	
func return_round_results(battle):
	var player_1 = Player.find_by_id(battle["player_1"]["id"])
	var player_2 = Player.find_by_id(battle["player_2"]["id"])
	battle["player_1"].erase("username")
	battle["player_2"].erase("username")
	for player in [player_1, player_2]:
		if player == null: continue
		var peer_id = player.peer_id()
		if not Array(get_tree().get_network_connected_peers()).has(peer_id): continue
		rpc_id(peer_id, "remote_update_battle_info", battle)
