extends Area3D
class_name DangerZone

@export var hunt_type: HuntTypes
@export var danger_min_wait_time_seconds = 25.0
@export var danger_max_wait_time_seconds = 35.0

var hunt_occurred: bool = false

enum HuntTypes {
	Always,
	FirstTimeOnly
}

func set_hunt_ocurred(val: bool):
	hunt_occurred = val

func _on_body_entered(body):
	BgmManager.play_scary()
	EventManager.show_hunt_visuals.emit()

