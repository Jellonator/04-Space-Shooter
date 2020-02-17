extends HBoxContainer

export var input_name := ""

onready var node_label := $Label
onready var node_btn := $Change
var previous_input
var pressed := false

func _ready():
	update_self()
	node_label.text = GameConfig.get_action_name(input_name)
	previous_input = GameConfig.get_keybind(input_name)
	
func update_self():
	var action = GameConfig.get_keybind(input_name)
	var text = GameConfig.get_event_name(action)
	node_btn.text = text

func update_config(event):
	previous_input = previous_input
	GameConfig.set_keybind(input_name, event)
#
func _physics_process(_delta):
	node_btn.disabled = pressed

func _input(event):
	if pressed:
		var e = GameConfig.check_input_valid(event)
		if e != null:
			update_config(e)
			update_self()
			pressed = false
			node_btn.accept_event()

func _on_Change_pressed():
	node_btn.text = "..."
	pressed = true
