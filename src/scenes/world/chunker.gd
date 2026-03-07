class_name Chunker extends Node3D
const CHUNK_SIZE: int = 64
const REGION_SIZE: int = 16
const TOTAL_REGIONS: int = 2

const CHUNK_LIFE_TIME: float = 15.0

@export var chunk_render_distance: int = 1
@export var chunk_unload_distance: int = 2
@export var region_unload_margin_chunks: int = 1

var chunks_in_area_ids: Dictionary[Vector2i, bool] = {}
var loaded_region_ids: Dictionary[Vector2i, bool] = {}
var loaded_chunks: Dictionary = {}
var chunk_cache: Dictionary = {}
var world_area: Rect2 = Rect2(Vector2i(-16, -16), Vector2i(32, 32))

@onready var editor_spawned_items: Node3D = %EditorSpawnedItems
@onready var item_spawner: MultiplayerSpawner = %ItemSpawner


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
	
	var new_chunks_in_area: Dictionary[Vector2i, bool] = {}
	var active_region_ids: Dictionary[Vector2i, bool] = {}
	
	
	## WHAT WE SEE LOCALLY
	get_chunks_in_area(new_chunks_in_area, active_region_ids, origin_chunk)

				
			
				
	## ATTEMPT TO UNLOAD CHUNK TO CACHE WHEN PLAYER EXITS
	for i: Vector2i in chunks_in_area_ids.keys():
		if !new_chunks_in_area.has(i):
			chunks_in_area_ids.erase(i)
			if !loaded_chunks.has(i):
				printerr("Trying to move chunk to cache ", i, " but it's not loaded")
				continue
			if !multiplayer.is_server():
				send_player_exit_request.rpc_id(1, i)
				move_chunk_to_cache(i)
			else:
				#loaded_chunks[i].player_count -= 1
				_handle_player_exit(i)
	
	## LOAD CHUNK FROM DISK OR CACHE
	for i: Vector2i in new_chunks_in_area.keys():
		if !chunks_in_area_ids.has(i):
			## Chunk was loaded by other client
			if loaded_chunks.has(i):
				loaded_chunks[i].player_count += 1
				highlight_chunk(i, "LOADED", true)
			else:
				if chunk_cache.has(i):
					load_chunk_from_cache(i)
					loaded_chunks[i].player_count += 1
					highlight_chunk(i, "LOADED")
					## Event though we just loaded chunk from cache on the client,
					## we still send chunk data request to the server to resync
					## TODO check for stale chunk and if it is stale, then request data
					if !multiplayer.is_server():
						request_chunk_data.rpc_id(1, i.x, i.y)
				else:
					request_chunk_data.rpc_id(1, i.x, i.y)
				
					#if multiplayer.is_server():
						#spawn_player_spawned_items(i)
						#despawn_editor_spawned_items(i)
				
			
	update_regions(active_region_ids)
	
	loaded_region_ids = active_region_ids
	chunks_in_area_ids = new_chunks_in_area
	print("====================================================================")
	



func _handle_player_exit(chunk: Vector2i) -> void:
	if !loaded_chunks.has(chunk): return
	loaded_chunks[chunk].player_count -= 1
	highlight_chunk(chunk, "LOADED", loaded_chunks[chunk].player_count)
	if loaded_chunks[chunk].player_count <= 0:
		move_chunk_to_cache(chunk)

@rpc("any_peer", "call_local")
func request_chunk_data(chunk_x: int, chunk_y: int) -> void:
	var peer_id: int = multiplayer.get_remote_sender_id()
	var chunk: Vector2i = Vector2i(chunk_x, chunk_y)
	if !loaded_chunks.has(chunk):
		if chunk_cache.has(chunk):
			load_chunk_from_cache(chunk)
			print("loaded chunk ", chunk, " from cache and sent to peer ", peer_id)
		else:
			loaded_chunks[chunk] = load_chunk_data(chunk)
			spawn_player_spawned_items(chunk)
		despawn_editor_spawned_items(chunk)
	
	loaded_chunks[chunk].player_count += 1
	highlight_chunk(chunk, "LOADED", peer_id > 1)
	if peer_id > 1:
		## TODO send only removed editor spawned items
		send_chunk_data_to_peer.rpc_id(peer_id, loaded_chunks[chunk], chunk)
		

