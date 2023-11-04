extends Node2D

@onready var ui_controller: UIController = $CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	PlayerInventory.item_added.connect(on_player_inventory_item_added)
	PlayerInventory.item_removed.connect(on_player_inventory_item_removed)


func on_player_inventory_item_added(item_id: ItemData.ItemId):
	ui_controller.add_item(item_id)

func on_player_inventory_item_removed(item_id: ItemData.ItemId):
	ui_controller.remove_item(item_id)
