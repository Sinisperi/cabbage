extends Control
@onready var continue_button: Button = %ContinueButton
@onready var world_name_line_edit: LineEdit = %WorldNameLineEdit
@onready var go_back_button: Button = %GoBackButton

signal back_button_pressed

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_button_pressed)
	go_back_button.pressed.connect(_go_back_button_pressed)
	

func _on_continue_button_pressed() -> void:
	#if !multiplayer.has_multiplayer_peer():
		#NetworkManager.enable_local_host()
	if multiplayer.is_server():
		SaveDataManager.create_save_slot(world_name_line_edit.text)
		load_world_with_character_creator.rpc()


func _go_back_button_pressed() -> void:
	back_button_pressed.emit()


@rpc("any_peer", "call_local")
func load_world_with_character_creator() -> void:
	EventBus.world.world_spawn_requested.emit(func(_world: World) -> void: Globals.player_ui.show_character_creator())
