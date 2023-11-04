extends Node2D
class_name InteractableItem

@export var type: Type = Type.Dialog

enum Type {
	KeyItem,
	InstantButton,
	ToggleButton,
	Dialog
}

func interact():
	# TODO: Fill this out!
	match type:
		Type.KeyItem:
			print("Key Item Interacted!")
		Type.InstantButton:
			print("Button Interacted!")
		Type.ToggleButton:
			print("Toggle Button Interacted!")
		Type.Dialog:
			print("Dialog Interacted!")
