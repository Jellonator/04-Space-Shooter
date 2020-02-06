extends Node2D

var bullets := []
const BULLET_SPEED = 6000

class BulletData:
	var frompos: Vector2
	var topos: Vector2
	var prevpos: float = 0
	var position: float = 0
	func _init(frompos: Vector2, topos: Vector2):
		self.frompos = frompos
		self.topos = topos
	func length() -> float:
		return frompos.distance_to(topos)

func add_bullet(frompos: Vector2, topos: Vector2):
	bullets.append(BulletData.new(frompos, topos))

func _process(delta):
	var i := 0
	while i < bullets.size():
		var bullet: BulletData = bullets[i] as BulletData
		bullet.prevpos = bullet.position
		bullet.position += delta * BULLET_SPEED
		if bullet.position > bullet.length():
			bullets.remove(i)
		else:
			i = i + 1
	update()

func _draw():
	for bullet in bullets:
		var startf = bullet.prevpos
		var endf = bullet.position
		var diff = abs(endf - startf)
		var trailf = max(0.0, startf - diff)
		var trailf2 = max(0.0, trailf - diff)
		var startv = bullet.frompos.linear_interpolate(bullet.topos, startf / bullet.length())
		var endv = bullet.frompos.linear_interpolate(bullet.topos, endf / bullet.length())
		var trailv = bullet.frompos.linear_interpolate(bullet.topos, trailf / bullet.length())
		var trailv2 = bullet.frompos.linear_interpolate(bullet.topos, trailf2 / bullet.length())
		draw_line(trailv2, trailv, Color(0.7, 0.1, 0.0), 1, false)
		draw_line(trailv, startv, Color(0.7, 0.5, 0.0), 2, false)
		draw_line(startv, endv, Color.white, 3, false)