@rpc("any_peer", "call_remote")
func send_chunk_data_to_peer(chunk_data: Dictionary, chunk: Vector2i) -> void:
	loaded_chunks[chunk] = {
		"player_count": 1,
		"life_time": CHUNK_LIFE_TIME,
		"is_dirty": false,
		"chunk_data": chunk_data.chunk_data
	}
	highlight_chunk(chunk, "LOADED")
	despawn_editor_spawned_items(chunk)


func despawn_editor_spawned_items(chunk: Vector2i) -> void:
	for i: String in loaded_chunks[chunk].chunk_data.removed_editor_entities:
		if editor_spawned_items.has_node("./" + i):
			print(" has node trying to remove")
			var item: Node = editor_spawned_items.get_node("./" + i)
			editor_spawned_items.remove_child(item)


func spawn_player_spawned_items(chunk: Vector2i) -> void:
	for i: Variant in loaded_chunks[chunk].chunk_data.entities:
		#print("spawning ", i)
		EventBus.world.item_spawn_requested.emit(loaded_chunks[chunk].chunk_data.entities[i])

func despawn_player_spawned_items(items: Dictionary) -> void:
	for i: Variant in items:
		EventBus.world.player_spawned_item_despawn_requested.emit(i)


func move_chunk_to_cache(chunk: Vector2i) -> void:
	chunk_cache[chunk] = loaded_chunks[chunk]
	chunk_cache[chunk].player_count = 0
	loaded_chunks.erase(chunk)
	highlight_chunk(chunk, "CACHED")
	
	
func load_chunk_data(chunk: Vector2i) -> Dictionary:
	return {
		"player_count": 0,
		"life_time": CHUNK_LIFE_TIME,
		"is_dirty": false,
		"chunk_data": ChunkLoader.load_chunk(chunk)
	}

func load_chunk_from_cache(chunk: Vector2i) -> void:
	chunk_cache[chunk].life_time = CHUNK_LIFE_TIME
	loaded_chunks[chunk] = chunk_cache[chunk]
	chunk_cache.erase(chunk)
	print("loaded chunk ", chunk, " from cache")

func update_regions(active_region_ids: Dictionary) -> void:
	for i: Vector2i in loaded_region_ids:
		if !active_region_ids.has(i):
			print("unloaded region", i)
	
	for i: Vector2i in active_region_ids:
		if !loaded_region_ids.has(i):
			print("loaded region ", i)

			
func get_chunks_in_area(new_chunks_in_area: Dictionary, active_region_ids: Dictionary, origin_chunk: Vector2i) -> void:
	for x in range(-chunk_unload_distance, chunk_unload_distance + 1):
		for y in range(-chunk_unload_distance, chunk_unload_distance + 1):
			var chunk_coord: Vector2i = origin_chunk + Vector2i(x, y)
			
			if !world_area.has_point(chunk_coord):
				continue
				
			var distance: int = int(origin_chunk.distance_to(chunk_coord))
			var region_coord: Vector2i = get_region_from_coords(chunk_coord)
			
			if distance <= chunk_render_distance:
				new_chunks_in_area[chunk_coord] = true
				active_region_ids[region_coord] = true
				
			# only if it is already loaded
			elif distance <= chunk_unload_distance && chunks_in_area_ids.has(chunk_coord):
				new_chunks_in_area[chunk_coord] = true
				if loaded_region_ids.has(region_coord):
					active_region_ids[region_coord] = true



