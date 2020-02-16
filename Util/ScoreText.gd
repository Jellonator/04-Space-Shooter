extends Node2D

export var score := 100
var life := 1.5

func _enter_tree():
	$Label.text = str(score)

func _physics_process(delta):
	self.position += delta * Vector2(0, -1) * 100
	self.life -= delta
	if life <= 0.0:
		queue_free()
