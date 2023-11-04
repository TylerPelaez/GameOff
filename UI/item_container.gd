extends MarginContainer
class_name ItemContainer

@onready var texture_rect: TextureRect = $TextureRect

var item_id: ItemData.ItemId

func set_item(id: ItemData.ItemId):
	texture_rect.texture = ItemData.data[item_id]["icon"]
	item_id = id
