@tool
extends Node3D
class_name InteractableItem


signal interacted
signal unlocked
signal toggled(val: bool)

## The kind of interactable item this is (what happens when the player interacts with it)
@export var type: Type = Type.Key : set = set_type
@export var has_collision: bool = true

@onready var collision_shape_3d = $MeshInstance3D/StaticBody3D/CollisionShape3D


@export var _key_id: ItemData.ItemId
@export var _dialog_id: DialogData.DialogId

@export var _required_key: ItemData.ItemId

@export var _toggled_on: bool

enum Type {
	Key,
	Alter,
	InstantButton,
	ToggleButton,
	Dialog,
	HidingPlace
}

func set_type(val):
	type = val
	notify_property_list_changed()

func _ready():
	collision_shape_3d.disabled = !has_collision

func interact():
	# TODO: Fill this in as needed
	match type:
		Type.Key:
			PlayerInventory.add_item(_key_id)
			var data = ItemData.data[_key_id]
#			DialogManager.play_dialog(DialogData.DialogId.PickupDialog, [data["name"]])
			queue_free()
			print("Key Item Interacted!")
		Type.Alter:
			if PlayerInventory.has_item(_required_key):
				PlayerInventory.remove_item(_required_key)
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
#			DialogManager.play_dialog(_dialog_id)
			queue_free()
			print("Key Item Interacted!")
#		Type.HidingPlace: 
# TODO: Re-enable hiding
#			print("In Hiding Spot")
#			var players = get_tree().get_nodes_in_group("player")
#			var player = players[0]
#			if player.mode == Player.Mode.Hidden:
#				DialogManager.play_dialog(dialog_id)
#				player.mode = Player.Mode.Normal
#				player.visible = true
#			elif player.mode == Player.Mode.Normal:
#				DialogManager.play_dialog(dialog_id)
#				player.visible = false
#				player.mode = Player.Mode.Hidden

func _on_interaction_area_area_entered(area):
	EventManager.publish(EventManager.EventId.ShowInteractionPrompt, self)


func _on_interaction_area_area_exited(area):
	EventManager.publish(EventManager.EventId.HideInteractionPrompt)
