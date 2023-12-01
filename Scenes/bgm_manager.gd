extends AudioStreamPlayer
@onready var ambience = $Ambience


@export var music_normal: AudioStream
@export var music_scary: AudioStream
@export var music_odd: AudioStream

@export var ambience_freq_seconds: float = 15

var timer: SceneTreeTimer
# Called when the node enters the scene tree for the first time.
func _ready():
	start_ambience_timer()

func start_ambience_timer():
	timer = get_tree().create_timer(ambience_freq_seconds)
	
	timer.timeout.connect(play_ambience)

func play_ambience():
	if !ambience.playing:
		ambience.play()
		ambience.finished.connect(start_ambience_timer)

func play_normal():
	if stream == music_normal:
		return
	stop()
	stream = music_normal
	play()

func play_scary():
	if stream == music_scary:
		return
	stop()
	stream = music_scary
	play()
	
func play_odd():
	if stream == music_odd:
		return
	stop()
	stream = music_odd
	play()

func stop_all():
	stop()
	ambience.stop()
	timer.free()
