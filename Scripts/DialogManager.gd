extends Node

signal dialog_played(id: DialogData.DialogId, params: Array[String])
signal dialog_finished

var current_dialog

func play_dialog(id: DialogData.DialogId, params: Array[String] = []):
	current_dialog = id
	dialog_played.emit(id, params)
	get_tree().paused = true

func finish_dialog():
	current_dialog = null
	dialog_finished.emit()
	get_tree().paused = false
