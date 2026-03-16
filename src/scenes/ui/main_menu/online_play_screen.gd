extends Control

signal back_button_pressed

@onready var go_back_button: Button = %GoBackButton
@onready var join_lobby_tab: Button = %JoinLobbyTab
@onready var create_lobby_tab: Button = %CreateLobbyTab
@onready var create_lobby_container: VBoxContainer = %CreateLobbyContainer
@onready var join_lobby_container: VBoxContainer = %JoinLobbyContainer
@onready var right_line: ColorRect = %RightLine
@onready var left_line: ColorRect = %LeftLine


@onready var invite_section: VBoxContainer = %InviteSection

@onready var private_checkbox: CheckBox = %PrivateCheckbox
@onready var friends_checkbox: CheckBox = %FriendsCheckbox

@onready var max_players_select: OptionButton = %MaxPlayersSelect

@onready var steam_checkbox: CheckBox = %SteamCheckbox
@onready var local_host_checkbox: CheckBox = %LocalHostCheckbox

@onready var create_lobby_button: Button = %CreateLobbyButton
@onready var send_invite_button: Button = %SendInviteButton
@onready var close_lobby_button: Button = %CloseLobbyButton

@onready var host_invite_code_input: LineEdit = %HostInviteCodeInput
@onready var host_invite_code_copy_button: TextureButton = %HostInviteCodeCopyButton



@onready var client_join_code_input: LineEdit = %ClientJoinCodeInput
@onready var join_button: Button = %JoinButton

@onready var local_server_list: VBoxContainer = %LocalServerList
@onready var join_local_game_button: Button = %JoinLocalGameButton
@onready var refresh_local_server_list_button: Button = %RefreshLocalServerListButton

@export var server_list_item_scene: PackedScene


var is_local: bool = false
var lobby_type: NetworkManager.LobbyType = NetworkManager.LobbyType.FRIENDS_ONLY
var tween: Tween = null

enum {
	CREATE,
	JOIN
}

func _ready() -> void:
	go_back_button.pressed.connect(_on_back_button_pressed)
	create_lobby_tab.button_down.connect(_on_create_lobby_tab_pressed)
	join_lobby_tab.button_down.connect(_on_join_lobby_tab_pressed)
	create_lobby_button.pressed.connect(_on_create_lobby_button_pressed)
	steam_checkbox.pressed.connect(func() -> void: is_local = false)
	local_host_checkbox.pressed.connect(func() -> void: is_local = true)
	private_checkbox.pressed.connect(func() -> void: lobby_type = NetworkManager.LobbyType.PRIVATE)
	friends_checkbox.pressed.connect(func() -> void: lobby_type = NetworkManager.LobbyType.FRIENDS_ONLY)
	send_invite_button.pressed.connect(_on_send_invite_button_pressed)
	host_invite_code_copy_button.button_down.connect(_on_host_invite_code_copy_button_pressed)
	
	join_button.pressed.connect(_on_join_button_pressed)
	client_join_code_input.gui_input.connect(_on_client_join_code_input_gui_input)
	close_lobby_button.pressed.connect(_on_close_lobby_button_pressed)
	
	join_local_game_button.pressed.connect(_on_join_local_game_button_pressed)
	refresh_local_server_list_button.pressed.connect(_on_refresh_local_server_list_button_pressed)
	join_lobby_tab.modulate.a = 0.5
	await get_tree().process_frame
	move_lines(CREATE)
	SteamManager.lobby_created.connect(_on_steam_lobby_created)
	SteamManager.lobby_joined.connect(_on_steam_lobby_joined)
	

	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	await get_tree().process_frame
	move_lines(CREATE)
	if NetworkManager.current_connection_type == NetworkManager.ConnectionType.LOCAL_HOST:
		disable_invite_section()
		client_join_code_input.text = ""
	if !local_server_list.get_child_count():
		join_local_game_button.disabled = true
	
func _on_back_button_pressed() -> void:
	back_button_pressed.emit()
	join_lobby_container.hide()
	create_lobby_container.show()
	move_lines(CREATE)
	join_lobby_tab.modulate.a = 0.5
	create_lobby_tab.modulate.a = 1.0
	

func _on_create_lobby_tab_pressed() -> void:
	create_lobby_container.show()
	join_lobby_container.hide()
	move_lines(CREATE)
	join_lobby_tab.modulate.a = 0.5
	create_lobby_tab.modulate.a = 1.0

