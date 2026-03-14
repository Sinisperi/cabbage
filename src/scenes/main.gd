extends Node
@onready var world_container: Node = %WorldContainer
@export var world_scene: PackedScene


func _ready() -> void:
	EventBus.world.world_spawn_requested.connect(spawn_world)
	NetworkManager.host_disconnected.connect(_on_host_disconnected)

func spawn_world(callback: Callable = Callable()) -> void:
	if world_container.get_child_count() == 0:
		var world: World = world_scene.instantiate()
		world_container.add_child(world)
		if !world.is_node_ready():
			await world.ready
		if !callback.is_null():
			callback.call(world)


func _on_host_disconnected() -> void:
	if Globals.world:
		world_container.get_child(0).call_deferred("queue_free")
		EventBus.ui.main_menu_requested.emit()
