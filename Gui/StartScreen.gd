extends Control

func _ready():
	$Panel/VBox/Center/Play.grab_focus()

func _on_Button_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://World/Game.tscn")