func update_chunk_cache(delta: float) -> void:
	for i: Variant in chunk_cache.keys():
		chunk_cache[i].life_time -= delta
		if chunk_cache[i].life_time <= 0.0:
			if chunk_cache[i].is_dirty:
				if multiplayer.is_server():
					ChunkLoader.save_chunk(i, chunk_cache[i].chunk_data)
			if multiplayer.is_server():
				despawn_player_spawned_items(chunk_cache[i].chunk_data.entities)
			chunk_cache.erase(i)
			highlight_chunk(i, "UNLOADED")


@rpc("any_peer", "call_local", "reliable")
func send_player_exit_request(chunk: Vector2i) -> void:
	if multiplayer.is_server():
		_handle_player_exit(chunk)
	
	



func add_entity_to_chunk(entity_data: Dictionary) -> void:
	var pos: Vector3 = Vector3(entity_data.position.x, entity_data.position.y, entity_data.position.z)
	var chunk: Vector2i = get_chunk_coord_from_pos(pos)
	if !loaded_chunks.has(chunk):
		printerr("Somehow trying to drop stuff at the chunk ", chunk, " which is
		not loaded!")
	loaded_chunks[chunk].chunk_data.entities[entity_data.item_id] = entity_data
	loaded_chunks[chunk].is_dirty = true
	print("dropping ", entity_data)


func remove_entity_from_chunk(entity_data: Dictionary) -> void:
	var pos: Vector3 = Vector3(entity_data.position.x, entity_data.position.y, entity_data.position.z)
	var chunk: Vector2i = get_chunk_coord_from_pos(pos)
	if !loaded_chunks.has(chunk):
		printerr("Somehow trying to pick up stuff at the chunk ", chunk, " which is
		not loaded!")
	loaded_chunks[chunk].chunk_data.entities.erase(entity_data.item_id)
	loaded_chunks[chunk].is_dirty = true
	print("removed entity", entity_data)


func remove_editor_entity_from_chunk(entity_data: Dictionary) -> void:
	var pos: Vector3 = Vector3(entity_data.position.x, entity_data.position.y, entity_data.position.z)
	var chunk: Vector2i = get_chunk_coord_from_pos(pos)
	loaded_chunks[chunk].chunk_data.removed_editor_entities.push_back(entity_data.item_id)
	loaded_chunks[chunk].is_dirty = true




func highlight_chunk(pos: Vector2i, tag: String, is_client: bool = false) -> void:
	#return
	var region_position: Vector2i = get_region_from_coords(pos)
	var region_name: String = "region_" + str(region_position.x) + "_" + str(region_position.y)
	var region_node: Node = regions_container.get_node("./" + region_name)
	var chunk_node: MeshInstance3D = region_node.get_node("./" + "Chunk_" + str(pos.x) + "_" + str(pos.y))
	var mat: StandardMaterial3D = chunk_node.get_active_material(0)
	var label: Label3D
	if chunk_node.has_node("./PlayerCount"):
		label = chunk_node.get_node("./PlayerCount")
	else:
		label = Label3D.new()
		chunk_node.add_child(label)
		
	label.rotation_degrees.x = -90.0
	label.pixel_size = 0.5
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.position.z = 7.0
	#label.position.x = 32.0
	label.position.y = 0.05
	label.text = "0"
	label.name = "PlayerCount"
	
	if mat:
		var new_mat: StandardMaterial3D = mat.duplicate()
		match tag:
			"LOADED":
				if is_client:
					new_mat.albedo_color = Color.DARK_BLUE
				else:
					new_mat.albedo_color = Color.SEA_GREEN
				label.text = str(pos)
				#label.text = str(loaded_chunks[pos].player_count)
			"CACHED":
				new_mat.albedo_color = Color.ORANGE
				label.text = str(pos)
				#label.text = str(chunk_cache[pos].player_count)
			"UNLOADED":
				new_mat.albedo_color = Color.WHITE
			_:
				new_mat.albedo_color = Color.WHITE
				
				
		chunk_node.set_surface_override_material(0, new_mat)
			


func get_current_region() -> Vector2i:
	return get_region_from_coords(current_chunk)
