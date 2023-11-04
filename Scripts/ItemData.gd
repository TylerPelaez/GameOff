extends Node
class_name ItemData

# For each key item, a unique name should be in this enum, with an associated entry in data
enum ItemId {
	TestItem,
}

static var data = {
	ItemId.TestItem: {
		"icon": preload("res://Art/Test/White32.png"),
		"name": "Little Square Thing"
	}
}