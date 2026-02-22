class_name SlotsPanel extends PanelContainer


@export var inventory_grid: InventoryGrid

signal item_picked(index: int)
signal item_placed(index: int, item_data: ItemData)

func _ready() -> void:
	inventory_grid.item_picked.connect(func(index: int) -> void: item_picked.emit(index))
	inventory_grid.item_placed.connect(func(index: int, item_data: ItemData) -> void: item_placed.emit(index, item_data))
	pass


func init_grid() -> void:
	inventory_grid.init_grid()

@rpc("any_peer", "call_local")
func place_items_request(inventory_type: Inventory.InventoryType) -> void:
	if multiplayer.is_server():
		var peer_id: int = multiplayer.get_remote_sender_id()
		var player_id: String = PlayerManager.active_peers[peer_id]
		
		var inv: Array = PlayerManager.active_players[player_id].inventory.inventory_items_to_obj()
		if inventory_type == Inventory.InventoryType.HOT_BAR:
			inv = PlayerManager.get_player_data(peer_id).inventory.hot_bar_items_to_obj()
			#print(inv)
		if peer_id <= 1:
			place_items(inv)
		else:
			place_items.rpc_id(peer_id, inv)

@rpc("authority", "call_remote")
func place_items(items_obj: Array) -> void:
	var items: Array = []
	for i: Variant in items_obj:
		if i != null:
			items.append(ItemDb.get_item(i.uid))
		else:
			items.append(i)
	print(items_obj)
			
	inventory_grid.place_items(items)


func get_selected_item() -> ItemData:
	return inventory_grid.get_selected_item()

@rpc("authority", "call_remote")
func add_item(item_data: Variant, index: int) -> void:
	var item = ItemDb.get_item(item_data.uid)
	inventory_grid.place_item(item, index)
