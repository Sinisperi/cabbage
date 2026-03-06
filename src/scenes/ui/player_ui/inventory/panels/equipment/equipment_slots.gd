class_name EquipmentSlots extends PanelContainer




@onready var equipment_grid: GridContainer = %EquipmentGrid


func _ready() -> void:
	EventBus.inventory.equipment.item_equipped.connect(
		func(item_data: EquipableItemData, index: int) -> void: _on_item_equipped.rpc_id(1, item_data.to_dict(), index))
	EventBus.inventory.equipment.item_unequipped.connect(
		func(item_data: EquipableItemData, index: int) -> void: _on_item_unequipped.rpc_id(1, item_data.to_dict(), index))


@rpc("any_peer", "call_local")
func _on_item_equipped(item_data: Variant, index: int) -> void:
	if multiplayer.is_server():
		var peer_id: int = multiplayer.get_remote_sender_id()
		var inv: Array = PlayerManager.get_player_data(peer_id).inventory.equipment_items
		var new_item_data: EquipableItemData = ItemDb.get_item(item_data.uid)
		inv[index] = new_item_data
		if peer_id > 1:
			_set_equipment_slot_display.rpc_id(peer_id, item_data, index)
		else:
			equipment_grid.get_child(index).set_item(new_item_data)
		
		## TODO Apply effects here
		print_rich("[color=yellow]Itrem equippped [/color]", item_data)

@rpc("authority", "call_remote")
func _set_equipment_slot_display(item_data: Variant, index: int) -> void:
	equipment_grid.get_child(index).set_item(ItemDb.get_item(item_data.uid))


@rpc("any_peer", "call_local")
func _on_item_unequipped(item_data: Variant, index: int) -> void:
	if multiplayer.is_server():
		var peer_id: int = multiplayer.get_remote_sender_id()
		var inv: Array = PlayerManager.get_player_data(peer_id).inventory.equipment_items
		inv[index] = null
		
		
		## TODO Unapply effects here
		print("item unequipped", item_data)


@rpc("any_peer", "call_local")
func init_equipment_request(peer_id: int) -> void:
	if multiplayer.is_server():
		var equipment_items: Array = PlayerManager.get_player_data(peer_id).inventory.equipment_items_to_obj()
		if peer_id <= 1:
			_init_equipment(equipment_items)
		else:
			print(peer_id, "this is called asdfasdf;lkjasd;flkjasdf;lkj")
			_init_equipment.rpc_id(peer_id, equipment_items)

		
@rpc("authority", "call_remote")
func _init_equipment(equipment: Array) -> void:
	print("equipment ", equipment)

	for i in equipment.size():
		equipment_grid.get_child(i).slot_index = i
		equipment_grid.get_child(i).set_item(ItemDb.get_item(equipment[i].uid) if equipment[i] else null)
