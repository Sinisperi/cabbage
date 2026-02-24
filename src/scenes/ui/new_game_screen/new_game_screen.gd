extends Control
@onready var confirm_button: Button = %ConfirmButton
@onready var online_checkbox: CheckBox = %OnlineCheckbox
@onready var player_name_line_edit: LineEdit = %PlayerNameLineEdit
@onready var to_main_menu_button: Button = %ToMainMenuButton


func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	to_main_menu_button.pressed.connect(_to_main_menu_button_pressed)
	

func _on_confirm_button_pressed() -> void:
	if online_checkbox.is_pressed():
		NetworkManager.enable_multiplayer(true)
		var status: Error = NetworkManager.host_game()
		if status != OK:
			print("Failed to host game with a status: ", status)
		# TODO in here somehow make a lobbby or something or send to a create lobby screen or pannel
		# where there will be an option to create a lobby, set amount of players and the visibility
		# and also get a code
		
		
	var username: String = player_name_line_edit.text ## this is going to be a steam username at some point

	SceneLoader.load_scene(SceneLoader.Scene.WORLD_SCENE, func(world: World) -> void: world._request_player_spawn.rpc_id(1, username))
	


func _to_main_menu_button_pressed() -> void:
	hide()
