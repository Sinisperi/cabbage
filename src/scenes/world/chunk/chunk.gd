class_name Chunk extends Node3D

@onready var chunk_data: Dictionary = {
	"entities": [],
	"position": {
		"x": global_position.x,
		"y": global_position.z
	}
}

func display_name() -> void:
	$Label3D.text = name

func load() -> void:
	get_child(0).material.albedo_color = Color.RED
	
	
func unload() -> void:
	get_child(0).material.albedo_color = Color.WHITE
