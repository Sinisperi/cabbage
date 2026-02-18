extends Control
@onready var confirm_button: Button = %ConfirmButton
@onready var online_checkbox: CheckBox = %OnlineCheckbox
@onready var game_name_line_edit: LineEdit = %GameNameLineEdit

func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_button_pressed)
	
func _on_confirm_button_pressed() -> void:
	if online_checkbox.is_pressed():
		NetworkManager.enable_multiplayer(true)
		NetworkManager.host_game()
		# in here somehow make a lobbby or something or send to a create lobby screen or pannel
		# where there will be an option to create a lobby, set amount of players and the visibility
		# and also get a code
	SceneLoader.load_scene(SceneLoader.Scene.WORLD_SCENE, func(world: World) -> void: world._request_player_spawn.rpc_id(1))
	
