extends Node2D
class_name InteractableItem

## The kind of interactable item this is (what happens when the player interacts with it)
@export var type: Type = Type.Dialog
@export var has_collision: bool = false

@export_group("Interactable Ids")
## If type is Dialog, the dialog Id to pop up when interaction occurs
@export var dialog_id: DialogData.DialogId 
## If type is a Key OR Lock item, the item id to give to/take from the player when interaction occurs
@export var item_id: ItemData.ItemId

@onready var collider = $StaticBody2D/CollisionShape2D



enum Type {
	KeyItem,
	LockItem,
	InstantButton,
	ToggleButton,
	Dialog,
	HidingPlace,
}

func _ready():
	collider.disabled = !has_collision

func interact():
	# TODO: Fill this in as needed
	match type:
		Type.KeyItem:
			PlayerInventory.add_item(item_id)
			var data = ItemData.data[item_id]
			DialogManager.play_dialog(DialogData.DialogId.PickupDialog, [data["name"]])
			queue_free()
			print("Key Item Interacted!")
		Type.LockItem:
			if PlayerInventory.has_item(item_id):
				print("Lock Removed")
				PlayerInventory.remove_item(item_id)
				queue_free()
			print("Lock Interacted")
		Type.InstantButton:
			print("Button Interacted!")
		Type.ToggleButton:
			print("Toggle Button Interacted!")
		Type.Dialog:
			DialogManager.play_dialog(dialog_id)
			queue_free()
			print("Key Item Interacted!")
		Type.HidingPlace: 
			print("Hiding Place Interacted!")
