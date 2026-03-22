extends Node
@onready var world_container: Node = %WorldContainer
@export var world_scene: PackedScene


func test() -> void:
	var item_schema: Schema = (
		Schema
		. new(
			{
				"name": Schema.Type.STRING,
				"price": Schema.Type.U16,
			}
		)
	)

	var person_schema: Schema = (
		Schema
		. new(
			{
				"name": Schema.Type.STRING,
				"age": Schema.Type.U8,
				"money": Schema.Type.S32,
				"location": Schema.Type.COORD,
				"inventory": [item_schema.get_schema()],
				"personal_details":
				{
					"city": Schema.Type.STRING,
					"street": Schema.Type.STRING,
					"building": Schema.Type.U8,
					"apt": Schema.Type.U8,
				}
			}
		)
	)

	var input_data: Dictionary = {
		"name": "Vitalik",
		"age": 43,
		"money": 2399,
		"location": Vector3(32.3450094475, 12.34230498, 324.3443423),
		"inventory":
		[
			{"name": "Potato", "price": 453.43},
			{"name": "Orange Juice", "price": 324.54},
			{"name": "Blue Cheese", "price": 3.44}
		],
		"personal_details":
		{
			"city": "Washington",
			"street": "The Street",
			"building": 32,
			"apt": 2,
		}
	}

	person_schema.create_buffer(input_data)
	print("input====================== \n", input_data)
	print("output ================================")
	print(person_schema.from_bytes(person_schema.data_array))
	pass


func _ready() -> void:
	EventBus.world.world_spawn_requested.connect(spawn_world)
	NetworkManager.host_disconnected.connect(_on_host_disconnected)
	SteamManager.invite_accepted.connect(_on_invite_accepted)
	test()


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
		Globals.world = null


func _on_invite_accepted() -> void:
	if Globals.world:
		world_container.get_child(0).call_deferred("queue_free")
		Globals.world = null

	Globals.network_bridge.clear_spawners()

	await get_tree().physics_frame
	EventBus.world.world_cleanup_finished.emit()
