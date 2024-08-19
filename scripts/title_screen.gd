extends CanvasLayer

signal game_start
signal toggle_fullscreen
signal toggle_music
signal set_music_volume(dB: float)

func _on_start_button_pressed():
	game_start.emit()
