extends Node3D
class_name InteractableItem


signal interacted
signal unlocked
signal toggled(val: bool)

## The kind of interactable item this is (what happens when the player interacts with it)
@export var type: Type = Type.Key : set = set_type
@export var has_collision: bool = true

@onready var collision_shape_3d = $MeshInstance3D/StaticBody3D/CollisionShape3D
@onready var animation_player = $AnimationPlayer
@onready var interaction_area = $InteractionArea


@export var _key_id: ItemData.ItemId
@export var _dialog_id: DialogData.DialogId
@export var _one_time_dialog: bool


@export var _required_key: ItemData.ItemId

@export var _toggled_on: bool


@export var required_alter: InteractableItem

@export_file("*.tscn", "*.scn") var destination_scene := "" 

var dialog_triggered: bool = false

var saved: bool = false
var broken: bool = false


var alter_unlocked: bool = false
var trans_door_can_open: bool = false

enum Type {
	Key,
	Alter,
	InstantButton,
	ToggleButton,
	Dialog,
	HidingPlace,
	SceneTransitionDoor,
	Breakable,
}


func get_interaction_area_global_pos():
	return interaction_area.global_position

func set_type(val):
	type = val


func _ready():
	collision_shape_3d.disabled = !has_collision
	if Type.SceneTransitionDoor == type:
		required_alter.unlocked.connect(on_alter_unlocked)

func on_alter_unlocked():
	trans_door_can_open = true

func interact():
	# TODO: Fill this in as needed
	match type:
		Type.Key:
			PlayerInventory.add_item(_key_id)
			var data = ItemData.data[_key_id]
			DialogManager.play_dialog(DialogData.DialogId.PickupDialog, [data["name"]])
			queue_free()
			
			if !saved:
				saved = true
				#GameStateService.save_data_to_default_path()
			print("Key Item Interacted!")
		Type.Alter:
			if PlayerInventory.has_item(_required_key):
				PlayerInventory.remove_item(_required_key)
				alter_unlocked = true
				unlocked.emit()
			print("Lock Interacted")
		Type.InstantButton:
			interacted.emit()
			print("Button Interacted!")
		Type.ToggleButton:
			_toggled_on = !_toggled_on
			toggled.emit(_toggled_on)
			print("Toggle Button Interacted!")
		Type.Dialog:
			DialogManager.play_dialog(_dialog_id)
			dialog_triggered = true
			print("Dialog Interacted!")
		Type.HidingPlace:
			print("In Hiding Spot")
			var players = get_tree().get_nodes_in_group("player")
			var player = players[0]
			player.hide_inside_object(self)
		Type.SceneTransitionDoor:
			if trans_door_can_open:
				GameStateService.set_global_state_value(Room.ENTERING_ROOM_FROM_SCENE_STATE_KEY, get_owner().scene_file_path)
				TransitionMgr.transition_to(destination_scene)
		Type.Breakable:
			if !broken && PlayerInventory.has_item(ItemData.ItemId.Chisel):
				explode()

func explode():
	broken = true
	get_tree().get_first_node_in_group("player").playrockbreak()
	animation_player.play("break")

func can_interact() -> bool:
	match type:
		Type.Dialog:
			return !_one_time_dialog || !dialog_triggered
		Type.Breakable:
			return PlayerInventory.has_item(ItemData.ItemId.Chisel) and !broken
		_:
			return true

func get_player_spawn_point():
	return $PlayerSpawnPoint

func _on_game_state_helper_loading_data(data):
	if type == Type.Key && saved:
		queue_free()
	if type == Type.Breakable && broken:
		explode()
