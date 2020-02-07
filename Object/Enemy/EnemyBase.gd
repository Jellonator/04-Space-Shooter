extends KinematicBody2D

export var max_health := 10
var health := 1
var mod_timer := 0.0

func _ready():
	health = max_health

func do_kill():
	print("KILL")
	queue_free()

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
