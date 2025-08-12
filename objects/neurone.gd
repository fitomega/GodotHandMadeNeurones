extends Node2D
class_name Neurone

var id : String
var value
var threshold : float
var timer : Timer
var recieved_value : float
var connections : Array
var state : bool

signal fired(value)

var color : Color = Color.WHITE
#Only for testing
func _draw() -> void: draw_circle(Vector2(0,0),5,color,true)
func _init(id, value, threshold = 0) -> void:
	self.id = id
	self.value = value
	self.threshold = threshold
	self.state = false
	self.name = id
func _ready() -> void:
	timer = Timer.new()
	self.add_child(timer)

	

func fire(): 
	self.state = true
	emit_signal("fired", value)
	for c in connections:
		c.send(self, self.value)
		
	self.color = Color.RED
	queue_redraw()
	

func recieve(new_value):
	self.recieved_value += new_value 
	if self.recieved_value >= threshold:
		self.fire()
	timer.start(1)
	timer.timeout.connect(func():
		self.state = false
		self.recieved_value = 0
		self.color = Color.WHITE
		queue_redraw()
	)

class OutputN: 
	extends Neurone
	func fire(): super()
class InputN: 
	extends Neurone
	func send(): fire()
class MiddleN: 
	extends Neurone
	func fire(): super()
	func recieve(new_value): super(new_value)

func _to_string() -> String:
	return self.name + " | " + str(self.value) + " | " + str(self.threshold) + " | " + str(self.recieved_value) + " | Time ->" + str(self.timer.time_left)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") && get_global_mouse_position().distance_to(self.position) < 5:
		self.recieve(10)
	if Input.is_action_just_pressed("ui_down") && get_global_mouse_position().distance_to(self.position) < 5:
		print(self)
