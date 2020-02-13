extends Node2D

# Must be off-screen for 5 seconds to despawn
const REMOVE_TIME_MAX := 5.0
export var velocity := Vector2(0, 0)
var remove_time := REMOVE_TIME_MAX

func _physics_process(delta):
	global_position += delta * velocity
	if not $VisibilityNotifier2D.is_on_screen():
		remove_time -= delta
		if remove_time < 0:
			queue_free()
	else:
		remove_time = REMOVE_TIME_MAX
	$Particles2D.position = velocity * delta * 6

func _on_Area2D_body_entered(body):
	print("BODY ENTERED")
	queue_free()
