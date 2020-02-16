extends "res://Object/Enemy/EnemyBase.gd"

func _physics_process(delta):
	if velocity.x > 10:
		$Sprite.flip_h = false
	elif velocity.x < -10:
		$Sprite.flip_h = true
