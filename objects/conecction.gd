extends Node2D
class_name Connection

var id : String
var origin : Neurone
var target : Neurone
var weight : float

var color : Color = Color.WHITE

func _draw() -> void:
	draw_line(self.origin.position, self.target.position, color, 1)

func _init(id, neurone1, neurone2) -> void:
	self.id = id
	self.origin = neurone1
	self.target = neurone2
	self.origin.connections.append(self)
	self.target.connections.append(self)
	self.name = id
	
func send(n : Neurone, value):
	if n == origin:
		target.recieve(value * weight)
		
		self.color = Color.RED
		queue_redraw()
		var timer : Timer = Timer.new()
		self.add_child(timer)
		timer.start(1)
		timer.timeout.connect(func(): 
			self.color = Color.WHITE
			queue_redraw()
		)
