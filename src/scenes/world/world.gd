class_name World extends Node3D


const CHUNK_SIZE: int = 32

@export var render_distance: int = 1
@export var unload_distance: int = 2
@onready var player_spawner: MultiplayerSpawner = %PlayerSpawner
@onready var chunks: Node3D = %Chunks



## 2 chunks render distance -> 1 we are currently in + 2 on each side and dioganally
## every time we discover new chunk we will generate its data, load it because we just entered it
## and then when we unload it, we save it into a file
var loaded_chunks: Dictionary[Vector2i, Chunk] = {}

## NOTE this is for debug purposes to simulate loading chunk data from filesystem

var chunk_data: Dictionary[String, Dictionary]


var world_size: Vector2 = Vector2.ZERO


#var asdf = {
	#"entities": [{ItemData.to_obj()}],
#}

# tool with durability uid: tool_name position: xy, data: { durability asdfasdflj }
# var item = ItemDb.get_item(uid)
# for i in data:
# 	item[i] = data[i]


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Globals.world = self
	init_chunks()
	calculate_world_size()


@rpc("any_peer", "call_local")
func _request_player_spawn(username: String = "NO USERNAME") -> void:
	if multiplayer.is_server():
		var peer_id: int = multiplayer.get_remote_sender_id()
		
		PlayerManager.add_player(peer_id, username)
		Globals.inventory.inventory_grid.place_items_request.rpc(Inventory.InventoryType.ITEM)
		Globals.inventory.hot_bar_slots.place_items_request.rpc(Inventory.InventoryType.HOT_BAR)
		Globals.inventory.equipment_slots.init_equipment_request.rpc()
		var data: Dictionary = {
			"peer_id": peer_id,
			"username": username
		}
		
		player_spawner.spawn(data)
		
		prints("spawning player", username, peer_id)


func get_chunk_name_from_pos(pos: Vector3) -> String:
	return str(int(pos.x / CHUNK_SIZE )) + "_" + str(int(pos.z / CHUNK_SIZE))


func get_chunk_coord_from_pos(pos: Vector3) -> Vector2i:
	return Vector2(int(pos.x / CHUNK_SIZE ), int(pos.z / CHUNK_SIZE))


func get_chunk_from_pos(pos: Vector3) -> Chunk:
	return chunks.get_node("./" + get_chunk_name_from_pos(pos))

## NOTE in future this is not going to be done with get_node or node tree at all
## we are going to be loading chunks and instantiating them from a file
## and then spawning all entities it has
func get_chunk_from_chunk_coords(coords: Vector2i) -> Chunk:
	return chunks.get_node("./" + str(coords.x) + "_" + str(coords.y))
	
	
func init_chunks() -> void:
	for c in chunks.get_children():
		c.name = get_chunk_name_from_pos(c.global_position)
		c.display_name()

func calculate_world_size() -> void:
	for c in chunks.get_children():
		world_size.x = max(world_size.x, int(c.global_position.x / CHUNK_SIZE))
		world_size.y = max(world_size.y, int(c.global_position.z / CHUNK_SIZE))
	
	print(world_size)






var current_chunk: Vector2i = Vector2.ZERO
func get_loaded_chunks() -> void:
	var player_position: Vector3 = Globals.player.global_position
	
	var origin_chunk: Vector2i = get_chunk_coord_from_pos(player_position)
	if origin_chunk == current_chunk: return
	current_chunk = origin_chunk
	
	var visible_chunks: Dictionary[Vector2i, Chunk] = {}
	var count: int = 0
	for x in range(-unload_distance, unload_distance + 1):
		for y in range(-unload_distance, unload_distance + 1):
			count += 1
			var chunk_coord: Vector2i = origin_chunk + Vector2i(x, y)
			if chunk_coord.x < 0 || chunk_coord.y < 0: continue
			if chunk_coord.x > world_size.x || chunk_coord.y > world_size.y: continue
			
			var distance: int = int(origin_chunk.distance_to(chunk_coord))
			
			if distance <= render_distance:
				visible_chunks[chunk_coord] = get_chunk_from_chunk_coords(chunk_coord)
			# only if it is already loaded
			elif distance <= unload_distance && loaded_chunks.has(chunk_coord):
				visible_chunks[chunk_coord] = get_chunk_from_chunk_coords(chunk_coord)
				
	for i: Vector2i in loaded_chunks:
		if !visible_chunks.has(i):
			loaded_chunks[i].unload()
	
	for i: Vector2i in visible_chunks:
		if !loaded_chunks.has(i):
			visible_chunks[i].load()
			print("loaded ", i)
	loaded_chunks = visible_chunks
				
