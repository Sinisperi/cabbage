class_name NetworkSpawner extends Node
@export var player_scene: PackedScene


# this runs on the server

# we recieve a request for player spawn from the client
# we init their data
# spawn player on the host
# send save data back to client together with all peer_ids in the loaded area
# on the client we recieve the data, spawn ourselves, and all peers

func _ready() -> void:
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func request_spawn(peer_id: int) -> void:
	
	var steam_id: int = NetworkManager.get_player_id(peer_id)
	PlayerManager.register_player(peer_id, steam_id)
	
	var save_data: Dictionary = PlayerManager.load_player_data(peer_id)
	_init_player_data(peer_id, save_data, "")
	
	var player: Player = _create_player(peer_id, save_data)
	PlayerManager.set_player_pointer_for_peer(peer_id, player)
	add_child(player, true)
	player.multiplayer_synchronizer.set_visibility_for(1, true)
	if !player.is_node_ready():
		await player.ready
	
	if peer_id > 1:
		_send_spawn_data_to_peer.rpc_id(peer_id, {
			"active_peers": PlayerManager.active_peers.keys(), # later this is going to be peers in loaded chunks of the client
			"save_data": save_data
		})

	_update_active_peers.rpc(peer_id)

	

## Called on the client
@rpc("any_peer", "call_remote")
func _update_active_peers(new_peer_id: int) -> void:
	if has_node("./" + str(new_peer_id)): return
	if Globals.player:
		if new_peer_id != multiplayer.get_unique_id():
			var new_player: Player = _create_player(new_peer_id, {})
			add_child(new_player)
			Globals.player.multiplayer_synchronizer.set_visibility_for(new_peer_id, true)



## Called on the client
@rpc("any_peer", "call_remote")
func _send_spawn_data_to_peer(spawn_data: Dictionary) -> void:
	var player: Player = _create_player(multiplayer.get_unique_id(), spawn_data.save_data)
	add_child(player, true)
	for peer: int in spawn_data.active_peers:
		if peer != multiplayer.get_unique_id():
			var peer_player: Player = _create_player(peer, {})
			add_child(peer_player)
			peer_player.multiplayer_synchronizer.set_visibility_for(peer, true)
			player.multiplayer_synchronizer.set_visibility_for(peer, true)
	_enable_peer_sync_request.rpc_id(1, spawn_data.active_peers)



## Called on the server
@rpc("any_peer", "call_local")
func _enable_peer_sync_request(peers: Array[int]) -> void:
	var sender_peer: int = multiplayer.get_remote_sender_id()
	var sender_player: Player = PlayerManager.get_player_pointer(sender_peer)
	for peer in peers:
		var target_player: Player = PlayerManager.get_player_pointer(peer)
		if target_player && sender_player:
			sender_player.multiplayer_synchronizer.set_visibility_for(peer, true)
			target_player.multiplayer_synchronizer.set_visibility_for(sender_peer, true)


## Called on the server
## TODO ALL OF THESE SHOULD NOT BE RPC FUNCTIONS BECAUSE IN THOSE RPCS WE ONLY DO STUFF IF WE ARE THE SERVER
func _init_player_data(peer_id: int, save_data: Dictionary, display_name: String) -> void:
		PlayerManager.set_player_data_for_peer(
			peer_id, save_data.get("player_data", {}), display_name
		)
		Globals.inventory.inventory_grid.place_items_request.rpc(
			peer_id, Inventory.InventoryType.ITEM
		)
		Globals.inventory.hot_bar_slots.place_items_request.rpc(
			peer_id, Inventory.InventoryType.HOT_BAR
		)
		Globals.inventory.equipment_slots.init_equipment_request.rpc(peer_id)



func _create_player(peer_id: int, save_data: Dictionary) -> Player:
	var player: Player = player_scene.instantiate()
	peer_id = peer_id if peer_id > 0 else 1
	player.name = str(peer_id)
	if save_data.is_empty():
		var spawn_point: Vector2 = Vector2(0.0, 0.0)
		player.position = Vector3(spawn_point.x, player.position.y, spawn_point.y)
	else:
		player.position = Vector3(save_data.position.x, save_data.position.y, save_data.position.z)
	player.set_multiplayer_authority(peer_id)
	return player





func _on_peer_disconnected(peer_id: int) -> void:
	if multiplayer.is_server():
		PlayerManager.save_player_data(peer_id)
		PlayerManager.mark_player_inactive(peer_id)
		_notify_player_disconnect.rpc(peer_id)


@rpc("any_peer", "call_local")
func _notify_player_disconnect(peer_id: int) -> void:
	var player: Player = get_node_or_null("./" + str(peer_id))
	if player:
		player.queue_free()
