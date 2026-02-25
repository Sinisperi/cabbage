class_name Chunk extends Node3D

var chunk_data: Dictionary = {
	"entities": []
}

func display_name() -> void:
	$Label3D.text = name

func load() -> void:
	get_child(0).material.albedo_color = Color.RED
	
	
func unload() -> void:
	get_child(0).material.albedo_color = Color.WHITE
