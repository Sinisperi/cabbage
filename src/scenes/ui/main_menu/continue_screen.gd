extends Control
@onready var go_back_button: Button = %GoBackButton
@onready var confirm_button: Button = %ConfirmButton
@onready var save_slot_list: VBoxContainer = %SaveSlotList
@export var save_slot_scene: PackedScene
signal back_button_pressed
var current_selected_slot: SaveSlot = null

func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	go_back_button.pressed.connect(_go_back_button_pressed)
	
	list_save_slots()
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if current_selected_slot:
		current_selected_slot.unhighlight()
		current_selected_slot = null
		if visible:
			list_save_slots()
	
func _on_confirm_button_pressed() -> void:
	if !multiplayer.is_server():
		NetworkManager.switch_connection_type(NetworkManager.ConnectionType.LOCAL_HOST)
	if current_selected_slot != null && current_selected_slot.save_name.length():
		SaveDataManager.load_save_slot(current_selected_slot.save_name)
		load_saves_or_character_creator_for_peers()
		load_world(true)
	if current_selected_slot:
		current_selected_slot.unhighlight()
		current_selected_slot = null
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
	for i: Dictionary in save_slots:
		var save_slot: SaveSlot = save_slot_scene.instantiate()
		save_slot.save_name = i.slot_name
		save_slot.last_time_played = i.slot_meta.last_played
		save_slot_list.add_child(save_slot)
		save_slot.selected.connect(_on_save_slot_selected)
		save_slot.delete_requested.connect(_on_save_slot_delete_requested)
	


func _on_save_slot_selected(slot: SaveSlot) -> void:
	if current_selected_slot:
		current_selected_slot.unhighlight()
	slot.highlight()
	current_selected_slot = slot


func _on_save_slot_delete_requested(slot: SaveSlot) -> void:
	SaveDataManager.delete_save_slot(slot.save_name)
	save_slot_list.remove_child(slot)
	slot.call_deferred("queue_free")
