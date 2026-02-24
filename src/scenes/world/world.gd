class_name World extends Node3D

@export var player_spawner: MultiplayerSpawner
@export var player_spawn_area: SpawnArea

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

@rpc("any_peer", "call_local")
func _request_player_spawn(username: String = "NO USERNAME") -> void:
	if multiplayer.is_server():
		var peer_id: int = multiplayer.get_remote_sender_id()
		
		PlayerManager.add_player(peer_id, username)
		Globals.inventory.inventory_grid.place_items_request.rpc(Inventory.InventoryType.ITEM)
		Globals.inventory.hot_bar_slots.place_items_request.rpc(Inventory.InventoryType.HOT_BAR)
		Globals.inventory.equipment_slots.init_equipment_request.rpc()
		
		var data: Dictionary = {
			"peer_id": peer_id,
			"location": player_spawn_area.get_spawn_point(),
			"username": username
		}
		
		player_spawner.spawn(data)
		
		prints("spawning player", username, peer_id)
		
