extends Node

var items: Dictionary = {}
const ITEMS_PATH = "res://src/resources/items/"

func _ready() -> void:
	_load_items(ITEMS_PATH)

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
	printerr("Item with id ", id, " does not exist!\nDid you forget to add its resource to ", ITEMS_PATH, "???\nYou silly silly goose")
	return null
