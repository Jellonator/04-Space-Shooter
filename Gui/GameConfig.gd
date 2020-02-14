extends Control

func _ready():
	var value = GameConfig.get_config_value("mouse_enabled")
	set_mouse_use(value)
	$VBoxContainer/CenterContainer/CheckButton.pressed = value

func set_mouse_use(value: bool):
	GameConfig.set_config_value("mouse_enabled", value)
	if value:
		$VBoxContainer/InputsMouse.show()
		$VBoxContainer/InputsNonMouse.hide()
	else:
		$VBoxContainer/InputsMouse.hide()
		$VBoxContainer/InputsNonMouse.show()

func _on_CheckButton_toggled(button_pressed: bool):
	set_mouse_use(button_pressed)
