class_name World extends Node3D
@export var player_scene: PackedScene
@onready var player_spawner: NetworkSpawner = %PlayerSpawner

#@onready var player_spawner: MultiplayerSpawner = %PlayerSpawner

## 2 chunks render distance -> 1 we are currently in + 2 on each side and dioganally
## every time we discover new chunk we will generate its data, load it because we just entered it
## and then when we unload it, we save it into a file

## NOTE this is for debug purposes to simulate loading chunk data from filesystem


func _ready() -> void:
	#ItemDb.init()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Globals.world = self
	#NetworkManager.peer_disconnected.connect(_on_peer_disconnected)

	# Currently there is a possibility that while player's data is saving, someone else is editing the chunk
	# for this to happen it has to happen at the same time with difference of the time it would take to save a json file





@rpc("any_peer", "call_local")
func _request_player_spawn(_display_name: String = "") -> void:
	if multiplayer.is_server():
		await player_spawner.request_spawn(multiplayer.get_remote_sender_id())
		#var peer_id: int = multiplayer.get_remote_sender_id()
		#var steam_id: int = NetworkManager.get_player_id(peer_id)
		#PlayerManager.register_player(peer_id, steam_id)
#
		#var save_data: Dictionary = PlayerManager.load_player_data(peer_id)
#
		#PlayerManager.set_player_data_for_peer(
			#peer_id, save_data.get("player_data", {}), display_name
		#)
		#Globals.inventory.inventory_grid.place_items_request.rpc(
			#peer_id, Inventory.InventoryType.ITEM
		#)
		#Globals.inventory.hot_bar_slots.place_items_request.rpc(
			#peer_id, Inventory.InventoryType.HOT_BAR
		#)
		#Globals.inventory.equipment_slots.init_equipment_request.rpc(peer_id)
#
		#var data: Dictionary = {"peer_id": peer_id, "save_data": save_data, "active_players": multiplayer.get_peers()}
#
		##Globals.player_spawner.spawn(data)
		#_spawn_player.rpc(data)
		#prints("spawning player", display_name, " aka ", " ", peer_id)


@rpc("authority", "call_local")
func _spawn_player(data: Dictionary) -> void:
	var player: Player = player_scene.instantiate()
	player.name = str(data.peer_id if data.peer_id > 0 else 1)
	if multiplayer.is_server():
		PlayerManager.set_player_pointer_for_peer(data.peer_id, player)
	if data.save_data.is_empty():
		var spawn_point: Vector2 = Vector2(0.0, 0.0)
		player.position = Vector3(spawn_point.x, player.position.y, spawn_point.y)
	else:
		player.position = Vector3(data.save_data.position.x, data.save_data.position.y, data.save_data.position.z)
	if !multiplayer.is_server():
		if data.peer_id == multiplayer.get_unique_id():
			var host: Player = player_scene.instantiate()
			host.set_multiplayer_authority(1)
			add_child(host, true)
			print(data.peer_id, " peer id when spawning host")
	#if multiplayer.is_server():
		#PlayerManager.save_player_data(data.peer_id)
	add_child(player, true)
	player.set_multiplayer_authority(data.peer_id)
	player.multiplayer_synchronizer.set_visibility_for(1, true)
	if multiplayer.is_server():
		var host: Player = PlayerManager.get_player_pointer(1)
		host.multiplayer_synchronizer.set_visibility_for(data.peer_id, true)
		print("REMOTE SENDER ", data.peer_id)
