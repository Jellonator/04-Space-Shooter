extends KinematicBody2D

const FRICTION := 400.0
const ACCELERATION := 800.0
const MAX_SPEED := 500.0
const SHOTS_PER_SECOND := 6.0
const INV_MAX := 0.5
const scene_health := preload("res://Object/Player/HealthNode.tscn")
const scene_kill := preload("res://Object/Player/Kill.tscn")
const AUTOAIM_MIN_DOT := 0.65
const AUTOAIM_DISTANCE_MAX := 600.0
const AUTOAIM_DISTANCE_MIN := 300.0

onready var node_sprite := $Sprite
onready var node_front := $FrontPos
onready var node_left := $LeftPos
onready var node_right := $RightPos
onready var node_smoke := $PSmoke as Particles2D
onready var node_gui := $Gui
onready var part_smoke := node_smoke.process_material as ParticlesMaterial
onready var part_smoke_offset := node_smoke.position
onready var node_fire := $PFlame as Particles2D
onready var part_fire := node_fire.process_material as ParticlesMaterial
onready var part_fire_offset := node_fire.position

var shot_timer := 0.0
var velocity := Vector2(0, 0)
var invincibility := 0.0
var shoot_i := 0
onready var shoot_locations = [node_left, node_right]
var max_health := 3
var health := max_health
onready var health_nodes := []
onready var look_rotation = self.rotation
var score := 0

func _ready():
	for _i in range(max_health - health_nodes.size()):
		var pos := Vector2(health_nodes.size() * 24 + 16, 16)
		var node := scene_health.instance()
		node_gui.add_child(node)
		node.position = pos
		health_nodes.append(node)

func get_nearest_enemy_in_sight():
	var ret = null
	var dis = 0.0
	for enemy in get_tree().get_nodes_in_group("enemy"):
		var froma = Vector2(1, 0).rotated(look_rotation)
		var toa = (enemy.global_position - global_position).normalized()
		var newdis = global_position.distance_to(enemy.global_position)
		var lerpv = clamp((newdis - AUTOAIM_DISTANCE_MIN) /\
			(AUTOAIM_DISTANCE_MAX - AUTOAIM_DISTANCE_MIN), 0.0, 1.0)
		var target_dot = lerp(AUTOAIM_MIN_DOT, 1.0, lerpv)
		if froma.dot(toa) < target_dot:
			continue
		if ret == null or newdis < dis:
			ret = enemy
			dis = newdis
	return ret

func _physics_process(delta):
	if invincibility >= 0.0:
		node_sprite.visible = fmod(invincibility, 1.0/6.0) < 1.0/12.0
		invincibility -= delta
	else:
		node_sprite.visible = true
	var ivector := Vector2(0, 0)
	ivector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	ivector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	if ivector.length_squared() > 1:
		ivector = ivector.normalized()
	if ivector.length() > 1e-3:
		node_smoke.emitting = true
		var lvec = ivector.rotated(-rotation)
		part_smoke.direction = Vector3(lvec.x, lvec.y, 0)
		part_fire.direction = part_smoke.direction
	else:
		node_smoke.emitting = false
	var target_velocity := MAX_SPEED * ivector
	var vdiff := target_velocity - velocity
	if vdiff.length() < ACCELERATION * delta:
		velocity = target_velocity
	else:
		velocity += vdiff.normalized() * delta * ACCELERATION
	var do_shoot := false
	if GameConfig.get_config_value("mouse_enabled"):
		look_at(get_global_mouse_position())
		do_shoot = Input.is_action_pressed("action_shoot_mouse")
	else:
		var lookvector := Vector2(0, 0)
		lookvector.x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
		lookvector.y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
		if lookvector.length_squared() > 1e-3:
			look_rotation = lookvector.angle()
			var target_rotation = look_rotation
			var enemy = get_nearest_enemy_in_sight()
			if enemy != null:
				var newrot = global_position.angle_to_point(enemy.global_position) + PI
				target_rotation = lerp_angle(look_rotation, newrot, 0.5)
			self.rotation = lerp_angle(self.rotation, target_rotation, delta * 15)
		do_shoot = Input.is_action_pressed("action_shoot_nonmouse")
	velocity = move_and_slide(velocity)
	var brender = get_tree().get_nodes_in_group("bullet_renderer")[0]
	if do_shoot:
		shot_timer -= delta * SHOTS_PER_SECOND
		while shot_timer <= 0.0:
			shot_timer += 1.0
			var shootparent = shoot_locations[shoot_i]
			var shoot_from := shootparent.global_position as Vector2
			shoot_i = (shoot_i + 1) % shoot_locations.size()
			var shot_direction := Vector2(1, 0).rotated(self.global_rotation)
			var shot_target := shoot_from + shot_direction * 10000
			var space := get_world_2d().direct_space_state
			var enemylayer := 0b101
			var result := space.intersect_ray(shoot_from, shot_target, [self], enemylayer)
			if not result.empty():
				var collider = result.collider
				if collider.has_method("do_damage"):
					collider.do_damage(1, shot_direction * 50)
				shot_target = result.position + shot_direction * 10
			brender.add_bullet(shoot_from, shot_target, shootparent)
	else:
		shot_timer = max(0.0, shot_timer - delta * SHOTS_PER_SECOND)

func do_damage(amount: int, accel: Vector2):
	if invincibility > 0.0:
		return
	velocity += accel
	var newhealth := int(clamp(health - amount, 0, max_health))
	for i in range(newhealth, health):
		health_nodes[i].set_burning(false)
	health = newhealth
	invincibility = INV_MAX
	if health <= 0:
		set_process(false)
		set_physics_process(false)
		set_process_input(false)
		collision_mask = 0
		collision_layer = 0
		node_sprite.hide()
		node_smoke.emitting = false
		node_fire.emitting = false
		var node = scene_kill.instance()
		node.position = self.global_position
		node.rotation = self.global_rotation
		node.score = score
		get_parent().add_child(node)

func add_score(amount: int):
	score += amount
	$Gui/VBox/Score.text = "%08d" % score
