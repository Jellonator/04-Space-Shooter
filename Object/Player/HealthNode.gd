extends Node2D

func _ready():
	$No.hide()

func set_burning(value: bool):
	if value:
		$Yes.show()
		$No.hide()
	else:
		$Yes.hide()
		$No.show()
