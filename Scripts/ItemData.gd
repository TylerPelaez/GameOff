extends Node
class_name ItemData

# For each key item, a unique name should be in this enum, with an associated entry in data
enum ItemId {
	TestItem,
	TestItem2,
	Chisel
}


static var data = {
	ItemId.TestItem: {
		"icon": preload("res://Art/Test/White32.png"),
		"name": "Blue Feather"
	},
	ItemId.TestItem2: {
		"icon": preload("res://Art/Test/White32.png"),
		"name": "Rotting Heart"
	},
	ItemId.Chisel: {
		"icon": preload("res://Art/Test/White32.png"),
		"name": "Chisel",
		"tool": true
	}
}
