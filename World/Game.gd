extends Node2D

const enemy_eye := preload("res://Object/Enemy/EyeEnemy.tscn")
const enemy_boycircle := preload("res://Object/Enemy/SmallBoys/SmallboyCircle.tscn")
const scene_spawner := preload("res://Object/Enemy/EnemySpawner.tscn")

var ordered_waves := [
	[enemy_eye],
	[enemy_boycircle],
	[enemy_eye, enemy_boycircle]
]
var rand_waves := [
	[enemy_eye, enemy_eye, enemy_eye],
	[enemy_eye, enemy_eye, enemy_boycircle],
	[enemy_eye, enemy_boycircle, enemy_boycircle],
]
var current_wave := 0

func spawn_enemy(scene: PackedScene, pos: Vector2):
	var spawner := scene_spawner.instance()
	spawner.scene = scene
	spawner.position = pos
	add_child(spawner)

func spawn_wave():
	var wave
	if current_wave < ordered_waves.size():
		wave = ordered_waves[current_wave]
	else:
		wave = rand_waves[randi() % rand_waves.size()]
	for e in wave:
		spawn_enemy(e, Vector2(rand_range(-800, 800), rand_range(-800, 800)))
	current_wave += 1

func _physics_process(_delta):
	if get_tree().get_nodes_in_group("enemy").size() == 0:
		spawn_wave()
