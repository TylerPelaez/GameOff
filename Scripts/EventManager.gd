extends Node


signal show_interaction_prompt(interactable: InteractableItem)
signal hide_interaction_prompt



enum EventId {
	ShowInteractionPrompt, # Args: Node2D
	HideInteractionPrompt, # No Args
}

var subscriptions = { 
	EventId.ShowInteractionPrompt: show_interaction_prompt,
	EventId.HideInteractionPrompt: hide_interaction_prompt,
}

func subscribe(id: EventId, callback: Callable):
	if !subscriptions.has(id):
		push_error("Missing Id: %s" % id)
	
	subscriptions[id].connect(callback)

func publish(id: EventId, args = null):
	if args != null:
		subscriptions[id].emit(args)
	else:
		subscriptions[id].emit()
