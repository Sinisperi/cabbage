extends Node

var save_path_root: String = "res://saves/"
var current_save_slot: String = ""
var current_save_path: String:
	get():
		return save_path_root + current_save_slot + "/"


func _ready() -> void:
	if !DirAccess.dir_exists_absolute(save_path_root):
		DirAccess.make_dir_absolute(save_path_root)


func save_slot_exists(save_name: String) -> bool:
	return DirAccess.dir_exists_absolute(save_path_root + save_name)


func list_save_slots() -> Array:
	var res: Array[Dictionary] = []
	for i in DirAccess.get_directories_at(save_path_root):
		var slot_icon: Texture2D = null
		if FileAccess.file_exists(save_path_root + i + "/" + i + ".jpg"):
			slot_icon = load(save_path_root + i + "/" + i + ".jpg")
		var save_slot_data: Dictionary = {
			"slot_name": i,
			"slot_meta": load_root_save_file(save_path_root + i + "/" + i + ".json"),
			"slot_icon": slot_icon
		}
		res.push_back(save_slot_data)
	return res


func create_save_slot(save_name: String) -> void:
	current_save_slot = save_name
	DirAccess.make_dir_absolute(save_path_root + save_name)


func save_game() -> void:
	PlayerManager.save_active_players()
	#PlayerManager.save_inactive_players()
	ChunkLoader.save_world()
	ItemDb.save_world_dict()
	save_root_save_file()
	await take_screenshot()


func load_save_slot(save_slot: String) -> void:
	current_save_slot = save_slot


func delete_save_slot(save_slot: String) -> void:
	_remove_dir_recursive(save_path_root + save_slot)


func _remove_dir_recursive(file_path: String) -> void:
	var dir: DirAccess = DirAccess.open(file_path)
	if dir:
		dir.list_dir_begin()
		var file_name: String = dir.get_next()
		while file_name.length():
			if file_name == "." || file_name == "..":
				file_name = dir.get_next()
				continue
			var current_path: String = file_path + "/" + file_name
			print(current_path)
			if dir.current_is_dir():
				_remove_dir_recursive(current_path)
			else:
				dir.remove(current_path)
			file_name = dir.get_next()
		dir.list_dir_end()
		DirAccess.remove_absolute(file_path)


func save_root_save_file() -> void:
	var file_name: String = current_save_path + current_save_slot.get_slice("/", 0) + ".json"
	var data: Dictionary = {
		"last_played": Time.get_datetime_string_from_system(),
	}
	var data_string: String = JSON.stringify(data)
	var file: FileAccess = FileAccess.open(file_name, FileAccess.WRITE)
	file.store_string(data_string)
	file.close()


func load_root_save_file(path: String) -> Dictionary:
	var file_name: String = path
	if !FileAccess.file_exists(file_name):
		return {"last_played": "00-00-00"}
	var file: FileAccess = FileAccess.open(file_name, FileAccess.READ)
	
	var json: JSON = JSON.new()
	json.parse(file.get_line())
	var data: Variant = json.data
	return data if data else {"last_played": "00-00-00"}


func take_screenshot() -> void:
	var file_name: String = current_save_path + current_save_slot.get_slice("/", 0) + ".jpg"
	await RenderingServer.frame_post_draw
	Globals.screenshot_sub_viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	var image: Image = Globals.screenshot_sub_viewport.get_texture().get_image()
	image.save_jpg(file_name, 0.5)
