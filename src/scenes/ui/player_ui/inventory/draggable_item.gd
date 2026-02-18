class_name DraggableItem extends TextureRect

var data: ItemData = null

func _ready() -> void:
	if !data: return
	texture = data.texture



func _physics_process(_delta: float) -> void:
	global_position = get_global_mouse_position() - size / 2.0

func update() -> void:
	if !data: return
	texture = data.texture
