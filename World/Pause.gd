extends Control

func _ready():
	hide()

func _input(event):
	if event.is_action_pressed("game_pause") or event.is_action_pressed("game_force_pause"):
		get_tree().paused = not get_tree().paused
		if get_tree().paused:
			show()
		else:
			hide()
