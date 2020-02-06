extends Node2D

var bullets := []
const BULLET_SPEED = 8000
const DRAW_LENGTH = 200
var font: Font

class BulletData:
	var frompos: Vector2
	var topos: Vector2
	var position: float = 0
	func _init(frompos: Vector2, topos: Vector2):
		self.frompos = frompos
		self.topos = topos
		self.position = 0
	func length() -> float:
		return frompos.distance_to(topos)

func _ready():
	var control := Control.new()
	font = control.get_font("font")
	control.free()

func add_bullet(frompos: Vector2, topos: Vector2):
	bullets.append(BulletData.new(frompos, topos))

func _process(delta):
	update()
	if Input.is_action_pressed("ui_home"):
		return
	var i := 0
	while i < bullets.size():
		var bullet: BulletData = bullets[i] as BulletData
		bullet.position += delta * BULLET_SPEED
		if bullet.position > bullet.length():
			bullets.remove(i)
		else:
			i = i + 1

func _draw():
	draw_string(font, Vector2(0, font.get_height()), str(self.bullets.size()))
	for bullet in bullets:
		var startf = bullet.position
		var endf = max(0.0, startf - DRAW_LENGTH)
		var startv = bullet.frompos.linear_interpolate(bullet.topos, startf / bullet.length())
		var endv = bullet.frompos.linear_interpolate(bullet.topos, endf / bullet.length())
		var opacity := 1.0
		if startf < 400:
			opacity = clamp(lerp(0.0, 1.0, (startf - 300)/100.0), 0, 1)
		draw_line(startv, endv, Color(1, 1, 1, opacity), 3, false)
		for i in range(8):
			var amt = (i + 1) / 8.0
			var newf = max(0.0, endf - amt * DRAW_LENGTH)
			var newv = bullet.frompos.linear_interpolate(bullet.topos, newf / bullet.length())
			draw_line(endv, newv, Color(1, 1, 1, opacity / 8.0), 3, false)
