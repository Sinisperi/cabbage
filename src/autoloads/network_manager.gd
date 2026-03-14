extends Node

signal peer_connected(peer_id: int, player_id: int)
signal peer_disconnected(peer_id: int, player_id: int)
signal host_disconnected

var peer: MultiplayerPeer = null
var port: int = 3000
var ip: String = "127.0.0.1"


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func enable_local_host() -> void:
	peer = ENetMultiplayerPeer.new()
	peer.create_server(port, 1)
	multiplayer.set_multiplayer_peer(peer)


func enable_multiplayer() -> Dictionary:
	peer = SteamMultiplayerPeer.new()
	return SteamManager.enable_steam()


func _on_peer_connected(peer_id: int) -> void:
	peer_connected.emit(peer_id, get_player_id(peer_id))


func _on_peer_disconnected(peer_id: int) -> void:
	peer_disconnected.emit(peer_id, get_player_id(peer_id))


func _on_server_disconnected() -> void:
	host_disconnected.emit()


func get_player_id(peer_id: int) -> int:
	if peer_id > 1:
		return SteamManager.get_peer_steam_id(peer_id)
	else:
		return 0
		
		

#func _disconnect_multiplayer_signals() -> void:
	#var signals: Array[Dictionary] = multiplayer.get_signal_list()
	#for i in signals:
		#for connection in multiplayer.get_signal_connection_list(i.name):
			##multiplayer.disconnect(i.name, connection.callable)
			#prints(i.name, connection.callable)



		
		
#func join_game(_lobby_id: int = 0) -> Error:
	#var status: Error = OK
	#if peer is ENetMultiplayerPeer:
		#status = peer.create_client(ip, port)
		#if status != OK:
			#return status
		#multiplayer.set_multiplayer_peer(peer)
	#return status
#
#
#
#func create_local_server() -> Error:
	#var status: Error = OK
	#status = peer.create_server(port, 2)
	#multiplayer.set_multiplayer_peer(peer)
	#return status
