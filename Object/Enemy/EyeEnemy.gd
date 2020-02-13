extends "res://Object/Enemy/EnemyBase.gd"

const SHOOT_SCENE := preload("res://Object/Enemy/EnemyShot.tscn")
const SHOOT_SPEED := 320.0
const SHOOT_RATE := 0.25
const SPEED := 120.0
const ACCEL := 100.0

const LOOK_LEN := Vector2(10, 6)
const EYE_LEN := 4.0

onready var node_socket := $Base/Socket
onready var node_eye := $Base/Socket/Eye
onready var eye_mat := node_eye.material as ShaderMaterial

var shoot_time := 0.0

func _ready():
	shoot_time = rand_range(0.8, 1.2)

func _physics_process(delta):
	var player = get_nearest_player()
	if player == null:
		node_socket.position = Vector2(0, 0)
#		node_eye.position = Vector2(0, 0)
		eye_mat.set_shader_param("offset", Vector2(0, 0))
		shoot_time = 1.0
	else:
		var diff = player.global_position - global_position
		node_socket.position = (LOOK_LEN * diff.normalized()).round()
#		node_eye.position = EYE_LEN * diff.normalized()
		eye_mat.set_shader_param("offset", -(diff.normalized() * EYE_LEN).round())
		shoot_time -= delta * SHOOT_RATE
		if shoot_time < 0:
			shoot_time = rand_range(0.9, 1.1)
			var shot = SHOOT_SCENE.instance()
			get_parent().add_child(shot)
			shot.global_position = global_position
			shot.velocity = diff.normalized() * SHOOT_SPEED
		if shoot_time > 0.2 and shoot_time < 0.6:
			tween_velocity(diff.normalized() * SPEED, delta * ACCEL)
