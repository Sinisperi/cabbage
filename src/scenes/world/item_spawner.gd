extends MultiplayerSpawner

@onready var gatherable_items: Node3D = %GatherableItems
@onready var editor_spawned_items: Node3D = %EditorSpawnedItems
const ITEM_DROP = preload("uid://diqi0pyya3sb6")



func _ready() -> void:
	
	EventBus.inventory.item_drop_requested.connect(func (item: Node) -> void: _on_item_dropped.rpc_id(1, item.data.to_dict()))
	
		
	## Goes through editor_spawned_items and replicates all the children it has
	## into gatherable_items node that is being watched by ItemSpawner
	## We are doing it so ItemSpawner realizes that it has to replicate items on the client
	## and to make it so when host or some client picks up item and later another client joins, they will
	## not see picked up item on the ground
	
	spawned.connect(_on_item_spawned)
	spawn_function = _spawn_function
	#await _init_editor_placed_items()


func _init_editor_placed_items() -> void:
	if multiplayer.is_server():
		await get_tree().process_frame
		while editor_spawned_items.get_child_count():
			var c: Node = editor_spawned_items.get_child(-1)
			
			
			var data: Dictionary = {
				"data": c.data.to_dict(),
				"position": c.position,
				"basis": c.basis,
				"is_editor_placed": true
			}
			
			spawn(data)
			editor_spawned_items.remove_child(c)
			c.queue_free()
			
		
	editor_spawned_items.queue_free()
	
@rpc("any_peer", "call_local")
func _on_item_dropped(item: Variant) -> void:	

	if multiplayer.is_server():
		var player_forward: Vector3 = -Globals.player.basis.z
		var data: Dictionary = {
			"data": item,
			"position": Globals.player.global_position + (Vector3.UP * 2.0) + (1.5 * player_forward),
		}
		spawn(data)

#func generate_unique_name(node: Node) -> String:
	#return str(node.get_instance_id())+ str(gatherable_items.get_child_count())


func _on_item_spawned(item: Node) -> void:
	item.update_visuals()


func _spawn_function(data: Dictionary) -> Node:
	var item: ItemDrop = ITEM_DROP.instantiate()
	item.data = ItemDb.get_item(data.data.uid)
	item.position = data.position
	if data.has("basis"):
		item.basis = data.basis
	item.name = str(Time.get_unix_time_from_system())
	if !data.has("is_editor_placed"):
		var chunk: Chunk = Globals.chunker.get_chunk_from_pos(item.position)
		chunk.chunk_data.entities.append(item.generate_entity_data())
	return item
