extends Node2D

const NUM_STARS := 512
const MIN_STAR_SIZE := 1.15
const MAX_STAR_SIZE := 2.0
const MIN_STAR_DEPTH := 5.0
const MAX_STAR_DEPTH := 15.0
var stars = []
var gradient: Gradient = Gradient.new()

onready var node_particles := $ParallaxBackground/ParallaxLayer/Particles2D
onready var shader_mat := node_particles.process_material as ShaderMaterial

func _process(delta):
	var rect := get_viewport().get_visible_rect()
	var tx := get_viewport().canvas_transform
	rect.position = tx.xform(rect.position)
	shader_mat.set_shader_param("offset", rect.position)
