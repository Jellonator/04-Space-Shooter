extends Node2D

# Must be off-screen for 5 seconds to despawn
const REMOVE_TIME_MAX := 5.0
export var velocity := Vector2(0, 0)
var remove_time := REMOVE_TIME_MAX
var did_hit := false

func _physics_process(delta):
	global_position += delta * velocity
	if not $VisibilityNotifier2D.is_on_screen() or did_hit:
		remove_time -= delta
		if remove_time < 0:
			queue_free()
	else:
		remove_time = REMOVE_TIME_MAX
	$Particles2D.position = velocity * delta * 4

func _on_Area2D_body_entered(body):
	if did_hit:
		return
	did_hit = true
	$Particles2D.emitting = false
	if body.has_method("do_damage"):
		body.do_damage(1, Vector2(0, 0))
