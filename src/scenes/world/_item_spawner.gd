class_name _ItemSpawner extends MultiplayerSpawner

@onready var item_drops: Node = %ItemDrops
const ITEM_DROP = preload("uid://diqi0pyya3sb6")



func _ready() -> void:
	return
	#Globals.item_spawner = self
	#EventBus.inventory.item_drop_requested.connect(func (item: Node) -> void: _on_item_dropped.rpc_id(1, item.generate_entity_data()))
	#EventBus.world.item_spawn_requested.connect(func (item_data: Variant) -> void: _on_item_spawn_requested.rpc_id(1, item_data))
	#EventBus.world.player_spawned_item_despawn_requested.connect(
		#func (item_id: String) -> void: _on_player_spawned_item_despawn_requested.rpc_id(1, item_id))
	#spawned.connect(_on_item_spawned)
	#spawn_function = _spawn_function
#
#
#@rpc("any_peer", "call_local")
#func _on_item_dropped(item: Variant) -> void:	
	#if multiplayer.is_server():
		##item["name"] = UUID.gen()
		#spawn(item)
#
#@rpc("any_peer", "call_local")
#func _on_item_spawn_requested(item_data: Variant) -> void:
	#if multiplayer.is_server():
		#item_data["registered_in_chunk"] = true
		##item_data["name"] = item_data.entity_id
		#spawn(item_data)
#
#
#func _on_item_spawned(item: Node) -> void:
	#item.update_visuals()
	#
#
#
#func _spawn_function(data: Dictionary) -> Node:
#
	#var item: ItemDrop = ITEM_DROP.instantiate()
	#######################################################
	#item.data = ItemDb.get_item_by_id(data.item_data.uid)
	#print(item.data, " item data here ,world dict id is ", data.item_data.uid)
	#
	#######################################################
	#item.position = Vector3(data.position.x, data.position.y, data.position.z)
	#item.rotation = Vector3(data.rotation.x, data.rotation.y, data.rotation.z)
	#item.name = UUID.gen()
	##item.name = data.name
	#if data.has("registered_in_chunk"):
		#item.is_registered_in_chunk = true
		#item.name = data.entity_id
	#return item
#
#@rpc("any_peer", "call_local")
#func _on_player_spawned_item_despawn_requested(item_id: String) -> void:
	#if multiplayer.is_server():
		#item_drops.get_node("./" + item_id).queue_free()
