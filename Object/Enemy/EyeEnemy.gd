extends "res://Object/Enemy/EnemyBase.gd"

const LOOK_LEN := Vector2(10, 6)
const EYE_LEN := 4
const LOOK_PLAYER_DIS := 500

onready var node_socket := $Base/Socket
onready var node_eye := $Base/Socket/Eye
onready var eye_mat := node_eye.material as ShaderMaterial

func _physics_process(delta):
	var player = get_nearest_player()
	if player == null:
		node_socket.position = Vector2(0, 0)
#		node_eye.position = Vector2(0, 0)
		eye_mat.set_shader_param("offset", Vector2(0, 0))
	else:
		var diff = player.global_position - global_position
		node_socket.position = LOOK_LEN * diff.normalized()
#		node_eye.position = EYE_LEN * diff.normalized()
		eye_mat.set_shader_param("offset", -diff.normalized() * EYE_LEN)
