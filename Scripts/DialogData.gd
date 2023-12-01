extends Node
class_name DialogData

# For each dialog, a unique name should be in this enum, with an associated entry in data
enum DialogId {
	PickupDialog,
	Room1,
	Room2,
	Room3,
	Room4,
	Room5,
	Room6,
}

static var data = {
	DialogId.PickupDialog: "res://Dialog/pickup.json",
	DialogId.Room1: "res://Dialog/room1.json",
	DialogId.Room2: "res://Dialog/room2.json",
	DialogId.Room3: "res://Dialog/room3.json",
	DialogId.Room4: "res://Dialog/room4.json",
	DialogId.Room5: "res://Dialog/room5.json",
	DialogId.Room6: "res://Dialog/room6.json",
}
