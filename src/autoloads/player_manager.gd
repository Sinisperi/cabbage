extends Node

# { uid: player_data }
var active_players: Dictionary[String, PlayerData] = {}
# { peer_id: uid }
var active_peers: Dictionary[int, String] = {}


func add_player(peer_id: int, player_data: PlayerData) -> void:
	if !active_peers.has(peer_id):
		# TODO in future change username to some sort of uid
		active_peers[peer_id] = player_data.username
		active_players[player_data.username] = player_data
