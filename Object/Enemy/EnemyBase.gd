extends KinematicBody2D

onready var shader := preload("res://Object/Enemy/death_shader.shader")
onready var scene_scoretext := preload("res://Util/ScoreText.tscn")

export var max_health := 10
export(Array, NodePath) var sprites := [];
export var drag := 0.1
export var weight := 1.0
export var score_value := 1000
export var spawner_radius := 32.0

var health := 1
var mod_timer := 0.0
var death_timer := 1.0
var smat: ShaderMaterial
var velocity := Vector2(0, 0)
var paused := false setget set_paused, is_paused
var node_snd_hit: AudioStreamPlayer2D

func is_paused() -> bool:
	return paused

func set_paused(value: bool):
	paused = value
	for c in get_children():
		if c is CollisionShape or c is CollisionPolygon2D:
			c.disabled = value

signal killed();

func get_spawner_radius() -> float:
	return spawner_radius

func _ready():
	node_snd_hit = AudioStreamPlayer2D.new()
	add_child(node_snd_hit)
	node_snd_hit.stream = preload("res://Sounds/sfx_sounds_impact6.wav")
	node_snd_hit.volume_db = -6
	health = max_health
	smat = ShaderMaterial.new()
	smat.shader = shader

func is_dead():
	return health <= 0

func do_kill():
	emit_signal("killed")
	for sprite in sprites:
		get_node(sprite).material = smat
	set_paused(true)
	collision_mask = 0
	collision_layer = 0
	get_tree().call_group("score", "add_score", score_value)
	var txt = scene_scoretext.instance()
	txt.score = score_value
	txt.position = self.global_position
	get_tree().current_scene.add_child(txt)

func do_damage(amount: int, accel: Vector2):
	node_snd_hit.pitch_scale = rand_range(0.9, 1.1)
	node_snd_hit.play()
	health = int(clamp(health - amount, 0, max_health))
	if health <= 0:
		do_kill()
	mod_timer = 1.0 / 20.0
	modulate = Color.red
	velocity += accel / weight

func _physics_process(delta):
	if mod_timer > 0:
		mod_timer -= delta
		if mod_timer <= 0:
			modulate = Color.white
	if is_dead():
		death_timer -= delta
		for path in sprites:
			var sprite := get_node(path) as Node2D
			sprite.position.x += rand_range(-2, 2)
			sprite.position.y += rand_range(-2, 2)
		if death_timer < 0.0:
			queue_free()
		else:
			smat.set_shader_param("death", death_timer)
	if not is_paused():
		velocity = move_and_slide(velocity)
		for i in range(get_slide_count()):
			var col := get_slide_collision(i)
			if not col.collider.is_in_group("enemy"):
				if col.collider.has_method("do_damage"):
					col.collider.do_damage(1, col.normal * -300)
		if velocity.length() > 1e-4:
			velocity += -drag * velocity * velocity * delta * velocity.normalized()
		else:
			velocity = Vector2(0, 0)

func add_velocity(accel: Vector2):
	velocity += accel

func tween_velocity(target_velocity: Vector2, accel: float):
	var vdiff := target_velocity - velocity
	if vdiff.length() < accel:
		velocity = target_velocity
	else:
		velocity += vdiff.normalized() * accel
