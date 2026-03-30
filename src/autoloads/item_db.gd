extends Node

const ITEMS_PATH = "res://src/resources/items/"
const WORLD_DICT_FILE_NAME = "world_dict.dat"
const ITEMS_MANIFEST_FILE = "items.manifest"

var _items_manifest: Dictionary = {}
var _id_to_name: Dictionary = {}
var _name_to_id: Dictionary = {}
var _is_dirty: bool = false
var _next_item_id: int = 0
var is_initialized: bool = false
signal initialized

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)


func _on_connected_to_server() -> void:
	init()

func init() -> void:
	load_items_manifest()
	_request_world_dict.rpc_id(1)


@rpc("any_peer", "call_local", "reliable")
func _request_world_dict() -> void:
	if multiplayer.is_server():
		if _id_to_name.is_empty() || _name_to_id.is_empty():
			load_world_dict()
		var peer_id: int = multiplayer.get_remote_sender_id()
		if peer_id > 1:
			send_world_dict.rpc_id(peer_id, _id_to_name)
		else:
			if _name_to_id.is_empty() || _id_to_name.is_empty():
				load_world_dict()


@rpc("any_peer", "call_remote", "reliable")
func send_world_dict(dict: Dictionary) -> void:
	_reset_state()
	_id_to_name = dict
	for id: int in dict:
		_name_to_id[dict[id]] = id
		if id >= _next_item_id:
			_next_item_id = id + 1
	initialized.emit()
	is_initialized = true


func _reset_state() -> void:
	_name_to_id.clear()
	_id_to_name.clear()
	_next_item_id = 0
	_is_dirty = false


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
		# if not multiplayer.is_server(): send rpc to ask for id if it's not already in _name_to_id
		_next_item_id += 1
		_name_to_id[item_name] = id
		_id_to_name[id] = item_name
		return id
	return _name_to_id[item_name]


@rpc("any_peer", "call_local")
func _request_item_id_from_name(item_name: String) -> int:
	return 0


func get_item_by_id(id: int) -> ItemData:
	var item_data: ItemData = null
	var item_name: String = name_from_id(id)
	if item_name == "unknown_item":
		print("UNKNOWN ITEM AAAAAAAAAAA NAME FROM ID: ", _id_to_name)
		return item_data

	if _items_manifest.has(item_name):
		var resource_path: String = ITEMS_PATH.path_join(_items_manifest[item_name])
		item_data = load(resource_path).duplicate()

	return item_data


func get_item_by_name(item_name: String) -> ItemData:
	var res: ItemData = null
	if _items_manifest.has(item_name):
		res = load(ITEMS_PATH.path_join(_items_manifest[item_name])).duplicate()
	else:
		printerr("Failed to load an item resource ", item_name, " from items.manifest")
	return res
	
	
func load_items_manifest() -> void:
	var file_name: String = ITEMS_PATH.path_join(ITEMS_MANIFEST_FILE)
	var file: FileAccess = FileAccess.open(file_name, FileAccess.READ)
	if file:
		var data: Variant = file.get_var()
		_items_manifest = data
	else:
		printerr("Unable to load manifest file ", file_name)
