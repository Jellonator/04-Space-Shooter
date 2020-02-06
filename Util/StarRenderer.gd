extends Node2D

const NUM_STARS := 512
const MIN_STAR_SIZE := 0.75
const MAX_STAR_SIZE := 2.0
const MIN_STAR_DEPTH := 5.0
const MAX_STAR_DEPTH := 15.0
var stars = []
var gradient: Gradient = Gradient.new()

class Star:
	var position: Vector2
	var depth: float
	var color: Color
	func _init(pos, depth, color):
		self.position = pos
		self.depth = depth
		self.color = color

func _ready():
	gradient.set_color(0, Color(1.0, 0.5, 0.5))
	gradient.set_color(1, Color(0.7, 0.8, 1.0))
	gradient.add_point(0.75, Color(0.9, 0.9, 0.9))
	gradient.add_point(0.5, Color(0.9, 0.9, 0.7))
	gradient.add_point(0.25, Color(0.9, 0.8, 0.7))
	for i in range(NUM_STARS):
		var ctemp := rand_range(0.0, 1.0)
		var color = gradient.interpolate(ctemp)
		var depth := sqrt(rand_range(0.0, 1.0)) * (MAX_STAR_DEPTH - MIN_STAR_DEPTH) + MIN_STAR_DEPTH
		var pos := Vector2(rand_range(0, 1024)*depth, rand_range(0, 600)*depth)
		stars.append(Star.new(pos, depth, color))

func _process(delta):
	update()

func _draw():
	var rect := get_viewport().get_visible_rect()
	var tx := get_viewport().canvas_transform
	rect.position = tx.xform(rect.position)
	for star in stars:
		var x = fposmod((star.position.x + rect.position.x) / star.depth, rect.size.x)
		var y = fposmod((star.position.y + rect.position.y) / star.depth, rect.size.y)
		var depth = star.depth
		var sizelerp = (depth - MIN_STAR_DEPTH) / (MAX_STAR_DEPTH - MIN_STAR_DEPTH)
		var size = lerp(MIN_STAR_SIZE, MAX_STAR_SIZE, 1.0-sizelerp)
		var col = Color.white
		col.a = sqrt(1.0-sizelerp)
		draw_circle(Vector2(x, y) - rect.position, size, col)
