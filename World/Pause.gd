extends Control

onready var node_unpause = $Margin/Panel/VBox/Center/Unpause

func _ready():
	hide()

func _input(event):
	if event.is_action_pressed("game_pause") or event.is_action_pressed("game_force_pause"):
		get_tree().paused = not get_tree().paused
		if get_tree().paused:
			show()
			node_unpause.grab_focus()
		else:
			hide()

func _on_Unpause_pressed():
	get_tree().paused = false
	hide()
