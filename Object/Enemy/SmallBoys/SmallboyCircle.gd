extends Node2D

const scene_boy := preload("res://Object/Enemy/SmallBoys/SmallBoy.tscn")
const ROTATION_SPEED_MAX := PI * 0.5
const BASE_RADIUS := 64.0
const RADIUS_SCALE := 16.0
const SPEED := 180.0
const BOY_SPEED := SPEED
export var num_boys := 3
var velocity := Vector2(0, 0)
var paused := false setget set_paused, is_paused
var kill_timer := 2.0

func get_spawner_radius() -> float:
	return 32.0

func set_paused(value: bool):
	paused = value
	for boy in boys:
		boy.paused = is_paused()

func is_paused() -> bool:
	return paused

var boys := []
var t := 0.0

func _ready():
	for _i in range(num_boys):
		var boy := scene_boy.instance()
		add_child(boy)
		boys.append(boy)
		boy.paused = paused
# warning-ignore:return_value_discarded
		boy.connect("killed", self, "_on_boy_killed", [boy])

func _physics_process(delta):
	var n := boys.size()
	if n == 0:
		kill_timer -= delta
		if kill_timer < 0.0:
			queue_free()
		return
	if paused:
		return
	var radius := n * RADIUS_SCALE + BASE_RADIUS
	var p1 = Vector2(radius, 0)
	var p2 = p1.rotated(2.0 * PI / n)
	var dis = p1.distance_to(p2)
	t += delta * ROTATION_SPEED_MAX * BASE_RADIUS / dis
	for i in range(n):
		var rot := t + (float(i) / float(n)) * PI * 2.0
		var boy = boys[i]
		var target_position = self.global_position + Vector2(radius, 0).rotated(rot)
		var diff = target_position - boy.global_position
		var target_velocity = diff.normalized() * BOY_SPEED
		var accel = delta * BOY_SPEED * clamp(diff.length() * 0.1, 1.0, 20.0)
		boy.tween_velocity(target_velocity, accel)
	var player = GameUtil.get_nearest_player(global_position)
	if player != null:
		var diff = player.global_position - global_position
		var movement = diff.normalized() * delta * SPEED
		if diff.length() < radius:
			movement *= -1
		self.position += movement
		for boy in boys:
			boy.position -= movement

func _on_boy_killed(boy):
	boys.erase(boy)
	if boys.size() == 0:
		self.paused = true
