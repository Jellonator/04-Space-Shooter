extends Node2D

const LOOK_RADIUS_MAX := 270
const LOOK_RADIUS_MIN := 250
const DRAW_RADIUS := 240
onready var scene_locator := preload("res://Util/EnemyLocator.tscn")

var locators := {}

func _physics_process(_delta):
	var camera := get_tree().get_nodes_in_group("camera")[0] as Camera2D
	var center := camera.get_camera_screen_center()
	for enemy_ in get_tree().get_nodes_in_group("enemy"):
		var enemy := enemy_ as Node2D
		var epos := enemy.global_position
		epos -= center
		epos.x /= 960/540.0
		if epos.length() > LOOK_RADIUS_MAX:
			if not enemy in locators:
				locators[enemy] = scene_locator.instance()
				add_child(locators[enemy])
# warning-ignore:return_value_discarded
				enemy.connect("tree_exited", self, "_on_enemy_dead", [enemy])
			locators[enemy].show()
		elif epos.length() < LOOK_RADIUS_MIN:
			if enemy in locators:
				locators[enemy].hide()
	for enemy_ in locators:
		var enemy := enemy_ as Node2D
		var locator := locators[enemy] as Node2D
		var epos := enemy.global_position
		epos -= center
		epos.x /= 960/540.0
		var rot := epos.angle()
		locator.rotation = rot + 1.5 * PI/2
		locator.position = Vector2(DRAW_RADIUS, 0).rotated(rot)
		locator.position.x *= 960.0/540.0
		locator.position += Vector2(960, 540) / 2

func _on_enemy_dead(enemy):
	if enemy in locators:
		locators[enemy].queue_free()
# warning-ignore:return_value_discarded
	locators.erase(enemy)
