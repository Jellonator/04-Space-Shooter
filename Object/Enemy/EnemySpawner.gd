extends Node2D

export(PackedScene) var scene: PackedScene;

var node
var radius: float

onready var node_sprite := $Sprite
onready var mat_sprite := node_sprite.material as ShaderMaterial

func is_paused():
	return false

func _ready():
	node = scene.instance()
	node.position = Vector2(320, 320)
	node.paused = true
	radius = node.get_spawner_radius() + 8.0
	$Viewport.add_child(node)

var t := 0.0

func _physics_process(delta):
	t += delta * 2.0
	var rad = (sin(t - PI*0.5) * 0.5 + 0.5) * radius
	mat_sprite.set_shader_param("radius", rad)
	if t >= PI and node != null:
		$Viewport.remove_child(node)
		get_parent().add_child(node)
		node.paused = false
		node.global_position = self.global_position
		node = null
	if t >= 2 * PI:
		queue_free()
