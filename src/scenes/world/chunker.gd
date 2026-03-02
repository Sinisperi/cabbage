class_name Chunker extends Node3D

const CHUNK_SIZE: int = 64
const REGION_SIZE: int = 16
const TOTAL_REGIONS: int = 2
var CHUNK_TEMPLATE: Dictionary = {
	"player_count": 0,
	"life_time": 60.0,
	"is_dirty": false,
	"chunk_data": {
		"entities": [],
		"removed_editor_entities": []
	}
}

@export var chunk_render_distance: int = 1
@export var chunk_unload_distance: int = 2
@export var region_unload_margin_chunks: int = 1

var loaded_chunk_ids: Dictionary[Vector2i, bool] = {}
var loaded_region_ids: Dictionary[Vector2i, bool] = {}
#var loaded_regions: Dictionary[Vector2i, Dictionary] = {}
var loaded_chunks: Dictionary = {}
var chunk_cache: Dictionary = {}
var world_area: Rect2 = Rect2(Vector2i(-16, -16), Vector2i(32, 32))


@export var regions_container: Node3D


## TODO
## Don't need to init chunks ( change their names cause it's been done in blender )
## Calculate world size somehow idk how maybe don't even need that
## No need to get and store chunk nodes just coordinates
## Store loaded regions each one will load the file from which you would get the chunk data with
## chunk coordinates as keys


## NOTE
## I think I don't need to do much with item spawning
## I have ItemSpawner that will replicate, so all I have to do is load the region on host and
## spawn the items -> they will be replicated to clients. The only thing is the host will have
## every active region loaded but it's fine i think


func _ready() -> void:
	Globals.chunker = self


func get_chunk_name_from_pos(pos: Vector3) -> String:
	return str(int(pos.x / CHUNK_SIZE )) + "_" + str(int(pos.z / CHUNK_SIZE))


func get_chunk_coord_from_pos(pos: Vector3) -> Vector2i:
	return Vector2(int(floor(pos.x / CHUNK_SIZE)), int(floor(pos.z / CHUNK_SIZE)))



func get_region_from_coords(coords: Vector2i) -> Vector2i:
	return Vector2i(floor(coords.x / float(REGION_SIZE)), floor(coords.y / float(REGION_SIZE)))



var current_chunk: Vector2i = Vector2(INF, INF)
func get_loaded_chunks(delta: float) -> void:
	update_chunk_cache(delta)
	
	var player_position: Vector3 = Globals.player.global_position
	
	var origin_chunk: Vector2i = get_chunk_coord_from_pos(player_position)
	if origin_chunk == current_chunk: return
	current_chunk = origin_chunk
	
	var active_chunk_ids: Dictionary[Vector2i, bool] = {}
	var active_region_ids: Dictionary[Vector2i, bool] = {}
	
	for x in range(-chunk_unload_distance, chunk_unload_distance + 1):
		for y in range(-chunk_unload_distance, chunk_unload_distance + 1):
			var chunk_coord: Vector2i = origin_chunk + Vector2i(x, y)
			
			if !world_area.has_point(chunk_coord):
				continue
				
			var distance: int = int(origin_chunk.distance_to(chunk_coord))
			var region_coord: Vector2i = get_region_from_coords(chunk_coord)
			
			if distance <= chunk_render_distance:
				active_chunk_ids[chunk_coord] = true
				active_region_ids[region_coord] = true
				
			# only if it is already loaded
			elif distance <= chunk_unload_distance && loaded_chunk_ids.has(chunk_coord):
				active_chunk_ids[chunk_coord] = true
				if loaded_region_ids.has(region_coord):
					active_region_ids[region_coord] = true
				
			
				
					
	for i: Vector2i in loaded_chunk_ids.keys():
		if !active_chunk_ids.has(i):
			#loaded_chunk_ids[i] = false
			loaded_chunk_ids.erase(i)
			#print("unloaded chunk ", i)
			
			if !loaded_chunks.has(i):
				printerr("Trying to save chunk ", i, " but it's not loaded")
				continue
			loaded_chunks[i].player_count -= 1
			if loaded_chunks[i].player_count <= 0:
				chunk_cache[i] = loaded_chunks[i]
				loaded_chunks.erase(i)
				
			highlight_chunk(i, "CACHED")
	
	for i: Vector2i in active_chunk_ids:
		if !loaded_chunk_ids.has(i):
			#active_chunk_ids[i] = true
			if !loaded_chunks.has(i):
				if chunk_cache.has(i):
					chunk_cache[i].life_time = 60.0
					loaded_chunks[i] = chunk_cache[i]
					chunk_cache.erase(i)
					print("loaded chunk ", i, " from cache")
				else:
					loaded_chunks[i] = {
						"player_count": 0,
						"life_time": 20.0,
						"is_dirty": false,
						"chunk_data": ChunkLoader.load_chunk(i)
					}
			loaded_chunks[i].player_count += 1
			highlight_chunk(i, "LOADED")
	
	for i in loaded_region_ids:
		if !active_region_ids.has(i):
			#save_region_file(i)
			#loaded_regions.erase(i)
			# Do stuff with LODs
			print("unloaded region", i)
	
	for i in active_region_ids:
		if !loaded_region_ids.has(i):
			#active_region_ids[i] = true
			# Do stuff with LODs
			print("loaded region ", i)
			#loaded_regions[i] = load_region_file(i)
	
	loaded_region_ids = active_region_ids
	loaded_chunk_ids = active_chunk_ids
	#print("chunks", active_chunk_ids, active_chunk_ids.size())
	print("====================================================================")
	


