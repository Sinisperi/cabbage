@tool
extends EditorScript

var items: Dictionary = {}


func _run() -> void:
	const ITEMS_PATH = "res://src/resources/items/"
	_load_item_paths(ITEMS_PATH)
	_save_item_manifest()


func _load_item_paths(base_path: String, relative_path: String = "") -> void:
	var current_folder: String = base_path.path_join(relative_path)
	print("current folder ", current_folder)
	var dir: DirAccess = DirAccess.open(current_folder)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				_load_item_paths(base_path, relative_path.path_join(file_name))
			elif file_name.ends_with(".tres"):
				var res: ItemData = load(base_path.path_join(relative_path).path_join(file_name))
				var normalized_item_name: String = res.item_name.to_lower().replace(" ", "_")
				items[normalized_item_name] = relative_path.path_join(file_name)
			file_name = dir.get_next()

	else:
		printerr("No such directory ", current_folder)


func _save_item_manifest() -> void:
	const ITEMS_PATH = "res://src/resources/items/"
	var file_name: String = ITEMS_PATH.path_join("items.manifest")
	var file: FileAccess = FileAccess.open(file_name, FileAccess.WRITE)
	file.store_var(items)
	file.close()
