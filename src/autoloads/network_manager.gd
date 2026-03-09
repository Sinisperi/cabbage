extends Node

signal peer_connected(peer_id: int)

var peer: MultiplayerPeer = null
var port: int = 3000
var ip: String = "127.0.0.1"



func enable_local_host() -> void:
	peer = ENetMultiplayerPeer.new()
	multiplayer.peer_connected.connect(_on_peer_connected)

func _on_peer_connected(peer_id: int) -> void:
	peer_connected.emit(peer_id)


func join_game(_lobby_id: int = 0) -> Error:
	var status: Error = OK
	if peer is ENetMultiplayerPeer:
		status = peer.create_client(ip, port)
		if status != OK:
			return status
		multiplayer.set_multiplayer_peer(peer)
	return status



func create_local_server() -> Error:
	var status: Error = OK
	status = peer.create_server(port, 2)
	multiplayer.set_multiplayer_peer(peer)
	return status
