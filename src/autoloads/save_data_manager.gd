extends Node

@onready var save_path_root: String = "res://saves/"
var current_save_slot: String = ""
var current_save_path: String:
	get():
		return save_path_root + current_save_slot

func _ready() -> void:
	if !DirAccess.dir_exists_absolute(save_path_root):
		DirAccess.make_dir_absolute(save_path_root)


func save_slot_exists(save_name: String) -> bool:
	return DirAccess.dir_exists_absolute(save_path_root + save_name)


func list_save_slots() -> Array:
	return DirAccess.get_directories_at(save_path_root)


func create_save_slot(save_name: String) -> void:
	current_save_slot = save_name
	DirAccess.make_dir_absolute(save_path_root + save_name)


func save_game() -> void:
	PlayerManager.save_active_players()
	ChunkLoader.save_world()
	

func load_save_slot(save_slot: String) -> void:
	current_save_slot = save_slot + "/"


func delete_save_slot(save_slot: String) -> void:
	DirAccess.remove_absolute(save_path_root + save_slot)
