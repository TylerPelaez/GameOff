extends Node3D
class_name Room

static var ENTERING_ROOM_FROM_SCENE_STATE_KEY = "entering_room_from_scene"

## Position to spawn player if they are not coming from another room (i.e. this is the very first room in the game)
@export var default_player_spawn_point: Node3D

@onready var ui_controller: UIController = $CanvasLayer
@onready var player_prefab = preload("res://Scenes/player3D.tscn")
@onready var camera_rig_prefab = preload("res://Scenes/camera_rig.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerInventory.item_added.connect(on_player_inventory_item_added)
	PlayerInventory.item_removed.connect(on_player_inventory_item_removed)
	
	DialogManager.dialog_played.connect(on_dialog_played)
	
	var player_origin_scene = GameStateService.get_global_state_value(ENTERING_ROOM_FROM_SCENE_STATE_KEY)
	var player_spawn_position = default_player_spawn_point
	if player_origin_scene != null and player_origin_scene != "":
		var transition_doors = get_tree().get_nodes_in_group("scene_transition_door")
		for trans_door in transition_doors:
			if trans_door.destination_scene == player_origin_scene:
				player_spawn_position = trans_door.get_player_spawn_point()
				break
	
	var player = player_prefab.instantiate()
	add_child(player)
	
	var camera_rig = camera_rig_prefab.instantiate()
	add_child(camera_rig)
	
	player.global_position = player_spawn_position.global_position
	player.assign_camera_rig(camera_rig)
	ui_controller.camera = camera_rig.camera_3d
	

func on_player_inventory_item_added(item_id: ItemData.ItemId):
	ui_controller.add_item(item_id)

func on_player_inventory_item_removed(item_id: ItemData.ItemId):
	ui_controller.remove_item(item_id)

func on_dialog_played(id: DialogData.DialogId, params: Array[String]):
	ui_controller.play_dialog(id, params)
