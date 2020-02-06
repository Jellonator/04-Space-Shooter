extends Node2D

var bullets := []
const BULLET_LIFE_TIME := 1.0/20.0
var font: Font
var gradient: Gradient = Gradient.new()

class BulletData:
	var frompos: Vector2
	var topos: Vector2
	var life: float = 1
	var firstframe: bool = true
	var parent
	func _init(frompos: Vector2, topos: Vector2, parent):
		self.frompos = frompos
		self.topos = topos
		self.parent = parent
	func length() -> float:
		return frompos.distance_to(topos)

func _ready():
	gradient.set_color(0, Color(0, 0, 0, 0))
	gradient.add_point(0.25, Color.red)
	gradient.add_point(0.5, Color.orange)
	gradient.add_point(0.75, Color.yellow)
	var control := Control.new()
	font = control.get_font("font")
	control.free()

func add_bullet(frompos: Vector2, topos: Vector2, parent):
	bullets.append(BulletData.new(frompos, topos, parent))

func _process(delta):
	update()
	var i := 0
	while i < bullets.size():
		var bullet: BulletData = bullets[i] as BulletData
		if not bullet.firstframe:
			bullet.life -= delta / BULLET_LIFE_TIME
		else:
			bullet.firstframe = false
		if bullet.life <= 0:
			bullets.remove(i)
		else:
			i = i + 1

func _draw():
	var tx := get_viewport_transform()
	var offset = tx.xform(Vector2(0, 0))
	var fps := str(Engine.get_frames_per_second())
	draw_string(font, -offset + Vector2(0, font.get_height()), fps, Color.white)
	for bullet in bullets:
		var frompos = bullet.frompos
		if bullet.parent != null:
			frompos = bullet.parent.global_position
		draw_line(frompos, bullet.topos, gradient.interpolate(bullet.life), 3, false)
