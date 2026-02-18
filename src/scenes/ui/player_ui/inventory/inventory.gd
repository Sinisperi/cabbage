class_name Inventory extends Control

@export_category("Inventory")
@export var inventory_size: int = 18
@export var inventory_items: Array[ItemData]
@export var inventory_grid: SlotsPanel


@export_category("Hot Bar")
@export var hot_bar_size: int = 4
@export var hot_bar_items: Array[ItemData]
@export var hot_bar_slots: SlotsPanel

@onready var inventory_container: HBoxContainer = $VBoxContainer/InventoryContainer


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			var draggable_item: DraggableItem = get_tree().get_first_node_in_group("draggable_item")
			if draggable_item:
				## TODO Spawn items on the ground ( throw them out with physics etc )
				print("dropped ", draggable_item.data.item_name)
				

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	inventory_grid.item_picked.connect(func(index: int) -> void: _remove_item(inventory_items, index))
	inventory_grid.item_placed.connect(func(index: int, item_data: ItemData) -> void:
		_add_item(inventory_items, index, item_data))
	
	hot_bar_slots.item_picked.connect(func(index: int) -> void: _remove_item(hot_bar_items, index))
	hot_bar_slots.item_placed.connect(func(index: int, item_data: ItemData) -> void:
		_add_item(hot_bar_items, index, item_data))
	
	inventory_grid.init_grid()
	hot_bar_slots.init_grid()
	
	inventory_items = _initialize_inventory(inventory_items, inventory_size)
	hot_bar_items = _initialize_inventory(hot_bar_items, hot_bar_size)

	inventory_grid.place_items(inventory_items)
	hot_bar_slots.place_items(hot_bar_items)
	
	
	_on_item_equipped(hot_bar_slots.get_selected_item())
	EventBus.item_equipped.connect(_on_item_equipped)

func _remove_item(from: Array[ItemData], index: int) -> void:
	from[index] = null


func _add_item(from: Array[ItemData], index: int, item_data: ItemData) -> void:
	from[index] = item_data
	

func _initialize_inventory(inventory: Array[ItemData], inv_size: int) -> Array[ItemData]:
	var empty_slots: int = inv_size - inventory.size()
	var new_array: Array[ItemData] = []
	new_array.resize(empty_slots)
	new_array.fill(null)
	inventory += new_array
	return inventory


func toggle_inventory(is_shown: bool) -> void:
	inventory_container.visible = is_shown


func _on_item_equipped(item_data: ItemData) -> void:
	if item_data:
		$VBoxContainer2/Label.text = item_data.item_name
		$VBoxContainer2/TextureRect.texture = item_data.texture
	else:
		$VBoxContainer2/Label.text = "Empty Hand"
		$VBoxContainer2/TextureRect.texture = null
