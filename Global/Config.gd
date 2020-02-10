extends Node

# Path to the user's configuration file
const CONFIG_FILE := "user://configuration.cfg"
# Handle to the user's configuration file
onready var config := ConfigFile.new();

# Section name for the player's keybinds
const SECTION_KEYS := "keybinds"
# Section name for the player's volume
const SECTION_VOLUME := "volume"
# Section for game config
const SECTION_CONFIG := "config"
# All configurable keys
const SECTION_KEY_ELEMENTS := [
	"move_up",
	"move_down",
	"move_left",
	"move_right",
	"look_up",
	"look_down",
	"look_left",
	"look_right",
	"action_shoot_mouse",
	"action_shoot_nonmouse",
	"game_pause"
]
# All configurable volumes
const SECTION_VOLUME_ELEMENTS := [
	"Sound",
	"Music",
	"Master",
]
# Real names for inputs
const INPUT_REALNAMES := {
	"move_up": "Move Up",
	"move_down": "Move Down",
	"move_left": "Move Left",
	"move_right": "Move Right",
	"look_up": "Move Up",
	"look_down": "Move Down",
	"look_left": "Move Left",
	"look_right": "Move Right",
	"action_shoot_mouse": "Shoot",
	"action_shoot_nonmouse": "Shoot",
	"game_pause": "Pause"
}

# CONFIG VALUES
var CONFIG := {
	"mouse_enabled": false
}

# Get the real name for a given action
func get_action_name(name: String) -> String:
	if INPUT_REALNAMES.has(name):
		return INPUT_REALNAMES[name]
	return "Invalid"

# Get the volume for the given volume name
func get_volume(name: String) -> float:
	return config.get_value(SECTION_VOLUME, name);

# Get the volume from 1 - 100
func get_volume_slider(name: String) -> float:
	return get_volume(name) * 100
	
# Updates the volume of the given bus to the given value
func update_volume(name: String):
	var volumedb := linear2db(get_volume(name))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(name), volumedb)

# Set the volume for the given volume name
func set_volume(name: String, value: float):
	config.set_value(SECTION_VOLUME, name, value);
	update_volume(name)
# warning-ignore:return_value_discarded
	save_config();

# Set the volume but from 1 - 100
func set_volume_slider(name: String, value: float):
	set_volume(name, value/100)

# Used to make sure config has all of the necessary settings
func check_config():
	var does_need_save := false
	for name in SECTION_KEY_ELEMENTS:
		if not config.has_section_key(SECTION_KEYS, name):
			config.set_value(SECTION_KEYS, name, InputMap.get_action_list(name)[0]);
			does_need_save = true
	for name in SECTION_VOLUME_ELEMENTS:
		if not config.has_section_key(SECTION_VOLUME, name):
			config.set_value(SECTION_VOLUME, name, 0.5);
			does_need_save = true
	for name in CONFIG:
		if not config.has_section_key(SECTION_CONFIG, name):
			config.set_value(SECTION_CONFIG, name, CONFIG[name])
	if does_need_save:
# warning-ignore:return_value_discarded
		save_config()

func _ready():
	# Make sure that the config file exists
	var file := File.new();
	if not file.file_exists(CONFIG_FILE):
# warning-ignore:return_value_discarded
		file.open(CONFIG_FILE, file.WRITE)
		file.close();
# warning-ignore:return_value_discarded
		save_config();
# warning-ignore:return_value_discarded
	load_config();

# Update all events in map to match settings
func update_events():
	for name in SECTION_KEY_ELEMENTS:
		var events = config.get_value(SECTION_KEYS, name);
		InputMap.erase_action(name);
		InputMap.add_action(name);
		if typeof(events) == TYPE_ARRAY:
			for event in events:
				InputMap.action_add_event(name, event);
		else:
			InputMap.action_add_event(name, events);

# Converts the given volume to DB.
func update_volumes():
	for name in SECTION_VOLUME_ELEMENTS:
		update_volume(name)

# Load configuration
func load_config() -> int:
	var err := config.load(CONFIG_FILE);
	if err != OK:
		printerr("Error loading user configuration: ", err);
	# After loading, check configuration
	# to make sure it is valid
	check_config();
	# And update InputMap to match
	update_events();
	# Also update volume
	update_volumes();
	# Update config
	for key in CONFIG:
		if config.has_section_key(SECTION_CONFIG, key):
			CONFIG[key] = config.get_value(SECTION_CONFIG, key)
	return err

# Save configuration to file
func save_config() -> int:
	var err := config.save(CONFIG_FILE);
	if err != OK:
		printerr("Error saving user configuration: ", err);
	return err

# Get a keybind
func get_keybind(name: String):
	return config.get_value(SECTION_KEYS, name)

# Set a keybind to a given event
func set_keybind(name: String, event: InputEvent):
	config.set_value(SECTION_KEYS, name, event)
# warning-ignore:return_value_discarded
	save_config()
	InputMap.erase_action(name);
	InputMap.add_action(name);
	InputMap.action_add_event(name, event);

func set_config_value(name: String, value):
	if name in CONFIG:
		if typeof(CONFIG[name]) == typeof(value):
			CONFIG[name] = value
			save_config()
			return OK
		else:
			return ERR_INVALID_DATA
	else:
		return ERR_DOES_NOT_EXIST

func get_config_value(name: String):
	return CONFIG[name]

# Check if an event is really a valid event
# Returns null if not valid, returns event if is valid
func check_input_valid(event: InputEvent):
	if event is InputEventKey:
		var ek := event as InputEventKey
		if ek.pressed and not ek.echo:
			ek.control = false
			ek.shift = false
			ek.meta = false
			ek.alt = false
			ek.command = false
			return ek
	if event is InputEventMouseButton:
		var emb := event as InputEventMouseButton
		if emb.pressed and not emb.doubleclick:
			emb.control = false
			emb.shift = false
			emb.meta = false
			emb.alt = false
			emb.command = false
			return emb
	if event is InputEventJoypadButton:
		var ejb := event as InputEventJoypadButton
		if ejb.pressed:
			return ejb
	if event is InputEventJoypadMotion:
		var ejm := event as InputEventJoypadMotion
		ejm.axis_value = 0.1 * sign(ejm.axis_value)
		return ejm
	return null

# Get name of an event
func get_event_name(event: InputEvent) -> String:
	if event is InputEventKey:
		var ek := event as InputEventKey
		return OS.get_scancode_string(ek.scancode)
	if event is InputEventMouseButton:
		var emb := event as InputEventMouseButton
		if emb.button_index == BUTTON_LEFT:
			return "Left click"
		elif emb.button_index == BUTTON_RIGHT:
			return "Right click"
		elif emb.button_index == BUTTON_MIDDLE:
			return "Middle click"
		elif emb.button_index == BUTTON_WHEEL_DOWN:
			return "Mouse wheel down"
		elif emb.button_index == BUTTON_WHEEL_UP:
			return "Mouse wheel down"
		elif emb.button_index == BUTTON_WHEEL_LEFT:
			return "Mouse wheel left"
		elif emb.button_index == BUTTON_WHEEL_RIGHT:
			return "Mouse wheel right"
		else:
			return "Mouse button " + str(emb.button_index)
	if event is InputEventJoypadButton:
		var ejb := event as InputEventJoypadButton
		return "Button " + str(ejb.button_index)
	if event is InputEventJoypadMotion:
		var ejm := event as InputEventJoypadMotion
		if ejm.axis_value < 0:
			return "Axis -" + str(ejm.axis)
		else:
			return "Axis " + str(ejm.axis)
	return "Invalid"
