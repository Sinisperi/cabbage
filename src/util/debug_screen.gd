class_name DebugScreen extends Control
@onready var fps: Label = %Fps
@onready var peer_id: Label = %PeerId
@onready var coords: Label = %Coords
@onready var chunk: Label = %Chunk
@onready var region: Label = %Region
@onready var loaded_regions: Label = %LoadedRegions

func _ready() -> void:
	peer_id.text = str(multiplayer.get_unique_id())

func _physics_process(_delta: float) -> void:
	fps.text = str(Engine.get_frames_per_second())
	coords.text = str(Globals.player.global_position if Globals.player else Vector3(0.0, 0.0, 0.0))
	chunk.text = str(Globals.chunker.current_chunk)
	region.text = str(Globals.chunker.get_current_region())
	loaded_regions.text = str(Globals.chunker.loaded_region_ids.keys())
