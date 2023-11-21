extends Node2D

@onready var ui_controller: UIController = $CanvasLayer

var paused_before_unfocused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerInventory.item_added.connect(on_player_inventory_item_added)
	PlayerInventory.item_removed.connect(on_player_inventory_item_removed)
	
	DialogManager.dialog_played.connect(on_dialog_played)

func on_player_inventory_item_added(item_id: ItemData.ItemId):
	ui_controller.add_item(item_id)

func on_player_inventory_item_removed(item_id: ItemData.ItemId):
	ui_controller.remove_item(item_id)

func on_dialog_played(id: DialogData.DialogId, params: Array[String]):
	ui_controller.play_dialog(id, params)

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
			paused_before_unfocused = get_tree().paused
			get_tree().paused = true
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
			get_tree().paused = paused_before_unfocused
