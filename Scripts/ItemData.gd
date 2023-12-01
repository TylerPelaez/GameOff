extends Node
class_name ItemData

# For each key item, a unique name should be in this enum, with an associated entry in data
enum ItemId {
	HeartRoom1,
	HeartRoom2,
	HeartRoom3,
	HeartRoom4,
	HeartRoom5,
	HeartRoom6,
	Chisel
}


static var data = {
	ItemId.HeartRoom1: {
		"icon": preload("res://Art/heart0024.png"),
		"name": "Energetic Heart"
	},
	ItemId.HeartRoom2: {
		"icon": preload("res://Art/heart0024.png"),
		"name": "Nervous Heart"
	},
		ItemId.HeartRoom3: {
		"icon": preload("res://Art/heart0024.png"),
		"name": "Quiet Heart"
	},
		ItemId.HeartRoom4: {
		"icon": preload("res://Art/heart0024.png"),
		"name": "Bestial Heart"
	},
		ItemId.HeartRoom5: {
		"icon": preload("res://Art/heart0024.png"),
		"name": "Anticipatory Heart"
	},
	ItemId.HeartRoom6: {
		"icon": preload("res://Art/heart0024.png"),
		"name": "RUNRUNRUNRUNRUNRUNRUNRUNRUNRUNRUNRUNRUNRUNRUNRUNRUNRUNRUNRUNRUNRUN"
	},
	
	ItemId.Chisel: {
		"icon": preload("res://Art/chisel.png"),
		"name": "Chisel",
		"tool": true
	}
}
