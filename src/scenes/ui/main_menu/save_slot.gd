class_name SaveSlot extends PanelContainer

signal selected(slot: SaveSlot)
signal delete_requested(slot: SaveSlot)

@onready var last_played: Label = %LastPlayed
@onready var save_slot_title: Label = %SaveSlotTitle
@onready var delete_button: Button = %DeleteButton

var save_name: String = ""
var last_time_played: String = ""
var tween: Tween = null


func _ready() -> void:
	last_played.text = last_time_played
	save_slot_title.text = save_name
	gui_input.connect(_on_gui_input)
	delete_button.pressed.connect(func() -> void: delete_requested.emit(self))


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
			selected.emit(self)


func highlight() -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "self_modulate", Color.WHITE * 1.4, 0.2)
	tween.parallel()
	tween.tween_property(delete_button, "modulate:a", 1.0, 0.2)
	tween.tween_callback(func() -> void: delete_button.disabled = false)
	

func unhighlight() -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "self_modulate", Color.WHITE, 0.05)
	tween.parallel()
	tween.tween_property(delete_button, "modulate:a", 0.0, 0.05)
	tween.tween_callback(func() -> void: delete_button.disabled = true)
