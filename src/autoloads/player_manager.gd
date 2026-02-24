extends Node

# { username: player_data }
var active_players: Dictionary[String, PlayerData] = {}
# { peer_id: username }
var active_peers: Dictionary[int, String] = {}


## TODO Load player save data in here

func add_player(peer_id: int, username: String) -> void:
	print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
	if !active_peers.has(peer_id):
		var new_player_data: PlayerData = PlayerData.new()
		new_player_data.username = username
		active_peers[peer_id] = username
		active_players[username] = new_player_data
		print("added new player ", peer_id, username)
		return
	#print("gholy funckoing shit whyyyyy ", peer_id)

func get_player_data(peer_id: int) -> PlayerData:
	if active_peers.has(peer_id):
		if active_players.has(active_peers[peer_id]):
			return active_players[active_peers[peer_id]]
	return null
