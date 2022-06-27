extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1911
var max_servers = 5

func _ready():
	StartServer()
	
func StartServer():
	network.create_server(port, max_servers)
	get_tree().network_peer = network
	print("Authentication server started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _Peer_Connected(server_id):
	print("Server " + str(server_id) + " Connected")
	
func _Peer_Disconnected(server_id):
	print("Server " + str(server_id) + " Disconnected")

remote func AuthenticatePlayer(username, password, player_id):
	print("authentication request received")
	var gateway_id = get_tree().get_rpc_sender_id()
	var hashed_password
	var token
	var result
	print("Starting authentication")
	if not PlayerData.PlayerIDs.has(username):
		print("User not recognized")
		result = false
	else:
		var retrieved_salt = PlayerData.PlayerIDs[username].Salt
		hashed_password = GenerateHashedPassword(password, retrieved_salt)
		if not PlayerData.PlayerIDs[username].Password == hashed_password:
			print("Incorrect password")
			result = false
		else:
			print("Successful authentication")
			result = true
		
			randomize()
			token = str(randi()).sha256_text() + str(OS.get_unix_time())
			print("token: " + token)
			rpc_id(PlayerData.hub_server, "DistributeLoginToken", token)
		
	print("authentication result send to gateway server")
	rpc_id(gateway_id, "AuthenticationResults", result, player_id, token)

remote func CreateAccount(username, password, player_id):
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	var message
	if PlayerData.PlayerIDs.has(username):
		result = false
		message = 2
	else:
		result = true
		message = 3
		var salt = GenerateSalt()
		var hashed_password = GenerateHashedPassword(password, salt)
		PlayerData.PlayerIDs[username] = {"Password": hashed_password, "Salt": salt}
		PlayerData.SavePlayerIds()
	
	rpc_id(gateway_id, "CreateAccountResults", result, player_id, message)

func GenerateSalt():
	randomize()
	var salt = str(randi()).sha256_text()
	print("Salt: " + salt)
	return salt

func GenerateHashedPassword(password, salt):
	print(str(OS.get_system_time_msecs()))
	var hashed_password = password
	var rounds = pow(2, 18)
	print("hashed password as input: " + hashed_password)
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	print("final hashed password: " + hashed_password)
	print(str(OS.get_system_time_msecs()))
	return hashed_password

remote func RegisterHubServer(server_id):
	PlayerData.hub_server = server_id
