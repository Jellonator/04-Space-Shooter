extends KinematicBody2D

onready var shader := preload("res://Object/Enemy/death_shader.shader")
export var max_health := 10
export(Array, NodePath) var sprites := [];
var health := 1
var mod_timer := 0.0
var death_timer := 1.0
var smat: ShaderMaterial

func _ready():
	health = max_health
	smat = ShaderMaterial.new()
	smat.shader = shader
	for sprite in sprites:
		get_node(sprite).material = smat
	add_to_group("enemy", true)

func is_dead():
	return health <= 0

func do_kill():
	collision_mask = 0
	collision_layer = 0

func do_damage(amount: int):
	health = clamp(health - amount, 0, max_health)
	if health <= 0:
		do_kill()
	mod_timer = 1.0 / 20.0
	modulate = Color.red

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
