class_name InteractionArea extends Area3D

signal interacted_with
signal being_looked_at
 ## Is used for gatherable stuff, also things you throw on the ground from your inventory
## Also when something gets destroyed, like trees etc.

func interaction_ray_entered() -> void:
	being_looked_at.emit()


func being_interacted_with() -> void:
	interacted_with.emit()
