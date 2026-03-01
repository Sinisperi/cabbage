@tool
class_name ItemDrop extends BaseItem


func _ready() -> void:
	await super._ready()
	

@rpc("any_peer", "call_local")
func destroy_itself() -> void:
	if multiplayer.is_server():
		queue_free()
