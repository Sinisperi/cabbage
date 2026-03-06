extends Node

const CHUNK_COLUMNS: int = 16
const CHUNKS_PER_REGION: int = CHUNK_COLUMNS * CHUNK_COLUMNS

const HEADER_SIZE: int = CHUNKS_PER_REGION * 8
const debug_region_root_dir: String = "res://test_save/regions/"
const REGION_ROOT_DIR: String = debug_region_root_dir


func create_region_file(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	
	## CREATE FILE HEADER WHERE CHUNK INDEX POINTS TO CHUNK DATA IN THE FILE
	for i in range(CHUNKS_PER_REGION):
		file.store_64(0)
	file.close()
	
	
func save_chunk(chunk_coords: Vector2i, chunk_data: Dictionary) -> void:
	var region_file_path: String = get_region_file_path(chunk_coords)
	var chunk_index: int = get_chunk_index(chunk_coords)
	if !DirAccess.dir_exists_absolute(REGION_ROOT_DIR):
		DirAccess.make_dir_absolute(REGION_ROOT_DIR)
	if !FileAccess.file_exists(region_file_path):
		create_region_file(region_file_path)
	var file: FileAccess = FileAccess.open(region_file_path, FileAccess.READ_WRITE)
	file.seek_end()
	var chunk_offset: int = file.get_position()
	file.store_var(chunk_data)
	file.seek(chunk_index * 8)
	file.store_64(chunk_offset)
	file.close()
	
	print("Saving chunk ", chunk_coords, " in ", region_file_path, " at index", chunk_index)

	

func load_chunk(chunk_coords: Vector2i) -> Dictionary:
	var region_file_path: String = get_region_file_path(chunk_coords)
	var chunk_index: int = get_chunk_index(chunk_coords)
	#print("Loading chunk ", chunk_coords, " in ", region_file_path, " at index", chunk_index)
	#var dir: DirAccess = DirAccess.open(REGION_ROOT_DIR)
	#if dir:
	var file: FileAccess = FileAccess.open(region_file_path, FileAccess.READ)
	if file:
		file.seek(chunk_index * 8)
		var chunk_address: int = file.get_64()
		
		if chunk_address == 0:
			return get_default_chunk_data()
		
		file.seek(chunk_address)
		var chunk_data: Variant = file.get_var()
		file.close()
		return chunk_data

	return get_default_chunk_data()

func get_chunk_index(chunk_coords: Vector2i) -> int:
	var column: int = posmod(chunk_coords.x, CHUNK_COLUMNS)
	var row: int = posmod(chunk_coords.y, CHUNK_COLUMNS)
	return (column * CHUNK_COLUMNS) + row

func get_region_file_path(chunk_coords: Vector2i) -> String:
	var rx: int = int(floor(chunk_coords.x / float(CHUNK_COLUMNS)))
	var ry: int = int(floor(chunk_coords.y / float(CHUNK_COLUMNS)))
	return REGION_ROOT_DIR + "Region_" + str(rx) + "_" + str(ry)

func get_default_chunk_data() -> Dictionary:
	return {
		"entities": {},
		"removed_editor_entities": []
	}
