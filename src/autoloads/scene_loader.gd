extends Node

var current_scene: Node = null

class Scene:
	## TODO not switch to it but just add it to main menu and show/hide it when needed
	static var MAIN_MENU: String = "uid://d0b3fdfc26ir6"
	static var WORLD_SCENE: String = "uid://bs3374vl80v8o"
	static var CHARACTER_CREATOR: String = "uid://ccodm1qwcmie4"
	
	
var scene_history: Array[String] = []
var max_history: int = 3
func _ready() -> void:
	current_scene = get_tree().root.get_child(-1)


func _load_scene(scene_path: String, callback: Callable) -> void:
	if !current_scene: return
	
	if current_scene.scene_file_path != scene_path:
		var new_scene: Node = ResourceLoader.load(scene_path).instantiate()
		get_tree().root.remove_child(current_scene)
		add_scene_to_history(current_scene.scene_file_path)
		current_scene.call_deferred("queue_free")
		get_tree().root.add_child(new_scene)
		
		if !new_scene.is_node_ready():
			await new_scene.ready
		current_scene = new_scene
		
		if not callback.is_null():
			callback.call(current_scene)


func load_scene(scene_path: String, callback: Callable = Callable()) -> void:
	call_deferred("_load_scene", scene_path, callback)


func go_back() -> void:
	if scene_history.size():
		load_scene(scene_history.pop_back())
		scene_history.pop_back()


func add_scene_to_history(path: String) -> void:
	if scene_history.size() == max_history:
		scene_history = scene_history.slice(1)
	scene_history.push_back(path)
