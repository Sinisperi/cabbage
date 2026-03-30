class_name ItemSpawner extends Node
const ITEM_DROP = preload("uid://diqi0pyya3sb6")
@export var editor_spawned_items: Node3D
## late join v
## simultanious join v
## client rejoin v

## client spawn host far away
## host spawn client far away 
## host load client far away v
## client load host far away v

func _ready() -> void:
	Globals.item_spawner = self
	EventBus.inventory.item_drop_requested.connect(_on_item_drop_requested)
	EventBus.world.player_spawned_item_pickup_requested.connect(_on_player_spawned_item_pickup_requested)
	EventBus.world.editor_spawned_item_despawn_requested.connect(_on_editor_spawned_item_despawn_requested)

## client requests spawn -> host spawns locally, generates uuid, sends uuid back to client -> client spawns locally with that id as the name

## when client loads a chunk with stuff


func unload_player_spawned_items(items: Array) -> void:
	for item_id: String in items:
		remove_item(item_id)

func load_player_spawned_items(items: Dictionary) -> void:
	for item_id: String in items:
		var item_data: Dictionary = items[item_id]
		item_data.registered_in_chunk = true
		var item: ItemDrop = _create_item(item_data)
		add_child(item, true)


func update_editor_spawned_items(removed_editor_entities: Array) -> void:
	for i: String in removed_editor_entities:
		if editor_spawned_items.has_node("./" + i):
			var item: Node = editor_spawned_items.get_node("./" + i)
			editor_spawned_items.remove_child(item)



func _on_item_drop_requested(item: ItemDrop) -> void:
	_send_item_drop_request.rpc_id(1, item.generate_entity_data())


@rpc("any_peer", "call_local")
func _send_item_drop_request(item_data: Dictionary) -> void:
	var item: ItemDrop = _create_item(item_data)
	add_child(item, true)
	var new_item_data: Dictionary = item.generate_entity_data()
	new_item_data["registered_in_chunk"] = true
	var peers: Array = Globals.chunker.get_peers_in_chunk_by_pos(item.global_position)
	for peer: int in peers:
		if peer <= 1: continue
		_sync_item_spawn.rpc_id(peer, new_item_data)
	await item.update_visuals()
	
	
@rpc("any_peer", "call_remote")
func _sync_item_spawn(item_data: Variant) -> void:
	var item: ItemDrop = _create_item(item_data)
	add_child(item, true)
	await item.update_visuals()
		


func _on_player_spawned_item_pickup_requested(item_id: String, peers: Array) -> void:
	for peer: int in peers:
		remove_item.rpc_id(peer, item_id)
	remove_item.rpc_id(1, item_id)

func _on_editor_spawned_item_despawn_requested(item_id: String, peers: Array) -> void:
	for peer: int in peers:
		remove_editor_spawned_item.rpc_id(peer, item_id)
	remove_editor_spawned_item.rpc_id(1, item_id)

@rpc("any_peer", "call_local")
func remove_editor_spawned_item(item_id: String) -> void:
	var item_to_remove: ItemDrop = editor_spawned_items.get_node_or_null("./" + item_id)
	if item_to_remove:
		item_to_remove.queue_free()
		
@rpc("any_peer", "call_local")
func remove_item(item_id: String) -> void:
	var item_to_remove: ItemDrop = get_node_or_null("./" + item_id)
	if item_to_remove:
		item_to_remove.queue_free()
	


func _on_item_spawned(item: Node) -> void:
	item.update_visuals()
	


func _create_item(data: Dictionary) -> Node:

	var item: ItemDrop = ITEM_DROP.instantiate()
	######################################################
	item.data = ItemDb.get_item_by_id(data.item_data.uid)
	
	######################################################
	item.position = Vector3(data.position.x, data.position.y, data.position.z)
	item.rotation = Vector3(data.rotation.x, data.rotation.y, data.rotation.z)
	if data.registered_in_chunk:
		item.is_registered_in_chunk = true
		item.name = data.entity_id
	else:
		item.name = UUID.gen()
	return item
