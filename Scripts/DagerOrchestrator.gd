extends Node

@export var danger_kill_time_seconds = 10.0

var current_danger_zone: DangerZone
var player: Player3D
var current_timer: Timer

func set_current_danger_zone(zone: DangerZone, player: Player3D):
	self.current_danger_zone = zone
	self.player = player
	if danger_is_possible(current_danger_zone):
		var danger_wait_period = randf_range(current_danger_zone.danger_min_wait_time_seconds, current_danger_zone.danger_max_wait_time_seconds)
		current_timer = Timer.new()
		add_child(current_timer)
		current_timer.one_shot = true
		current_timer.wait_time = danger_wait_period
		current_timer.timeout.connect(on_danger_wait_period_ended)
		current_timer.start()

func on_danger_wait_period_ended():
	current_timer.queue_free()
	EventManager.show_hunt_visuals.emit()
	current_danger_zone.set_hunt_ocurred(true)
	current_timer = Timer.new()
	add_child(current_timer)
	current_timer.one_shot = true
	current_timer.wait_time = danger_kill_time_seconds
	current_timer.timeout.connect(on_danger_kill_period_ended)
	current_timer.start()

func on_danger_kill_period_ended():
	EventManager.stop_hunt_visuals.emit()
	print("boo")
	if !player.is_hidden():
		player.die()
	else:
		set_current_danger_zone(current_danger_zone, player)

func danger_is_possible(zone: DangerZone) -> bool:
	return zone.hunt_type == DangerZone.HuntTypes.Always || !zone.hunt_occurred

func set_danger_zone_escaped(zone):
	if zone == current_danger_zone:
		current_danger_zone = null
		current_timer.queue_free()
		EventManager.stop_hunt_visuals.emit()

