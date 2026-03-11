extends Control
@onready var go_back_button: Button = %GoBackButton
#@onready var continue_button: Button = %ContinueButton
@onready var confirm_button: Button = %ConfirmButton
@onready var save_slot_list: VBoxContainer = %SaveSlotList
@export var save_slot_scene: PackedScene
signal back_button_pressed
var current_selected_slot: String = ""

func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	go_back_button.pressed.connect(_go_back_button_pressed)
	
	list_save_slots()
	
func _on_confirm_button_pressed() -> void:
	print_rich("You press continue button [color=yellow] but nothing happens![/color]")
	if multiplayer.is_server():
		if current_selected_slot.length():
			SaveDataManager.load_save_slot(current_selected_slot)
			load_world.rpc()

@rpc("any_peer", "call_local")
func load_world() -> void:
	SceneLoader.load_scene_with_callback(SceneLoader.Scene.WORLD_SCENE, func(world: World) -> void: world._request_player_spawn.rpc_id(1))
	

func _go_back_button_pressed() -> void:
	back_button_pressed.emit()


func list_save_slots() -> void:
	var save_slots: Array = SaveDataManager.list_save_slots()
	for i: String in save_slots:
		var save_slot: SaveSlot = save_slot_scene.instantiate()
		save_slot.save_name = i
		save_slot.last_time_played = "00-00-00"
		save_slot_list.add_child(save_slot)
		save_slot.selected.connect(func(slot_name: String) -> void: current_selected_slot = slot_name)
	
