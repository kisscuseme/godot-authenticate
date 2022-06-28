extends Node

var PlayerIDs: Dictionary
var hub_server

func _ready():
	PlayerIDs = GlobalData.LoadDataFromJSON("PlayerIds")


func SaveDataToJSON(path, json_data):
	var save_file = File.new()
	save_file.open("res://Data/" + path + ".json", File.WRITE)
	save_file.store_line(json_data)
	save_file.close()	


func SavePlayerIds():
	SaveDataToJSON("PlayerIds", to_json(PlayerIDs))
