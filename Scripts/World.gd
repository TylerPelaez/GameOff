extends Node3D
class_name Room

static var ENTERING_ROOM_FROM_SCENE_STATE_KEY = "entering_room_from_scene"

@onready var ui_controller: UIController = $CanvasLayer
@onready var player = $Player
@onready var camera_rig = $CameraRig

# Called when the node enters the scene tree for the first time.
func _ready():
	# wait for game state load to finish
	await GameStateService.state_load_completed
	
	PlayerInventory.item_added.connect(on_player_inventory_item_added)
	PlayerInventory.item_removed.connect(on_player_inventory_item_removed)
	
	DialogManager.dialog_played.connect(on_dialog_played)
	
	if player.remote_transform_3d.remote_path == null || player.remote_transform_3d.remote_path.is_empty():
		player.assign_camera_rig(camera_rig)
	
	
	var player_origin_scene = GameStateService.get_global_state_value(ENTERING_ROOM_FROM_SCENE_STATE_KEY)
	if player_origin_scene == null or player_origin_scene == "":
		return
	
	var player_spawn_position = null
	var transition_doors = get_tree().get_nodes_in_group("scene_transition_door")
	for trans_door in transition_doors:
		if trans_door.destination_scene == player_origin_scene:
			player_spawn_position = trans_door.get_player_spawn_point()
			break
	
	if player_spawn_position != null:
		player.global_position = player_spawn_position.global_position
		
	
	GameStateService.set_global_state_value(ENTERING_ROOM_FROM_SCENE_STATE_KEY, null)


func on_player_inventory_item_added(item_id: ItemData.ItemId):
	ui_controller.add_item(item_id)

func on_player_inventory_item_removed(item_id: ItemData.ItemId):
	ui_controller.remove_item(item_id)

func on_dialog_played(id: DialogData.DialogId, params: Array[String]):
	ui_controller.play_dialog(id, params)
