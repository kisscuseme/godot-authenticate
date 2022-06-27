extends Node

var PlayerIDs: Dictionary
var hub_server

func _ready():
	var player_data_file = File.new()
	var err = player_data_file.open("res://Data/PlayerIds.json", File.READ)
	var player_data_json = JSON.parse(player_data_file.get_as_text())
	player_data_file.close()
	PlayerIDs = player_data_json.result

func SavePlayerIds():
	var save_file = File.new()
	save_file.open("res://Data/PlayerIds.json", File.WRITE)
	save_file.store_line(to_json(PlayerIDs))
	save_file.close()
