extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1912
var max_players = 100

var gameserverlist = {}

func _ready():
	StartServer()

func _process(delta):
	if not self.custom_multiplayer.has_network_peer():
		return;
	self.custom_multiplayer.poll()

func StartServer():
	network.create_server(port, max_players)
	self.custom_multiplayer = gateway_api
	self.custom_multiplayer.root_node = self
	self.custom_multiplayer.network_peer = network
	print("GameServerHub started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")

func _Peer_Connected(gameserver_id):
	print("Game Server " + str(gameserver_id) + " Connected")
	"""
	Name is something to add in the loadbalancer tutorial
	"""
	gameserverlist["GameServer1"] = gameserver_id
	print(gameserverlist)


func _Peer_Disconnected(gameserver_id):
	print("Game Server " + str(gameserver_id) + " Disconnected")


func DistributeLoginToken(token, gameserver):
	var gameserver_peer_id = gameserverlist[gameserver]
	rpc_id(gameserver_peer_id, "ReceiveLoginToken", token)
