class_name World extends Node3D



#@onready var player_spawner: MultiplayerSpawner = %PlayerSpawner


## 2 chunks render distance -> 1 we are currently in + 2 on each side and dioganally
## every time we discover new chunk we will generate its data, load it because we just entered it
## and then when we unload it, we save it into a file

## NOTE this is for debug purposes to simulate loading chunk data from filesystem



func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Globals.world = self
	SteamManager.peer_disconnected.connect(_on_peer_disconnected)

func _on_peer_disconnected(peer_id: int) -> void:
	if multiplayer.is_server():
		var player_to_remove: Player = PlayerManager.remove_player_peer(peer_id)
		player_to_remove.queue_free()


@rpc("any_peer", "call_local")
func _request_player_spawn(display_name: String = "") -> void:
	if multiplayer.is_server():
		var peer_id: int = multiplayer.get_remote_sender_id()
		var steam_username: String = SteamManager.get_peer_steam_username(peer_id)
		PlayerManager.register_player(peer_id, steam_username)
		
		
		
		var save_data: Dictionary = PlayerManager.load_player_data(peer_id)
		
		
		PlayerManager.set_player_data_for_peer(peer_id, save_data.get("player_data", {}), display_name)
		Globals.inventory.inventory_grid.place_items_request.rpc(peer_id, Inventory.InventoryType.ITEM)
		Globals.inventory.hot_bar_slots.place_items_request.rpc(peer_id, Inventory.InventoryType.HOT_BAR)
		Globals.inventory.equipment_slots.init_equipment_request.rpc(peer_id)
		var data: Dictionary = {
			"peer_id": peer_id,
			#"display_name": display_name,
			"save_data": save_data
		}
		
		Globals.player_spawner.spawn(data)
		
		prints("spawning player", display_name, " aka ", steam_username, " ", peer_id)



				
