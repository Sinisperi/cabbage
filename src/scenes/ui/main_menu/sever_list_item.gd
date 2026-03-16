class_name ServerListItem extends PanelContainer
@onready var local_server_name_label: Label = %LocalServerNameLabel
@onready var local_server_port_label: Label = %LocalServerPortLabel


var server_name: String = ""
var port: int = -1

func _ready() -> void:
	local_server_name_label.text = server_name
	local_server_port_label.text = str(port)
