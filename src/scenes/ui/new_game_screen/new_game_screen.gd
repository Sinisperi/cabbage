extends Control
@onready var continue_button: Button = %ContinueButton
@onready var online_checkbox: CheckBox = %OnlineCheckbox
@onready var world_name_line_edit: LineEdit = %WorldNameLineEdit
@onready var go_back_button: Button = %GoBackButton


signal back_button_pressed

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_button_pressed)
	go_back_button.pressed.connect(_go_back_button_pressed)
	

func _on_continue_button_pressed() -> void:
	if multiplayer.is_server():
		SaveDataManager.create_save_slot(world_name_line_edit.text)
		load_character_creator.rpc()
		
		
		
	#if online_checkbox.is_pressed():
		#NetworkManager.enable_multiplayer(true)
		#var status: Error = NetworkManager.host_game()
		#if status != OK:
			#print("Failed to host game with a status: ", status)
			
		## TODO in here somehow make a lobbby or something or send to a create lobby screen or pannel
		## where there will be an option to create a lobby, set amount of players and the visibility
		## and also get a code
		#
		#
	#var username: String = world_name_line_edit.text ## this is going to be a steam username at some point
#
	#SceneLoader.load_scene(SceneLoader.Scene.WORLD_SCENE, func(world: World) -> void: world._request_player_spawn.rpc_id(1, username))
	


func _go_back_button_pressed() -> void:
	back_button_pressed.emit()

@rpc("any_peer", "call_local")
func load_character_creator() -> void:
	SceneLoader.load_scene(SceneLoader.Scene.CHARACTER_CREATOR)
