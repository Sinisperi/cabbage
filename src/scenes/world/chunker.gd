class_name Chunker extends Node3D

const CHUNK_SIZE: int = 64
const REGION_SIZE: int = 16
const TOTAL_REGIONS: int = 2

@export var render_distance: int = 1
@export var unload_distance: int = 2


var loaded_chunks: Dictionary[Vector2i, bool] = {}
var loaded_regions: Dictionary[Vector2i, bool] = {}
var world_size: Rect2 = Rect2(Vector2i(-16, -16), Vector2i(16, 16))



## TODO
## Don't need to init chunks ( change their names cause it's been done in blender )
## Calculate world size somehow idk how maybe don't even need that
## No need to get and store chunk nodes just coordinates
## Store loaded regions each one will load the file from which you would get the chunk data with
## chunk coordinates as keys


func _ready() -> void:
	Globals.chunker = self
	init_chunks()


## TODO No need for this
func get_chunk_name_from_pos(pos: Vector3) -> String:
	return str(int(pos.x / CHUNK_SIZE )) + "_" + str(int(pos.z / CHUNK_SIZE))


func get_chunk_coord_from_pos(pos: Vector3) -> Vector2i:
	return Vector2(int(floor(pos.x / CHUNK_SIZE)), int(floor(pos.z / CHUNK_SIZE)))


## TODO No need for this
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


func get_region_from_coords(coords: Vector2i) -> Vector2i:
	return Vector2i(floor(coords.x / float(REGION_SIZE)), floor(coords.y / float(REGION_SIZE)))



var current_chunk: Vector2i = Vector2(INF, INF)
func get_loaded_chunks() -> void:
	var player_position: Vector3 = Globals.player.global_position
	
	var origin_chunk: Vector2i = get_chunk_coord_from_pos(player_position)
	if origin_chunk == current_chunk: return
	current_chunk = origin_chunk
	
	var visible_chunks: Dictionary[Vector2i, bool] = {}
	var active_regions: Dictionary[Vector2i, bool] = {}
	
	for x in range(-unload_distance, unload_distance + 1):
		for y in range(-unload_distance, unload_distance + 1):
			var chunk_coord: Vector2i = origin_chunk + Vector2i(x, y)
			
			
			
			## TODO world size is a rect2 so you can do has_point probably idk
			if chunk_coord.x > world_size.size.x + 1 || chunk_coord.y > world_size.size.y + 1: continue
			if chunk_coord.x < world_size.position.x || chunk_coord.y < world_size.position.y: continue
			
			var distance: int = int(origin_chunk.distance_to(chunk_coord))
			
			if distance <= render_distance:
				visible_chunks[chunk_coord] = true
				
			# only if it is already loaded
			elif distance <= unload_distance && loaded_chunks.has(chunk_coord):
				visible_chunks[chunk_coord] = true
			
			if distance <= unload_distance + 1:
				## NOTE This works but loads/unloads instantly so we need to do it
				## like with chunks with unload distance or something
				var region_coord: Vector2i = get_region_from_coords(chunk_coord)
				if !active_regions.has(region_coord):
					active_regions[region_coord] = true
				
				
					
	for i: Vector2i in loaded_chunks:
		if !visible_chunks.has(i):
			loaded_chunks[i] = false
			print("unloaded chunks")
	
	for i: Vector2i in visible_chunks:
		if !loaded_chunks.has(i):
			visible_chunks[i] = true
	
	for i in loaded_regions:
		if !active_regions.has(i):
			loaded_regions[i] = false
			print("unloaded region", i)
	
	for i in active_regions:
		if !loaded_regions.has(i):
			active_regions[i] = true
			print("loaded region", i)
	
	loaded_regions = active_regions
	loaded_chunks = visible_chunks
	print("chunks", visible_chunks)
	print("====================================================================")


# at the start of the game we should go over every chunk, save it into a file
# and then  queue_free


func unload_chunk(chunk: Chunk) -> void:
	var _chunk_data: Dictionary = chunk.chunk_data
	pass
	
func load_chunk(_chunk: Chunk) -> void:
	pass


func generate_chunk() -> void:
	pass
