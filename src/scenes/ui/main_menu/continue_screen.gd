extends Control
@onready var go_back_button: Button = %GoBackButton
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
	#if !multiplayer.has_multiplayer_peer():
		#NetworkManager.enable_local_host()
	if !multiplayer.is_server():
		NetworkManager.switch_connection_type(NetworkManager.ConnectionType.LOCAL)
	if current_selected_slot.length():
		SaveDataManager.load_save_slot(current_selected_slot)
		load_saves_or_character_creator_for_peers()
		load_world(true)
	print("peer id", multiplayer.get_unique_id(), "is peer enet ", NetworkManager.peer is ENetMultiplayerPeer)

@rpc("any_peer", "call_remote")
func load_world(has_save: bool) -> void:
	if !has_save:
		EventBus.world.world_spawn_requested.emit(func(_world: World) -> void: Globals.player_ui.show_character_creator())
	else:
		EventBus.world.world_spawn_requested.emit(func(world: World) -> void: world._request_player_spawn.rpc_id(1))

func load_saves_or_character_creator_for_peers() -> void:
	for peer_id: int in multiplayer.get_peers():
		if peer_id > 1:
			var has_save: bool = PlayerManager.player_has_save(SteamManager.get_peer_steam_id(peer_id))
			load_world.rpc_id(peer_id, has_save)


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
	