func update_chunk_cache(delta: float) -> void:
	for i: Variant in chunk_cache.keys():
		chunk_cache[i].life_time -= delta
		if chunk_cache[i].life_time <= 0.0:
			if chunk_cache[i].is_dirty:
				ChunkLoader.save_chunk(i, chunk_cache[i].chunk_data)
			chunk_cache.erase(i)
			highlight_chunk(i, "UNLOADED")
			
			


func add_entity_to_chunk(entity_data: Dictionary) -> void:
	var pos: Vector3 = Vector3(entity_data.position.x, entity_data.position.y, entity_data.position.z)
	var chunk: Vector2i = get_chunk_coord_from_pos(pos)
	if !loaded_chunks.has(chunk):
		printerr("Somehow trying to drop stuff at the chunk ", chunk, " which is
		not loaded!")
	loaded_chunks[chunk].chunk_data.entities.push_back(entity_data)
	loaded_chunks[chunk].is_dirty = true
	print("dropping ", entity_data)


func remove_entity_from_chunk(entity_data: Dictionary) -> void:
	var pos: Vector3 = Vector3(entity_data.position.x, entity_data.position.y, entity_data.position.z)
	var chunk: Vector2i = get_chunk_coord_from_pos(pos)
	if !loaded_chunks.has(chunk):
		printerr("Somehow trying to pick up stuff at the chunk ", chunk, " which is
		not loaded!")
	loaded_chunks[chunk].chunk_data.entities.erase(entity_data)
	loaded_chunks[chunk].is_dirty = true


func remove_editor_entity_from_chunk(index: int, pos: Vector3) -> void:
	var chunk: Vector2i = get_chunk_coord_from_pos(pos)
	loaded_chunks[chunk].chunk_data.removed_editor_entities.push_back(index)
	loaded_chunks[chunk].is_dirty = true


func update_chunk_visuals(chunk: Vector2i) -> void:
	pass


func highlight_chunk(pos: Vector2i, tag: String) -> void:
	var region_position: Vector2i = get_region_from_coords(pos)
	var region_name: String = "region_" + str(region_position.x) + "_" + str(region_position.y)
	var region_node: Node = regions_container.get_node("./" + region_name)
	var chunk_node: MeshInstance3D = region_node.get_node("./" + "Chunk_" + str(pos.x) + "_" + str(pos.y))
	var mat: StandardMaterial3D = chunk_node.get_active_material(0)
	if mat:
		var new_mat: StandardMaterial3D = mat.duplicate()
		match tag:
			"LOADED":
				new_mat.albedo_color = Color.SEA_GREEN
			"CACHED":
				new_mat.albedo_color = Color.ORANGE
			"UNLOADED":
				new_mat.albedo_color = Color.WHITE
			_:
				new_mat.albedo_color = Color.WHITE
				
				
		chunk_node.set_surface_override_material(0, new_mat)
			
