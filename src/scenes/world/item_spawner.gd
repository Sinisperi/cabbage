extends MultiplayerSpawner

@onready var gatherable_items: Node = %GatherableItems
@onready var editor_spawned_items: Node3D = %EditorSpawnedItems
const ITEM_DROP = preload("uid://diqi0pyya3sb6")



func _ready() -> void:
	
	EventBus.inventory.item_drop_requested.connect(func (item: Node) -> void: _on_item_dropped.rpc_id(1, item.generate_entity_data()))
	spawned.connect(_on_item_spawned)
	spawn_function = _spawn_function


@rpc("any_peer", "call_local")
func _on_item_dropped(item: Variant) -> void:	

	if multiplayer.is_server():
		#Globals.chunker.add_entity_to_chunk(item)
		spawn(item)



func _on_item_spawned(item: Node) -> void:
	item.update_visuals()


func _spawn_function(data: Dictionary) -> Node:
	var item: ItemDrop = ITEM_DROP.instantiate()
	item.data = ItemDb.get_item(data.item_data.uid)
	item.position = Vector3(data.position.x, data.position.y, data.position.z)
	item.rotation = Vector3(data.rotation.x, data.rotation.y, data.rotation.z)
	item.name = str(Time.get_unix_time_from_system())
	return item
