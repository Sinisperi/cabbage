extends Control


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

@onready var host_invite_code_input: LineEdit = %HostInviteCodeInput
@onready var host_invite_code_copy_button: TextureButton = %HostInviteCodeCopyButton




@onready var client_join_code_input: LineEdit = %ClientJoinCodeInput
@onready var join_button: Button = %JoinButton

var is_local: bool = false
var lobby_type: Steam.LobbyType = Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY
var tween: Tween = null
signal back_button_pressed

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
	private_checkbox.pressed.connect(func() -> void: lobby_type = Steam.LobbyType.LOBBY_TYPE_PRIVATE)
	friends_checkbox.pressed.connect(func() -> void: lobby_type = Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY)
	send_invite_button.pressed.connect(_on_send_invite_button_pressed)
	host_invite_code_copy_button.button_down.connect(_on_host_invite_code_copy_button_pressed)
	
	join_button.pressed.connect(_on_join_button_pressed)
	client_join_code_input.gui_input.connect(_on_client_join_code_input_gui_input)
	join_lobby_tab.modulate.a = 0.5
	await get_tree().process_frame
	move_lines(CREATE)
	visibility_changed.connect(func() -> void: await get_tree().process_frame; move_lines(CREATE))
	SteamManager.lobby_created.connect(_on_steam_lobby_created)
	SteamManager.lobby_joined.connect(_on_steam_lobby_joined)
	
	
	
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
	if lobby_type != Steam.LobbyType.LOBBY_TYPE_PRIVATE:
		send_invite_button.disabled = false



func _on_create_lobby_button_pressed() -> void:
	if is_local:
		NetworkManager.switch_connection_type(NetworkManager.ConnectionType.LOCAL)
	else:
		var result: Dictionary = NetworkManager.enable_multiplayer()
		NetworkManager.switch_connection_type(NetworkManager.ConnectionType.MULTIPLAYER_HOST)
		
		if result.status == 0:
			SteamManager.create_lobby(lobby_type, int(max_players_select.get_item_text(max_players_select.selected)))
			return
		elif result.status == 2:
			create_toast_popup("Seems like Steam is probably not running...", true)
			return
		else:
			create_toast_popup(result.verbal, true)
			return
		



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
	NetworkManager.switch_connection_type(NetworkManager.ConnectionType.MULTIPLAYER_CLIENT)
	var result: Dictionary = await SteamManager.join_lobby(client_join_code_input.text)
	if result.status == 0:
		#SteamManager.join_lobby(int(client_join_code_input.text))
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
			

func create_toast_popup(message: String, is_error: bool = false, title: String = "") -> void:
	EventBus.ui.toast_popup_requested.emit(message, is_error, title)
