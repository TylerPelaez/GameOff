extends CanvasLayer
class_name UIController

@onready var item_inventory = $ItemInventory

var item_container_prefab = preload("res://UI/item_container.tscn")

func add_item(item_id: ItemData.ItemId):
	var instance = item_container_prefab.instantiate()
	item_inventory.add_child(instance)
	instance.set_item(item_id)
	
func remove_item(item_id: ItemData.ItemId):
	for child in item_inventory.get_children():
		if child.item_id == item_id:
			child.queue_free()
			return
