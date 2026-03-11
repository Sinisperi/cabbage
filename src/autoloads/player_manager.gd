extends Node


## FRICKING REDOING EVERYTHING FFS
# { username: {ref: Player, player_data: PlayerData} }
var active_players: Dictionary[String, Dictionary] = {}
# { peer_id: username }
var active_peers: Dictionary[int, String] = {}

#var debug_save_dir: String = "res://saves/player_data/"
#var SAVE_DIR: String = debug_save_dir
var SAVE_DIR: String = "player_data/"
## TODO Load player save data in here

func _ready() -> void:
	pass

func register_player(peer_id: int, steam_username: String) -> void:
	if !active_peers.has(peer_id):
		active_peers[peer_id] = steam_username


func set_player_data_for_peer(peer_id: int, player_data: Dictionary, display_name: String) -> void:
	var new_player_data: PlayerData = PlayerData.new(player_data)
	if player_data.is_empty():
		new_player_data.display_name = display_name
	active_players[active_peers[peer_id]] = {
		"player_data": new_player_data,
		"ref": null
	}
	
	
func set_player_pointer_for_peer(peer_id: int, ptr: Player) -> void:
	if !multiplayer.is_server(): return
	if active_peers.has(peer_id):
		active_players[active_peers[peer_id]].ref = ptr
	else:
		printerr("Trying to assign player pointer to a peer ", peer_id, " but it's not in active_players!")

func save_active_players() -> void:
	for i in active_peers:
		save_player_data(i)
		

#func add_player(peer_id: int, username: String) -> void:
	#print("attempting to add new player: ", username)
	#if !active_peers.has(peer_id):
		#active_peers[peer_id] = username
		#var player_save_data: Dictionary = load_player_data(peer_id)
		#if player_save_data.is_empty():
			#var new_player_data: PlayerData = PlayerData.new()
			#new_player_data.username = username
			#active_players[username] = {
				#"player_data": new_player_data,
				#"ref": null
			#}
		#else:
			#active_players[username] = player_save_data
		#print("added new player ", peer_id, username)
		#return
	#print("player ", username, " already exists")

func get_player_data(peer_id: int) -> PlayerData:
	if active_peers.has(peer_id):
		if active_players.has(active_peers[peer_id]):
			return active_players[active_peers[peer_id]].player_data
	return null

## TODO



func load_player_data(peer_id: int) -> Dictionary:
	var file_name: String = SaveDataManager.current_save_path + SAVE_DIR + active_peers[peer_id] + ".json"
	if !FileAccess.file_exists(file_name):
		return {}
	var json: JSON = JSON.new()
	var file: FileAccess = FileAccess.open(file_name, FileAccess.READ)
	json.parse(file.get_line())
	var data: Variant = json.data
	return data

func save_player_data(peer_id: int) -> void:
	var file_name: String = SaveDataManager.current_save_path + SAVE_DIR + active_peers[peer_id] + ".json"
	var player_position: Vector3 = get_player_pointer(peer_id).position
	var data_to_save: Dictionary = {
		"player_data": get_player_data(peer_id).to_obj(),
		"position": {
			"x": player_position.x,
			"y": player_position.y,
			"z": player_position.z
		}
	}
	var data_string: String = JSON.stringify(data_to_save)
	if !DirAccess.dir_exists_absolute(SaveDataManager.current_save_path + SAVE_DIR):
		DirAccess.make_dir_absolute(SaveDataManager.current_save_path + SAVE_DIR)
	var file: FileAccess = FileAccess.open(file_name, FileAccess.WRITE)
	file.store_string(data_string)


func save_and_remove_player(peer_id: int) -> Player:
	save_player_data(peer_id)
	var removed_player: Player = remove_player_peer(peer_id)
	return removed_player

func get_player_pointer(peer_id: int) -> Player:
	if active_peers[peer_id]:
		return active_players[active_peers[peer_id]].ref
	else:
		return null

func remove_player_peer(peer_id: int) -> Player:
	var removed_player: Player = null
	if active_peers[peer_id]:
		removed_player = active_players[active_peers[peer_id]].ref
		active_players.erase(active_peers[peer_id])
		active_peers.erase(peer_id)
	return removed_player
