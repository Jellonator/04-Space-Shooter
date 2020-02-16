extends Node2D

onready var node_score := $CanvasLayer/Control/Panel/VBoxContainer/Score

var score := 0

func _ready():
	$AnimationPlayer.play("kill")
	node_score.text = "Score: %d" % score

func _on_Button_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Gui/StartScreen.tscn")
