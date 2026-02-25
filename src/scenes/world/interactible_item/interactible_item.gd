class_name InteractibleItem extends Area3D

signal interacted_with
signal being_looked_at
 ## Is used for gatherable stuff, also things you throw on the ground from your inventory
## Also when something gets destroyed, like trees etc.
@export var data: ItemData = null

func interaction_ray_entered() -> void:
	return


## returns wether item was destroyed upon interaction or not
func being_interacted_with() -> bool:
	return true

func generate_entity_data() -> Dictionary:
	return {
		"item_data": data.to_dict(),
		"position": {
			"x": global_position.x,
			"y": global_position.y,
			"z": global_position.z,
		},
		"rotation": {
			"x": rotation.x,
			"y": rotation.y,
			"z": rotation.z
		}
		
	}
