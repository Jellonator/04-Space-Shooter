extends Node2D

const enemy_eye := preload("res://Object/Enemy/EyeEnemy.tscn")
const enemy_boycircle := preload("res://Object/Enemy/SmallBoys/SmallboyCircle.tscn")
const scene_spawner := preload("res://Object/Enemy/EnemySpawner.tscn")

func spawn_enemy(scene: PackedScene, pos: Vector2):
	var spawner := scene_spawner.instance()
	spawner.scene = scene
	spawner.position = pos
	add_child(spawner)

func spawn_wave():
	pass

func _physics_process(_delta):
	if get_tree().get_nodes_in_group("enemy").size() == 0:
		spawn_enemy(enemy_eye, Vector2(rand_range(-800, 800), rand_range(-800, 800)))
