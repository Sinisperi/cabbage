extends Node

const CHUNK_COLUMNS: int = 16
const CHUNKS_PER_REGION: int = CHUNK_COLUMNS * CHUNK_COLUMNS

const HEADER_SIZE: int = CHUNKS_PER_REGION * 8
const SAVE_DIR: String = "regions/"


func create_region_file(path: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	
	## CREATE FILE HEADER WHERE CHUNK INDEX POINTS TO CHUNK DATA IN THE FILE
	for i in range(CHUNKS_PER_REGION):
		file.store_64(0)
	file.close()
	
	
func save_chunk(chunk_coords: Vector2i, chunk_data: Dictionary) -> void:
	var region_file_path: String = get_region_file_path(chunk_coords)
	var chunk_index: int = get_chunk_index(chunk_coords)
	if !DirAccess.dir_exists_absolute(SaveDataManager.current_save_path + SAVE_DIR):
		DirAccess.make_dir_absolute(SaveDataManager.current_save_path + SAVE_DIR)
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


## TODO pack everything into bytes instead of dealing with dicts
#func pack_chunk_data(chunk_data: Dictionary) -> PackedByteArray:
	#var buffer: StreamPeerBuffer = StreamPeerBuffer.new()
	#
	#pass

func load_chunk(chunk_coords: Vector2i) -> Dictionary:
	var region_file_path: String = get_region_file_path(chunk_coords)
	var chunk_index: int = get_chunk_index(chunk_coords)
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


func defragment_region_files() -> void:
	var files: Array = DirAccess.get_files_at(SaveDataManager.current_save_path + SAVE_DIR)
	for i: String in files:
		_defragment_region_file(i)
	print(files)

func _defragment_region_file(file_name: String) -> void:
	var file_path: String = SaveDataManager.current_save_path + SAVE_DIR + file_name
	var temp_file: FileAccess = FileAccess.open(file_path + ".tmp", FileAccess.WRITE_READ)
	var region_file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	
	for i in range(CHUNKS_PER_REGION):
		temp_file.store_64(0)
	
	for i in range(CHUNKS_PER_REGION):
		region_file.seek(i * 8)
		var chunk_address: int = region_file.get_64()
		
		if chunk_address == 0:
			continue
			
		region_file.seek(chunk_address)
		var chunk_data: Variant = region_file.get_var()
		temp_file.seek_end()
		var new_chunk_address: int = temp_file.get_position()
		temp_file.store_var(chunk_data)
		temp_file.seek(i * 8)
		temp_file.store_64(new_chunk_address)

	region_file.close()
	temp_file.close()
	DirAccess.remove_absolute(file_path)
	DirAccess.rename_absolute(file_path + ".tmp", file_path)
		
		

func get_chunk_index(chunk_coords: Vector2i) -> int:
	var column: int = posmod(chunk_coords.x, CHUNK_COLUMNS)
	var row: int = posmod(chunk_coords.y, CHUNK_COLUMNS)
	return (column * CHUNK_COLUMNS) + row

func get_region_file_path(chunk_coords: Vector2i) -> String:
	var rx: int = int(floor(chunk_coords.x / float(CHUNK_COLUMNS)))
	var ry: int = int(floor(chunk_coords.y / float(CHUNK_COLUMNS)))
	return SaveDataManager.current_save_path + SAVE_DIR + "Region_" + str(rx) + "_" + str(ry)

func get_default_chunk_data() -> Dictionary:
	return {
		"entities": {},
		"removed_editor_entities": []
	}

func save_world() -> void:
	if Globals.chunker:
		var loaded_chunks: Dictionary = Globals.chunker.loaded_chunks
		for chunk: Vector2i in loaded_chunks:
			if loaded_chunks[chunk].is_dirty:
				save_chunk(chunk, loaded_chunks[chunk].chunk_data)
	else:
		print_rich("[color=yellow]Trying to save the world, but it is not loaded yet![/color]")
