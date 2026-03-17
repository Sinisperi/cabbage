class_name ServerListItem extends PanelContainer

signal selected(list_item: ServerListItem)

@onready var local_server_name_label: Label = %LocalServerNameLabel
@onready var local_server_port_label: Label = %LocalServerPortLabel


var server_name: String = ""
var port: int = -1
var tween: Tween = null

func _ready() -> void:
	local_server_name_label.text = server_name
	local_server_port_label.text = str(port)
	gui_input.connect(_on_gui_input)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.is_pressed():
			selected.emit(self)


func highlight() -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "self_modulate", Color.WHITE * 1.4, 0.2)
	tween.custom_step(0.1)
	

func unhighlight() -> void:
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "self_modulate", Color.WHITE, 0.05)
