extends MultiplayerSpawner
@onready var node_3d: Node3D = $"../Node3D"
@onready var gatherable_items: Node3D = $"../GatherableItems"
const TEST_MUSHROOM = preload("uid://h7qw3eulkbcj")

func _ready() -> void:
	if multiplayer.is_server():
		#await get_tree().create_timer(0.2).timeout
		await get_tree().process_frame
		while node_3d.get_child_count():
			var c = node_3d.get_child(-1)
			#c.name = str(c.get_instance_id())+ str(node_3d.get_child_count())
			#c.reparent(gatherable_items, true)
			#var mushroom = TEST_MUSHROOM.instantiate()
			var mushroom = load(c.scene_file_path).instantiate()
			gatherable_items.add_child(mushroom)
			mushroom.global_position = c.global_position
			mushroom.basis = c.basis
			mushroom.name =  str(c.get_instance_id())+ str(node_3d.get_child_count())
			node_3d.remove_child(c)
			c.queue_free()
	node_3d.queue_free()

func _spawn_function(data: Variant) -> void:
	pass
