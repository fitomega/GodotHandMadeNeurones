extends Node2D
class_name Connection

var id : String
var origin : Neurone
var target : Neurone
var weight : float

var color : Color = Color.WHITE
var visual_timer : Timer  # Reuse timer instead of creating new ones

func _draw() -> void:
	# Visual distinction: positive weights = normal, negative = dashed/thinner
	var line_width = 1 if weight >= 0 else 1
	var line_color = color if weight >= 0 else Color(color.r, color.g, color.b, 0.7)
	draw_line(self.origin.position, self.target.position, line_color, line_width)

func _init(id, neurone1, neurone2) -> void:
	self.id = id
	self.origin = neurone1
	self.target = neurone2
	self.origin.connections.append(self)
	self.target.connections.append(self)
	self.name = id
	# Xavier/Glorot initialization for better learning
	self.weight = randf_range(-0.5, 0.5)
	# Initialize reusable timer
	visual_timer = Timer.new()
	self.add_child(visual_timer)
	visual_timer.timeout.connect(_reset_color)
func send(n : Neurone, value):
	if n == origin:
		target.recieve(value * weight)
		self.color = Color.RED
		queue_redraw()
		# Reuse existing timer instead of creating new ones
		visual_timer.start(1.0)
	
func _reset_color():
	self.color = Color.WHITE
	queue_redraw()
