extends MultiplayerSpawner

@onready var gatherable_items: Node3D = %GatherableItems
@onready var editor_spawned_items: Node3D = %EditorSpawnedItems



func _ready() -> void:
	
	EventBus.inventory.item_drop_requested.connect(_on_item_dropped)
	await _init_editor_placed_items()
	
		
	## Goes through editor_spawned_items and replicates all the children it has
	## into gatherable_items node that is being watched by ItemSpawner
	## We are doing it so ItemSpawner realizes that it has to replicate items on the client
	## and to make it so when host or some client picks up item and later another client joins, they will
	## not see picked up item on the ground
	


func _init_editor_placed_items() -> void:
	if multiplayer.is_server():
		await get_tree().process_frame
		while editor_spawned_items.get_child_count():
			var c: Node = editor_spawned_items.get_child(-1)
			var new_item: Node = load(c.scene_file_path).instantiate()
			new_item.data = c.data
			gatherable_items.add_child(new_item)
			new_item.global_position = c.global_position
			var chunk: Chunk = Globals.chunker.get_chunk_from_pos(new_item.global_position)
			new_item.basis = c.basis
			new_item.name = generate_unique_name(new_item)
			
			# this is done because new_item has @tool ffs
			await get_tree().process_frame
			
			chunk.chunk_data.entities.append(new_item.generate_entity_data())
			
			editor_spawned_items.remove_child(c)
			c.queue_free()
			
		
	editor_spawned_items.queue_free()
	
	
func _on_item_dropped(item: Node) -> void:	
	item.name = generate_unique_name(item)
	
	gatherable_items.add_child(item, true)
	var player_forward: Vector3 = -Globals.player.basis.z
	item.global_position = Globals.player.global_position + (Vector3.UP * 2.0) + (1.5 * player_forward)

func generate_unique_name(node: Node) -> String:
	return str(node.get_instance_id())+ str(gatherable_items.get_child_count())
