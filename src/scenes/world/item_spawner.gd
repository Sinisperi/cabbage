extends MultiplayerSpawner

@onready var gatherable_items: Node = %GatherableItems
@onready var editor_spawned_items: Node3D = %EditorSpawnedItems
const ITEM_DROP = preload("uid://diqi0pyya3sb6")



func _ready() -> void:
	
	EventBus.inventory.item_drop_requested.connect(func (item: Node) -> void: _on_item_dropped.rpc_id(1, item.generate_entity_data()))
	EventBus.world.item_spawn_requested.connect(func (item_data: Variant) -> void: _on_item_spawn_requested.rpc_id(1, item_data))
	EventBus.world.player_spawned_item_despawn_requested.connect(
		func (item_id: String) -> void: _on_player_spawned_item_despawn_requested.rpc_id(1, item_id))
	spawned.connect(_on_item_spawned)
	spawn_function = _spawn_function


@rpc("any_peer", "call_local")
func _on_item_dropped(item: Variant) -> void:	

	if multiplayer.is_server():
		spawn(item)

@rpc("any_peer", "call_local")
func _on_item_spawn_requested(item_data: Variant) -> void:
	if multiplayer.is_server():
		print(" trying to spawn AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", item_data)
		item_data["registered_in_chunk"] = true
		spawn(item_data)

func _on_item_spawned(item: Node) -> void:
	item.update_visuals()
	


func _spawn_function(data: Dictionary) -> Node:
	var item: ItemDrop = ITEM_DROP.instantiate()
	item.data = ItemDb.get_item(data.item_data.uid)
	item.position = Vector3(data.position.x, data.position.y, data.position.z)
	item.rotation = Vector3(data.rotation.x, data.rotation.y, data.rotation.z)
	item.name = UUID.gen()
	if data.has("registered_in_chunk"):
		item.is_registered_in_chunk = true
		item.name = data.item_id
	return item

@rpc("any_peer", "call_local")
func _on_player_spawned_item_despawn_requested(item_id: String) -> void:
	if multiplayer.is_server():
		gatherable_items.get_node("./" + item_id).queue_free()
