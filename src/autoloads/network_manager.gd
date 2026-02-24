extends Node

signal peer_connected(peer_id: int)


var peer: MultiplayerPeer = null
var port: int = 3000
var ip: String = "127.0.0.1"


func enable_multiplayer(is_nat: bool = true) -> void:
	if is_nat:
		peer = ENetMultiplayerPeer.new()
	multiplayer.peer_connected.connect(_on_peer_connected)


func _on_peer_connected(peer_id: int) -> void:
	peer_connected.emit(peer_id)
	print("peer connected ", peer_id)


func host_game() -> Error:
	var status: Error = OK
	if peer is ENetMultiplayerPeer:
		status = peer.create_server(port, 2)
		if status != OK:
			return status
		multiplayer.set_multiplayer_peer(peer)
	return status


func join_game(_lobby_id: int = 0) -> Error:
	var status: Error = OK
	if peer is ENetMultiplayerPeer:
		status = peer.create_client(ip, port)
		if status != OK:
			return status
		multiplayer.set_multiplayer_peer(peer)
	return status
