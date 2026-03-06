class_name World extends Node3D



@onready var player_spawner: MultiplayerSpawner = %PlayerSpawner


## 2 chunks render distance -> 1 we are currently in + 2 on each side and dioganally
## every time we discover new chunk we will generate its data, load it because we just entered it
## and then when we unload it, we save it into a file

## NOTE this is for debug purposes to simulate loading chunk data from filesystem




func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Globals.world = self


@rpc("any_peer", "call_local")
func _request_player_spawn(username: String = "NO USERNAME") -> void:
	if multiplayer.is_server():
		var peer_id: int = multiplayer.get_remote_sender_id()
		PlayerManager.register_player(peer_id, username)
		var save_data: Dictionary = PlayerManager.load_player_data(peer_id)
		PlayerManager.set_player_data_for_peer(peer_id, save_data.player_data)
		#PlayerManager.add_player(peer_id, username)
		Globals.inventory.inventory_grid.place_items_request.rpc(peer_id, Inventory.InventoryType.ITEM)
		Globals.inventory.hot_bar_slots.place_items_request.rpc(peer_id, Inventory.InventoryType.HOT_BAR)
		Globals.inventory.equipment_slots.init_equipment_request.rpc(peer_id)
		var data: Dictionary = {
			"peer_id": peer_id,
			"username": username,
			"save_data": save_data
		}
		
		player_spawner.spawn(data)
		
		prints("spawning player", username, peer_id)



				
