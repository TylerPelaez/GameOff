extends Node
class_name DialogData

# For each dialog, a unique name should be in this enum, with an associated entry in data
enum DialogId {
	TestDialog,
}

static var data = {
	DialogId.TestDialog: ["This is a test", "ligma"]
}
