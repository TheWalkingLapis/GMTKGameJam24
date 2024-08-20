extends CanvasLayer

signal game_start
signal settings

func _ready():
	$AnimatedSprite2D.play()
	
func _on_start_button_pressed():
	game_start.emit()


func _on_settings_button_pressed():
	settings.emit()
