class_name Chunker extends Node3D

const CHUNK_SIZE: int = 64
const REGION_SIZE: int = 16
const TOTAL_REGIONS: int = 2
var CHUNK_TEMPLATE: Dictionary = {
	"entities": [],
	"removed_editor_entities": []
}
@export var chunk_render_distance: int = 1
@export var chunk_unload_distance: int = 2
@export var region_unload_margin_chunks: int = 1

var loaded_chunk_ids: Dictionary[Vector2i, bool] = {}
var loaded_region_ids: Dictionary[Vector2i, bool] = {}
var loaded_regions: Dictionary[Vector2i, Dictionary] = {}
var world_area: Rect2 = Rect2(Vector2i(-16, -16), Vector2i(32, 32))


@export var regions_container: Node3D


## TODO
## Don't need to init chunks ( change their names cause it's been done in blender )
## Calculate world size somehow idk how maybe don't even need that
## No need to get and store chunk nodes just coordinates
## Store loaded regions each one will load the file from which you would get the chunk data with
## chunk coordinates as keys


func _ready() -> void:
	Globals.chunker = self


func get_chunk_name_from_pos(pos: Vector3) -> String:
	return str(int(pos.x / CHUNK_SIZE )) + "_" + str(int(pos.z / CHUNK_SIZE))


func get_chunk_coord_from_pos(pos: Vector3) -> Vector2i:
	return Vector2(int(floor(pos.x / CHUNK_SIZE)), int(floor(pos.z / CHUNK_SIZE)))



func get_region_from_coords(coords: Vector2i) -> Vector2i:
	return Vector2i(floor(coords.x / float(REGION_SIZE)), floor(coords.y / float(REGION_SIZE)))



var current_chunk: Vector2i = Vector2(INF, INF)
func get_loaded_chunks() -> void:
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
				#if !loaded_regions.has(region_coord):
					# fake load/create region for now
				active_region_ids[region_coord] = true
				
			# only if it is already loaded
			elif distance <= chunk_unload_distance && loaded_chunk_ids.has(chunk_coord):
				active_chunk_ids[chunk_coord] = true
				if loaded_regions.has(region_coord):
					active_region_ids[region_coord] = true
				
			
				
					
	for i: Vector2i in loaded_chunk_ids:
		if !active_chunk_ids.has(i):
			loaded_chunk_ids[i] = false
			print("unloaded chunks")
			highlight_chunk(i, false)
	
	for i: Vector2i in active_chunk_ids:
		if !loaded_chunk_ids.has(i):
			active_chunk_ids[i] = true
			highlight_chunk(i, true)
	
	for i in loaded_region_ids:
		if !active_region_ids.has(i):
			# fake save regions for now
			save_region_file(i)
			loaded_regions.erase(i)
			print("saved region", i)
	
	for i in active_region_ids:
		if !loaded_region_ids.has(i):
			# fake load regions for now
			active_region_ids[i] = true
			loaded_regions[i] = load_region_file(i)
	
	loaded_region_ids = active_region_ids
	loaded_chunk_ids = active_chunk_ids
	print("chunks", active_chunk_ids, active_chunk_ids.size())
	print("====================================================================")


# at the start of the game we should go over every chunk, save it into a file
# and then  queue_free


func add_entity_to_chunk(entity_data: Dictionary) -> void:
	var pos: Vector3 = Vector3(entity_data.position.x, entity_data.position.y, entity_data.position.z)
	var chunk: Vector2i = get_chunk_coord_from_pos(pos)
	var region_key: Vector2i = get_region_from_coords(chunk)
	if !loaded_regions.has(region_key):
		print("no region ", region_key, " is loaded")
		return
	if !loaded_regions[region_key].has(chunk):
		loaded_regions[region_key][chunk] = CHUNK_TEMPLATE.duplicate()
	loaded_regions[region_key][chunk].entities.push_back(entity_data)
		


func highlight_chunk(pos: Vector2i, on: bool) -> void:
	#var chunk_coords: Vector2i = get_chunk_coord_from_pos(pos)
	var region_position: Vector2i = get_region_from_coords(pos)
	var region_name: String = "region_" + str(region_position.x) + "_" + str(region_position.y)
	var region_node: Node = regions_container.get_node("./" + region_name)
	var chunk_node: MeshInstance3D = region_node.get_node("./" + "Chunk_" + str(pos.x) + "_" + str(pos.y))
	var mat: StandardMaterial3D = chunk_node.get_active_material(0)
	if mat:
		var new_mat: StandardMaterial3D = mat.duplicate()
		if on:
			new_mat.albedo_color = Color.RED
		else:
			new_mat.albedo_color = Color.WHITE
		chunk_node.set_surface_override_material(0, new_mat)
			



# this will be a sophisticated region loading thing with binary offsets and stuff

func load_region_file(region_id: Vector2i) -> Dictionary:
	print("loaded ", region_id, " region file")
	return {}


func save_region_file(_region_id: Vector2i) -> void:
	return
