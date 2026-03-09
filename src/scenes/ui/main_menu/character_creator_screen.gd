extends Control
@onready var go_back_button: Button = %GoBackButton
@onready var start_game_button: Button = %StartGameButton
@onready var character_name_line_edit: LineEdit = %CharacterNameLineEdit
@onready var character_name_error_label: RichTextLabel = %CharacterNameErrorLabel
@onready var tween: Tween = null


func _ready() -> void:
	character_name_error_label.modulate.a = 0.0
	
	go_back_button.pressed.connect(_on_back_button_pressed)
	start_game_button.pressed.connect(_on_start_game_button_pressed)
	character_name_line_edit.focus_entered.connect(_on_character_name_line_edit_focus_entered)

func _on_back_button_pressed() -> void:
	SceneLoader.go_back()


func _on_start_game_button_pressed() -> void:
	var display_name: String = character_name_line_edit.text
	if display_name.length() < 2:
		name_length_error()
		return
	SceneLoader.load_scene(SceneLoader.Scene.WORLD_SCENE, func(world: World) -> void: world._request_player_spawn.rpc_id(1, display_name))


func name_length_error() -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	var original_position: float = character_name_error_label.position.x
	tween.tween_property(character_name_error_label, "modulate:a", 1.0, 0.05)
	character_name_line_edit.position.x = -10
	tween.tween_property(character_name_line_edit, "position:x", original_position, 0.6)

	
func _on_character_name_line_edit_focus_entered() -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(character_name_error_label, "modulate:a", 0.0, 0.12)
	
