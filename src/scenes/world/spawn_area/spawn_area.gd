class_name SpawnArea extends Area3D

@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func get_spawn_point() -> Vector2:
	var radius: float = collision_shape.shape.radius
	
	prints("global pos ", position, position.z - radius, position.z + radius, radius)
	return Vector2(randf_range(position.x - radius, position.x + radius), 
	randf_range(position.z - radius, position.z + radius))
