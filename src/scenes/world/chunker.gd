class_name Chunker extends Node3D

const CHUNK_SIZE: int = 32

@export var render_distance: int = 2
@export var unload_distance: int = 3


var loaded_chunks: Dictionary[Vector2i, Chunk] = {}
var world_size: Vector2 = Vector2.ZERO


func _ready() -> void:
	Globals.chunker = self
	init_chunks()
	calculate_world_size()


func get_chunk_name_from_pos(pos: Vector3) -> String:
	return str(int(pos.x / CHUNK_SIZE )) + "_" + str(int(pos.z / CHUNK_SIZE))


func get_chunk_coord_from_pos(pos: Vector3) -> Vector2i:
	return Vector2(int(pos.x / CHUNK_SIZE ), int(pos.z / CHUNK_SIZE))


func get_chunk_from_pos(pos: Vector3) -> Chunk:
	return get_node("./" + get_chunk_name_from_pos(pos))


## NOTE in future this is not going to be done with get_node or node tree at all
## we are going to be loading chunks and instantiating them from a file
## and then spawning all entities it has
func get_chunk_from_chunk_coords(coords: Vector2i) -> Chunk:
	return get_node("./" + str(coords.x) + "_" + str(coords.y))
	
	
func init_chunks() -> void:
	for c in get_children():
		c.name = get_chunk_name_from_pos(c.global_position)
		c.display_name()


func calculate_world_size() -> void:
	for c in get_children():
		world_size.x = max(world_size.x, int(c.global_position.x / CHUNK_SIZE))
		world_size.y = max(world_size.y, int(c.global_position.z / CHUNK_SIZE))
	


var current_chunk: Vector2i = Vector2.ZERO
func get_loaded_chunks() -> void:
	var player_position: Vector3 = Globals.player.global_position
	
	var origin_chunk: Vector2i = get_chunk_coord_from_pos(player_position)
	if origin_chunk == current_chunk: return
	current_chunk = origin_chunk
	
	var visible_chunks: Dictionary[Vector2i, Chunk] = {}
	for x in range(-unload_distance, unload_distance + 1):
		for y in range(-unload_distance, unload_distance + 1):
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
	loaded_chunks = visible_chunks


# at the start of the game we should go over every chunk, save it into a file
# and then  queue_free


func unload_chunk(chunk: Chunk) -> void:
	var chunk_data: Dictionary = chunk.chunk_data
	pass
	
func load_chunk(chunk: Chunk) -> void:
	pass


func generate_chunk() -> void:
	pass
