extends Node2D

onready var node_particles := $ParallaxBackground/ParallaxLayer/Particles2D
onready var shader_mat := node_particles.process_material as ShaderMaterial

func _process(delta):
	var rect := get_viewport().get_visible_rect()
	var tx := get_viewport().canvas_transform
	rect.position = tx.xform(rect.position)
	shader_mat.set_shader_param("offset", rect.position)
