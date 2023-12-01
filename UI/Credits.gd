extends CanvasLayer

var uri

func _on_defective_melon_pressed():
	OS.shell_open("https://defectivemelon.itch.io/")


func _on_loki_howell_studios_pressed():
	OS.shell_open("https://loki-howell-studios.itch.io/")


func _on_jpkinsella_pressed():
	OS.shell_open("https://itch.io/profile/jpkinsella")


func _on_lex_catto_pressed():
	OS.shell_open("https://lex-catto.itch.io/")


func _on_sugonugo_pressed():
	OS.shell_open("https://itch.io/profile/sugonugo")


func _on_the_jade_rose_pressed():
	OS.shell_open("https://itch.io/profile/thejaderose")


func _on_the_holy_noobness_pressed():
	OS.shell_open("https://itch.io/profile/the-holy-noobness")

func _on_music_pressed():
	OS.shell_open("")


func _on_back_pressed():
	get_tree().change_scene_to_file("res://UI/main_menu.tscn")
