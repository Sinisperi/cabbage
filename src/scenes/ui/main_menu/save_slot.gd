class_name SaveSlot extends PanelContainer
@onready var last_played: Label = %LastPlayed
@onready var save_slot_title: Label = %SaveSlotTitle

var save_name: String = ""
var last_time_played: String = ""

signal selected(slot_name: String)


func _ready() -> void:
	last_played.text = last_time_played
	save_slot_title.text = save_name
	gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
			selected.emit(save_name)
