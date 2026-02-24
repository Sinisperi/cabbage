extends MultiplayerSpawner
@export var player_scene: PackedScene


func _ready() -> void:
	spawn_function = _spawn_function 


func _spawn_function(data: Dictionary) -> Node:
	var player: Player = player_scene.instantiate()
	player.position = Vector3(data.location.x, player.position.y, data.location.y)
	player.name = str(data.peer_id)
	PlayerManager.add_player(data.peer_id, data.username)
	
	Globals.inventory.inventory_grid.place_items_request.rpc(Inventory.InventoryType.ITEM)
	Globals.inventory.hot_bar_slots.place_items_request.rpc(Inventory.InventoryType.HOT_BAR)
	Globals.inventory.equipment_slots.init_equipment_request.rpc()
	return player
