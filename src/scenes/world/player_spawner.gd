extends MultiplayerSpawner
@export var player_scene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_function = _spawn_function


func _spawn_function(data: Dictionary) -> Node:
	var player: Player = player_scene.instantiate()
	## Load player data or create based on username???
	
	if PlayerManager.active_players.has(data.username):
		player.player_data = PlayerManager.active_players[data.username]
	else:
		player.player_data = PlayerData.new()
		player.player_data.username = data.username
		PlayerManager.active_players[data.username] = player.player_data
		
	PlayerManager.active_peers[data.peer_id] = data.username
	
	player.position = Vector3(data.location.x, player.position.y, data.location.y)
	player.name = str(data.peer_id)
	
	Globals.inventory.inventory_grid.place_items_request.rpc(Inventory.InventoryType.ITEM)
	Globals.inventory.hot_bar_slots.place_items_request.rpc(Inventory.InventoryType.HOT_BAR)
	#hot_bar_slots.place_items_request.rpc(InventoryType.HOT_BAR)
	return player
