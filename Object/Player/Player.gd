extends KinematicBody2D

const FRICTION := 400
const ACCELERATION := 400
const MAX_SPEED := 800
const SHOTS_PER_SECOND := 10.0

enum ControlType {MOUSE, KEYBOARD}

onready var node_front := $FrontPos
onready var node_left := $LeftPos
onready var node_right := $RightPos

var look_type = ControlType.KEYBOARD
var shot_timer := 0.0
var velocity := Vector2(0, 0)
var shoot_i = 0
onready var shoot_locations = [node_left, node_right]

func _physics_process(delta):
	var ivector := Vector2(0, 0)
	ivector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	ivector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	if ivector.length_squared() > 1:
		ivector = ivector.normalized()
	var target_velocity := MAX_SPEED * ivector
	var vdiff := target_velocity - velocity
	if vdiff.length() < ACCELERATION * delta:
		velocity = target_velocity
	else:
		velocity += vdiff * delta
	velocity = move_and_slide(velocity)
	if look_type == ControlType.KEYBOARD:
		var lookvector := Vector2(0, 0)
		lookvector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
		lookvector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
		if lookvector.length_squared() > 1e-2:
			self.rotation = lerp_angle(self.rotation, lookvector.angle(), delta * 10)
	else:
		look_at(get_global_mouse_position())
	var brender = get_tree().get_nodes_in_group("bullet_renderer")[0]
	if Input.is_action_pressed("action_shoot"):
		shot_timer -= delta * SHOTS_PER_SECOND
		while shot_timer <= 0.0:
			shot_timer += 1.0
			var shootparent = shoot_locations[shoot_i]
			var shoot_from := shootparent.global_position as Vector2
			shoot_i = (shoot_i + 1) % shoot_locations.size()
			var shot_direction := Vector2(1, 0).rotated(self.global_rotation)
			var shot_target := shoot_from + shot_direction * 10000
			brender.add_bullet(shoot_from, shot_target, shootparent)
	else:
		shot_timer = max(0.0, shot_timer - delta * SHOTS_PER_SECOND)
