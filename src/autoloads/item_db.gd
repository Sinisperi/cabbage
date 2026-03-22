extends Node

const ITEMS_PATH = "res://src/resources/items/"
const WORLD_DICT_FILE_NAME = "world_dict.dat"

var items: Dictionary = {}
var _name_to_path: Dictionary = {}
var _id_to_name: Dictionary = {}
var _name_to_id: Dictionary = {}
var _is_dirty: bool = false
var _next_item_id: int = 0


func load_world_dict() -> void:
	_id_to_name.clear()
	_name_to_id.clear()

	var file_path: String = SaveDataManager.current_save_path + WORLD_DICT_FILE_NAME
	if !FileAccess.file_exists(file_path):
		return

	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var file_size: int = file.get_length()
		while file.get_position() < file_size:
			var id: int = file.get_16()
			var item_name: String = file.get_pascal_string()
			_id_to_name[id] = item_name
			_name_to_id[item_name] = id
			if _next_item_id <= id:
				_next_item_id = id + 1
		file.close()


func save_world_dict() -> void:
	if !_is_dirty:
		return
	var file_path: String = SaveDataManager.current_save_path + WORLD_DICT_FILE_NAME
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		for id: int in _id_to_name:
			file.store_16(id)
			file.store_pascal_string(_id_to_name[id])
		file.close()
	_is_dirty = false


func name_from_id(id: int) -> String:
	if !_id_to_name.has(id):
		return "unknown_item"
	return _id_to_name[id]


func id_from_name(item_name: String) -> int:
	if !_name_to_id.has(item_name):
		_is_dirty = true
		var id: int = _next_item_id
		_next_item_id += 1
		_name_to_id[item_name] = id
		_id_to_name[id] = item_name
		return id
	return _name_to_id[item_name]


func item_from_id(id: int) -> ItemData:
	var item_data: ItemData = null
	var item_name: String = name_from_id(id)

	if item_name == "unknown_item":
		return item_data

	if _name_to_path.has(item_name):
		var resource_path: String = ITEMS_PATH.path_join(_name_to_path[item_name])
		item_data = load(resource_path)

	return item_data


func _load_item_paths(base_path: String, relative_path: String = "") -> void:
	var current_folder: String = base_path.path_join(relative_path)
	var dir: DirAccess = DirAccess.open(current_folder)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				_load_item_paths(base_path, relative_path.path_join(file_name))
			elif file_name.ends_with(".tres"):
				_name_to_path[file_name.get_basename()] = relative_path.path_join(file_name)
			file_name = dir.get_next()

	else:
		printerr("No such directory ", current_folder)


# OLD WAY
func _ready() -> void:
	_load_items(ITEMS_PATH)
	_load_item_paths(ITEMS_PATH)
	load_world_dict()


func _load_items(path: String) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			var full_path: String = path + file_name
			if dir.current_is_dir():
				_load_items(full_path + "/")
			elif file_name.ends_with(".tres"):
				var item: Resource = load(full_path)

				if item is ItemData:
					items[item.uid] = item

			file_name = dir.get_next()
	else:
		printerr("No such directory ", path)


func get_item(id: String) -> ItemData:
	if items.has(id):
		return items[id].duplicate()
	printerr(
		"Item with id ",
		id,
		" does not exist!\nDid you forget to add its resource to ",
		ITEMS_PATH,
		"???\nYou silly silly goose"
	)
	return null
