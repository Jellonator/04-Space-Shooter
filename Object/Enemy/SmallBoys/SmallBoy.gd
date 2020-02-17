extends "res://Object/Enemy/EnemyBase.gd"

func _physics_process(delta):
	if velocity.x > 10:
		$Sprite.flip_h = false
	elif velocity.x < -10:
		$Sprite.flip_h = true

func _ready():
	connect("killed", self, "play_death")

func play_death():
	$SndDead.pitch_scale = rand_range(0.9, 1.1)
	$SndDead.play()
