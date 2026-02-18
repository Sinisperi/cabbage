extends Node

var current_scene: Node = null

class Scene:
	static var NEW_GAME_SCREEN: String = "uid://bla5i5xxak8jt"
	static var WORLD_SCENE: String = "uid://bs3374vl80v8o"
	
func _ready() -> void:
	current_scene = get_tree().root.get_child(-1)


func _load_scene(scene_path: String, callback: Callable) -> void:
	if !current_scene: return
	
	if current_scene.scene_file_path != scene_path:
		var new_scene: Node = ResourceLoader.load(scene_path).instantiate()
		get_tree().root.remove_child(current_scene)
		current_scene.call_deferred("queue_free")
		get_tree().root.add_child(new_scene)
		
		if !new_scene.is_node_ready():
			await new_scene.ready
		current_scene = new_scene
		
		if not callback.is_null():
			callback.call(current_scene)


func load_scene(scene_path: String, callback: Callable = Callable()) -> void:
	call_deferred("_load_scene", scene_path, callback)
