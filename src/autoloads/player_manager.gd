extends Node

# { uid: player_data }
var active_players: Dictionary[String, PlayerData] = {}
# { peer_id: uid }
var active_peers: Dictionary[int, String] = {}


func add_player(peer_id: int, username: String) -> void:
	if !active_peers.has(peer_id):
		# TODO in future change username to some sort of uid
		active_peers[peer_id] = username
		active_players[username] = PlayerData.new()
		print("peer_id", peer_id, "not working maybe")
		return
	print("gholy funckoing shit whyyyyy ", peer_id)

func get_player_data(peer_id: int) -> PlayerData:
	return active_players[active_peers[peer_id]]
