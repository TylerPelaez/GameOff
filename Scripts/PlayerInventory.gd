extends Node

signal item_added(id: ItemData.ItemId)
signal item_removed(id: ItemData.ItemId)

var items: Dictionary = {}

func add_item(id: ItemData.ItemId):
	items[id] = true
	item_added.emit(id)

func remove_item(id: ItemData.ItemId):
	items.erase(id)
	item_removed.emit(id)

func has_item(id: ItemData.ItemId) -> bool:
	return items.has(id)
