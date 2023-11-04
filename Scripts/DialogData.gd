extends Node
class_name DialogData

# For each dialog, a unique name should be in this enum, with an associated entry in data
enum DialogId {
	TestDialog,
	PickupDialog
}

static var data = {
	DialogId.TestDialog: ["This is a test", "ligma"],
	DialogId.PickupDialog: ["You picked up %s."]
}
