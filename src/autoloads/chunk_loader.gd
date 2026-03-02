extends Node

const CHUNK_COLUMNS: int = 16
const CHUNKS_PER_REGION: int = CHUNK_COLUMNS * CHUNK_COLUMNS

const HEADER_SIZE: int = CHUNKS_PER_REGION * 8
const debug_region_root_dir: String = "res://test_save/regions/"
const REGION_ROOT_DIR: String = debug_region_root_dir

func save_chunk(chunk_coords: Vector2i, chunk_data: Dictionary) -> void:
	var region_file_path: String = get_region_file_path(chunk_coords)
	var chunk_index: int = get_chunk_index(chunk_coords)
	print("Saving chunk ", chunk_coords, " in ", region_file_path, " at index", chunk_index)
	pass

func load_chunk(chunk_coords: Vector2i) -> Dictionary:
	var region_file_path: String = get_region_file_path(chunk_coords)
	var chunk_index: int = get_chunk_index(chunk_coords)
	print("Loading chunk ", chunk_coords, " in ", region_file_path, " at index", chunk_index)
	return {
		"entities": [],
		"removed_editor_entities": []
	}

func get_chunk_index(chunk_coords: Vector2i) -> int:
	var column: int = posmod(chunk_coords.x, CHUNK_COLUMNS)
	var row: int = posmod(chunk_coords.y, CHUNK_COLUMNS)
	return (column * CHUNK_COLUMNS) + row

func get_region_file_path(chunk_coords: Vector2i) -> String:
	var rx: int = int(floor(chunk_coords.x / float(CHUNK_COLUMNS)))
	var ry: int = int(floor(chunk_coords.y / float(CHUNK_COLUMNS)))
	return REGION_ROOT_DIR + "Region_" + str(rx) + "_" + str(ry)
