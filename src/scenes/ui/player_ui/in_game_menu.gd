class_name InGameMenu extends Control

@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var save_game_button: Button = %SaveGameButton
@onready var quit_button: Button = %QuitButton


signal continue_button_pressed


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_button_pressed)
	save_game_button.pressed.connect(_on_save_game_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_continue_button_pressed() -> void:
	continue_button_pressed.emit()


func _on_save_game_button_pressed() -> void:
	SaveDataManager.save_game()


func _on_quit_button_pressed() -> void:
	SteamManager.disconnect_from_current_session()
	EventBus.ui.main_menu_requested.emit()
	Globals.world.queue_free()
	Globals.world = null
