class_name ItemSpawner extends Node
const ITEM_DROP = preload("uid://diqi0pyya3sb6")



func _ready() -> void:
	EventBus.world.item_spawn_requested.connect(_on_item_spawn_requested)
	EventBus.inventory.item_drop_requested.connect(_on_item_drop_requested)
	EventBus.world.item_sync_requested.connect(_on_item_sync_requested)
	EventBus.world.player_spawned_item_despawn_requested.connect(
		func (item_id: String) -> void: _on_player_spawned_item_despawn_requested.rpc(item_id))


## client requests spawn -> host spawns locally, generates uuid, sends uuid back to client -> client spawns locally with that id as the name

## when client loads a chunk with stuff

func _on_item_sync_requested(entities: Dictionary, old_entities: Dictionary) -> void:
	var entities_to_remove: Array = []
	for i: String in old_entities.keys():
		if !entities.has(i):
			entities_to_remove.push_back(old_entities[i].entity_id)
			old_entities.erase(i)
	
	for i: String in entities.keys():
		if !old_entities.has(i):
			entities[i]["registered_in_chunk"] = true
			var item: ItemDrop = _create_item(entities[i])
			add_child(item, true)
	
	for i: String in entities_to_remove:
		var item_to_remove: ItemDrop = get_node_or_null("./" + i)
		if item_to_remove:
			item_to_remove.queue_free()
			
	prints("ITEM SYNC REQUESTED", entities, "\n", old_entities, multiplayer.get_unique_id())



func _on_item_drop_requested(item: ItemDrop) -> void:
	_send_item_drop_request.rpc_id(1, item.generate_entity_data())


func _on_item_spawn_requested(item_data: Variant) -> void:
	#_send_item_spawn_request.rpc_id(1, item_data)
	await _send_item_spawn_request(item_data)


@rpc("any_peer", "call_local")
func _send_item_spawn_request(item_data: Dictionary) -> void:
	print("SPAWN REQUESST")
	#item_data["registered_in_chunk"] = true
	var item: ItemDrop = _create_item(item_data)
	#item.name = item.name
	add_child(item, true)
	#_sync_item_spawn.rpc(item_data)
	await item.update_visuals()

@rpc("any_peer", "call_local")
func _send_item_drop_request(item_data: Dictionary) -> void:
	print("DROP REQUESST ", item_data)
	var item: ItemDrop = _create_item(item_data)
	print("AFTER INSTANTIATING")
	#item.is_registered_in_chunk = true
	add_child(item, true)
	var new_item_data: Dictionary = item.generate_entity_data()
	new_item_data["registered_in_chunk"] = true
	_sync_item_spawn.rpc(new_item_data)
	await item.update_visuals()
	
	
@rpc("any_peer", "call_remote")
func _sync_item_spawn(item_data: Variant) -> void:
	print("CALLING REMOTE")
	var item: ItemDrop = _create_item(item_data)
	add_child(item, true)
	await item.update_visuals()
		


@rpc("any_peer", "call_local")
func _on_player_spawned_item_despawn_requested(item_id: String) -> void:
	var item_to_remove: ItemDrop = get_node_or_null("./" + item_id)
	if item_to_remove:
		item_to_remove.queue_free()
	



func _on_item_spawned(item: Node) -> void:
	item.update_visuals()
	


func _create_item(data: Dictionary) -> Node:

	var item: ItemDrop = ITEM_DROP.instantiate()
	######################################################
	item.data = ItemDb.get_item_by_id(data.item_data.uid)
	print(item.data, " item data here ,world dict id is ", data.item_data.uid)
	
	######################################################
	item.position = Vector3(data.position.x, data.position.y, data.position.z)
	item.rotation = Vector3(data.rotation.x, data.rotation.y, data.rotation.z)
	#item.name = data.name
	if data.registered_in_chunk:
		item.is_registered_in_chunk = true
		item.name = data.entity_id
	else:
		prints("DID I DROP?", multiplayer.get_unique_id())
		item.name = UUID.gen()
	return item
