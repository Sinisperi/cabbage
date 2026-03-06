extends MultiplayerSpawner
@export var player_scene: PackedScene
@onready var spawn_area: SpawnArea = %SpawnArea


func _ready() -> void:
	spawn_function = _spawn_function 

func _spawn_function(data: Dictionary) -> Node:
	var player: Player = player_scene.instantiate()
	player.name = str(data.peer_id)
	#PlayerManager.add_player(data.peer_id, data.username)
	#Globals.inventory.inventory_grid.place_items_request.rpc(data.peer_id, Inventory.InventoryType.ITEM)
	#Globals.inventory.hot_bar_slots.place_items_request.rpc(data.peer_id, Inventory.InventoryType.HOT_BAR)
	#Globals.inventory.equipment_slots.init_equipment_request.rpc(data.peer_id)
	PlayerManager.set_player_pointer_for_peer(data.peer_id, player)
	if data.save_data.is_empty():
		var spawn_point: Vector2 = spawn_area.get_spawn_point()
		player.position = Vector3(spawn_point.x, player.position.y, spawn_point.y)
	else:
		player.position = Vector3(data.save_data.position.x, data.save_data.position.y, data.save_data.position.z)
	return player
