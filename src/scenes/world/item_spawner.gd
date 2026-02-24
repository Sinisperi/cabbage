extends MultiplayerSpawner

@onready var gatherable_items: Node3D = %GatherableItems
@onready var editor_spawned_items: Node3D = %EditorSpawnedItems



func _ready() -> void:
	
	## Goes through editor_spawned_items and replicates all the children it has
	## into gatherable_items node that is being watched by ItemSpawner
	## We are doing it so ItemSpawner realizes that it has to replicate items on the client
	## and to make it so when host or some client picks up item and later another client joins, they will
	## not see picked up item on the ground
	
	if multiplayer.is_server():
		await get_tree().process_frame
		while editor_spawned_items.get_child_count():
			var c: Node = editor_spawned_items.get_child(-1)
			var new_item: Node = load(c.scene_file_path).instantiate()
			gatherable_items.add_child(new_item)
			new_item.global_position = c.global_position
			new_item.basis = c.basis
			new_item.name =  str(c.get_instance_id())+ str(editor_spawned_items.get_child_count())
			editor_spawned_items.remove_child(c)
			c.queue_free()
	editor_spawned_items.queue_free()
