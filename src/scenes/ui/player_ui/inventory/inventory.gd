class_name Inventory extends Control

@export_category("Inventory")
@export var inventory_size: int = 16
@export var inventory_items: Array[ItemData]
@export var inventory_grid: SlotsPanel


@export_category("Hot Bar")
@export var hot_bar_size: int = 4
@export var hot_bar_items: Array[ItemData]
@export var hot_bar_slots: SlotsPanel

@export_category("Equipment")

@export var equipment_slots: EquipmentSlots

@onready var inventory_container: HBoxContainer = $VBoxContainer/InventoryContainer

enum InventoryType
{
	ITEM,
	HOT_BAR,
}

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			var draggable_item: DraggableItem = get_tree().get_first_node_in_group("draggable_item")
			if draggable_item:
				## TODO Spawn items on the ground ( throw them out with physics etc )
				printerr("NOT IMPLEMENTED: dropped ", draggable_item.data.item_name)
				

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.inventory = self
	inventory_grid.item_picked.connect(func(index: int) -> void: _remove_item.rpc_id(1, InventoryType.ITEM, index))
	inventory_grid.item_placed.connect(func(index: int, item_data: ItemData) -> void:
		_add_item.rpc_id(1, InventoryType.ITEM, index, item_data.to_dict()))
	
	hot_bar_slots.item_picked.connect(func(index: int) -> void: _remove_item.rpc_id(1, InventoryType.HOT_BAR, index))
	hot_bar_slots.item_placed.connect(func(index: int, item_data: ItemData) -> void:
		_add_item.rpc_id(1, InventoryType.HOT_BAR, index, item_data.to_dict()))
	
	inventory_grid.init_grid()
	hot_bar_slots.init_grid()
	

	
	_on_item_equipped(hot_bar_slots.get_selected_item())
	
	
	push_warning("Debug purposes")
	EventBus.inventory.hot_bar.rh_item_equipped.connect(_on_item_equipped)
	
	EventBus.inventory.item_pick_up_requested.connect(_on_item_picked_up)


@rpc("any_peer", "call_local")
func _remove_item(inventory_type: InventoryType, index: int) -> void:
	if multiplayer.is_server():
		var peer_id: int = multiplayer.get_remote_sender_id()
		print(peer_id, " remove item peer id")
		var player_id: String = PlayerManager.active_peers[peer_id if peer_id > 0 else 1]
		var player_inventory: InventoryData = PlayerManager.active_players[player_id].inventory
		var inventory_kind: Variant = null
		match inventory_type:
			InventoryType.ITEM:
				inventory_kind = player_inventory.inventory_items
			InventoryType.HOT_BAR:
				inventory_kind = player_inventory.hot_bar_items
		if !inventory_kind:
			print(inventory_kind)
			return
		inventory_kind[index] = null

@rpc("any_peer", "call_local")
func _add_item(inventory_type: InventoryType, index: int, item_data: Variant) -> void:
	if multiplayer.is_server():
		var peer_id: int = multiplayer.get_remote_sender_id()
		print(peer_id, " remove item peer id")
		var player_id: String = PlayerManager.active_peers[peer_id if peer_id > 0 else 1]
		var player_inventory: InventoryData = PlayerManager.active_players[player_id].inventory
		var inventory_kind: Variant = null
		match inventory_type:
			InventoryType.ITEM:
				inventory_kind = player_inventory.inventory_items
			InventoryType.HOT_BAR:
				inventory_kind = player_inventory.hot_bar_items
		if !inventory_kind:
			print(" no fricking inveneoty", inventory_kind)
			return
		
		if item_data != null:
			inventory_kind[index] = load(item_data.path)
		else:
			inventory_kind[index] = null
		print("peer_id ", peer_id, " ", " kind: ", inventory_kind, "\nactual ", player_inventory.inventory_items)
	

#func _initialize_inventory(inventory: Array[ItemData], inv_size: int) -> Array[ItemData]:
	#var empty_slots: int = inv_size - inventory.size()
	#var new_array: Array[ItemData] = []
	#new_array.resize(empty_slots)
	#new_array.fill(null)
	#inventory += new_array
	#return inventory


func toggle_inventory(is_shown: bool) -> void:
	inventory_container.visible = is_shown


func _on_item_equipped(item_data: ItemData) -> void:
	if item_data:
		$VBoxContainer2/Label.text = item_data.item_name
		$VBoxContainer2/TextureRect.texture = item_data.texture
	else:
		$VBoxContainer2/Label.text = "Empty Hand"
		$VBoxContainer2/TextureRect.texture = null


func _on_item_picked_up(item_data: ItemData) -> void:
	var item_index: int = -1
	
	for i in inventory_items.size():
		if !inventory_items[i]:
			inventory_items[i] = item_data
			item_index = i
			break
			
	if item_index < 0:
		print("no space, later will check item type and try to 
		add it to other slots maybe")
		return
		
	inventory_grid.add_item(item_data, item_index)
	
