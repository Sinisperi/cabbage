extends Control

@onready var confirm_button: Button = %ConfirmButton
@onready var character_name_input: LineEdit = %CharacterNameInput

func _ready() -> void:
	confirm_button.pressed.connect(_on_confirm_button_pressed)

func _on_confirm_button_pressed() -> void:
	var username: String = character_name_input.text
	SceneLoader.load_scene(SceneLoader.Scene.WORLD_SCENE, func(world: World) -> void: world._request_player_spawn.rpc_id(1, username))
