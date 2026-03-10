extends Control
@onready var go_back_button: Button = %GoBackButton
@onready var continue_button: Button = %ContinueButton
signal back_button_pressed


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_button_pressed)
	go_back_button.pressed.connect(_go_back_button_pressed)
	
	
func _on_continue_button_pressed() -> void:
	print_rich("You press continue button [color=yellow] but nothing happens![/color]")


func _go_back_button_pressed() -> void:
	back_button_pressed.emit()
