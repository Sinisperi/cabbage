extends Node

signal peer_connected(peer_id: int, player_id: int)
signal peer_disconnected(peer_id: int, player_id: int)
signal host_disconnected
signal connection_type_changed(connection_type: ConnectionType)

var peer: MultiplayerPeer = null
var port: int = 3000


var broadcast_port: int = 7000
var broadcast_interval: float = 0.3
var since_last_broadcast: float = INF
var is_broadcasting: bool = false
var broadcast_peer: PacketPeerUDP



var ip: String = "127.0.0.1"

enum ConnectionType
{
	NONE,
	LOCAL_HOST,
	LOCAL_CLIENT,
	MULTIPLAYER_HOST,
	MULTIPLAYER_CLIENT
}

enum LobbyType
{
	FRIENDS_ONLY = Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY,
	PRIVATE = Steam.LobbyType.LOBBY_TYPE_PRIVATE
}

var current_connection_type: ConnectionType = ConnectionType.NONE


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _enable_local_host() -> void:
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer.close()
	peer = ENetMultiplayerPeer.new()
	peer.create_server(_find_available_port(), 1)
	multiplayer.multiplayer_peer = peer
	

func _create_local_client() -> void:
	if multiplayer.has_multiplayer_peer():
		print("peer has connections ")
		multiplayer.multiplayer_peer.close()
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	port += 1

func _reset_peer() -> void:
	if multiplayer.has_multiplayer_peer():
		multiplayer.multiplayer_peer.close()
	peer = null
	multiplayer.multiplayer_peer = peer
	

func enable_multiplayer() -> Dictionary:
	return SteamManager.enable_steam()


func _on_peer_connected(peer_id: int) -> void:
	peer_connected.emit(peer_id, get_player_id(peer_id))


func _on_peer_disconnected(peer_id: int) -> void:
	peer_disconnected.emit(peer_id, get_player_id(peer_id))


func _on_server_disconnected() -> void:
	await switch_connection_type(ConnectionType.LOCAL_HOST)
	host_disconnected.emit()


func get_player_id(peer_id: int) -> int:
	if peer_id > 1:
		if peer is SteamMultiplayerPeer:
			return SteamManager.get_peer_steam_id(peer_id)
		else:
			return 69
	else:
		return 0
		
		

func switch_connection_type(connection_type: ConnectionType) -> void:
	if connection_type == current_connection_type: return
	SteamManager.leave_lobby()
	_reset_peer()
	_stop_broadcast()
	await get_tree().process_frame
	match connection_type:
		ConnectionType.LOCAL_HOST:
			_enable_local_host()
		ConnectionType.LOCAL_CLIENT:
			_create_local_client()
		ConnectionType.MULTIPLAYER_HOST:
			enable_multiplayer()
			SteamManager.create_host()
		ConnectionType.MULTIPLAYER_CLIENT:
			enable_multiplayer()
			SteamManager.create_client()
	
	current_connection_type = connection_type
	connection_type_changed.emit(current_connection_type)


func start_broadcast() -> void:
	if is_broadcasting: return
	is_broadcasting = true
	broadcast_peer = PacketPeerUDP.new()
	broadcast_peer.set_broadcast_enabled(true)
	broadcast_peer.set_dest_address("255.255.255.255", broadcast_port)
	
	get_tree().process_frame.connect(_send_broadcast_packet)
	

func _send_broadcast_packet() -> void:
	if since_last_broadcast >= broadcast_interval:
		since_last_broadcast = 0.0
		broadcast_peer.put_packet(JSON.stringify(port).to_utf8_buffer())
	since_last_broadcast += 0.01666666666


## NOTE QQQQQQQQQQQQQQ
## HOOK UP THIS BREADCAST STUFF


func _stop_broadcast() -> void:
	if !is_broadcasting: return
	
	get_tree().process_frame.disconnect(_send_broadcast_packet)
	broadcast_peer.close()
	broadcast_peer = null
	is_broadcasting = false


func get_local_servers() -> Array[int]:
	var res: Array[int] = []
	var listener: PacketPeerUDP = PacketPeerUDP.new()
	var err: Error = listener.bind(broadcast_port)
	if !err:
		var end_time: float = Time.get_ticks_msec() + 2.0 * 1000.0
		while Time.get_ticks_msec() < end_time:
			while listener.get_available_packet_count() > 0:
				var bytes: PackedByteArray = listener.get_packet()
				var data: Variant = JSON.parse_string(bytes.get_string_from_utf8())
				if !res.has(data):
					res.push_back(data)
			await get_tree().process_frame
		listener.close()
	return res
	

func _find_available_port() -> int:
	var res: int = port
	for i in range(10):
		var temp_peer: PacketPeerUDP = PacketPeerUDP.new()
		res += i
		var response: Error = temp_peer.bind(res)
		if response == OK:
			temp_peer.close()
			break
	return res
		
