class_name NetworkBridge extends Node
@onready var players: Node = %Players
@onready var item_drops: Node = %ItemDrops




func _ready() -> void:
	EventBus.ui.main_menu_requested.connect(_on_main_menu_requested)


func _on_main_menu_requested() -> void:
	while item_drops.get_child_count():
		var i: Node = item_drops.get_child(-1)
		item_drops.remove_child(i)
		i.queue_free()
		print("delteting item")
	
	while players.get_child_count():
		var i: Node = players.get_child(-1)
		players.remove_child(i)
		i.queue_free()
		print("deleting player")