func _on_join_lobby_tab_pressed() -> void:
	create_lobby_container.hide()
	join_lobby_container.show()
	move_lines(JOIN)
	join_lobby_tab.modulate.a = 1.0
	create_lobby_tab.modulate.a = 0.5
	

func move_lines(to: int) -> void:
	var button: Button = create_lobby_tab if to == CREATE else join_lobby_tab
	
	left_line.position.x = button.global_position.x + 1.0 - left_line.size.x
	right_line.position.x = button.global_position.x + button.size.x - 1.0
	
	left_line.position.y = button.global_position.y + button.size.y - left_line.size.y
	right_line.position.y = button.global_position.y + button.size.y - right_line.size.y


func enable_invite_section() -> void:
	invite_section.modulate.a = 1.0
	host_invite_code_copy_button.disabled = false
	close_lobby_button.disabled = false
	
	if lobby_type != NetworkManager.LobbyType.PRIVATE:
		send_invite_button.disabled = false



func disable_invite_section() -> void:
	invite_section.modulate.a = 0.4
	host_invite_code_copy_button.disabled = true
	send_invite_button.disabled = true
	close_lobby_button.disabled = true
	host_invite_code_input.text = ""



func _on_create_lobby_button_pressed() -> void:
	if is_local:
		await NetworkManager.switch_connection_type(NetworkManager.ConnectionType.LOCAL_HOST)
		NetworkManager.start_broadcast()
	else:
		var result: Dictionary = NetworkManager.enable_multiplayer()
		if result.status == 0:
			await NetworkManager.switch_connection_type(NetworkManager.ConnectionType.MULTIPLAYER_HOST)
			SteamManager.create_lobby(lobby_type, int(max_players_select.get_item_text(max_players_select.selected)))
			return
		elif result.status == 2:
			create_toast_popup("Seems like Steam is probably not running...", true)
			return
		else:
			create_toast_popup(result.verbal, true)
			return
		

func _on_close_lobby_button_pressed() -> void:
	await NetworkManager.switch_connection_type(NetworkManager.ConnectionType.LOCAL_HOST)
	create_toast_popup("Lobby was closed", false, "Closed!")
	disable_invite_section()

# DISABLE INVITE SECTION WHEN IS IN LOCAL
func _on_steam_lobby_created(response: int, lobby_id: int) -> void:
	if response == 1:
		enable_invite_section()
		create_toast_popup("Created lobby successfully!")
		host_invite_code_input.text = str(lobby_id)


func _on_steam_lobby_joined() -> void:
	create_toast_popup("Successfully joined a lobby!")
	


func _on_send_invite_button_pressed() -> void:
	SteamManager.create_friends_popup()





func _on_host_invite_code_copy_button_pressed() -> void:
	DisplayServer.clipboard_set(host_invite_code_input.text)
	create_toast_popup("Coppied the invite code to clipboard!")
	


func _on_join_button_pressed() -> void:
	if !SteamManager.is_steam_enabled:
		create_toast_popup("Steam has to be running for this to work...", true, "Nice try")
		return
	var result: Dictionary = await SteamManager.join_lobby(client_join_code_input.text)
	if result.status == 0:
		return
	elif result.status == 3:
		create_toast_popup(result.verbal, true, "Feels so lonely here...")
	else:
		create_toast_popup(result.verbal, true, "Not so fast!")




func _on_client_join_code_input_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
			client_join_code_input.text = DisplayServer.clipboard_get()
			create_toast_popup("Pasted lobby id", false, "Pasted")
			


func _on_join_local_game_button_pressed() -> void:
	await NetworkManager.switch_connection_type(NetworkManager.ConnectionType.LOCAL_CLIENT)


func create_toast_popup(message: String, is_error: bool = false, title: String = "") -> void:
	EventBus.ui.toast_popup_requested.emit(message, is_error, title)


func _on_refresh_local_server_list_button_pressed() -> void:
	await _refresh_local_server_list()


func _refresh_local_server_list() -> void:
	refresh_local_server_list_button.disabled = true
	while local_server_list.get_child_count():
		var i: ServerListItem = local_server_list.get_child(-1)
		local_server_list.remove_child(i)
		i.queue_free()
	
	var server_ports: Array[int] = await NetworkManager.get_local_servers()
	
	for i in server_ports:
		var server_list_item: ServerListItem = server_list_item_scene.instantiate()
		server_list_item.server_name = "Local server " + str(i)
		server_list_item.port = i
		local_server_list.add_child(server_list_item)
	
	if server_ports.size():
		join_local_game_button.disabled = false
	refresh_local_server_list_button.disabled = false
		
	
	
