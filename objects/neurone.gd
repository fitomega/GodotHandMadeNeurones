extends Node2D
class_name Neurone

var state
var value
var activation_threshold = 1
var activation_level = 0
var id
var connections = []

const MAX_FRAME_TIME = 0.2
var frame_time = 0.0

const MAX_SHUT_DOWN_TIME = 0.2
var shut_down_time = 0.0

signal fired(value)

var color : Color
enum  types {OUTPUT, INPUT, MIDDLE}
var type
func _init(id : String, value = null, type : types = types.MIDDLE) -> void:
	self.id = id
	self.name = id
	self.value = value
	self.type = type

func _process(delta):
	if(frame_time > 0): 
		frame_time -= delta
	if(shut_down_time > 0): 
		shut_down_time -= delta
	else:
		color = Color.WHITE
		self.activation_level = 0
		shut_down_time = MAX_SHUT_DOWN_TIME
		state = false
		queue_redraw()

func recieve(value): 
	activation_level += value
	if activation_level >= activation_threshold: fire()

func fire():
	if(frame_time <= 0):
		connections.any(func(c : Connection): c.fire(self, value))
		emit_signal("fired", value)
		state = true
		self.color = Color.RED
		self.activation_level = 0
		frame_time = MAX_FRAME_TIME
		queue_redraw()

#testing
func _draw() -> void:
	draw_circle(Vector2(0,0),5,self.color)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept") && get_global_mouse_position().distance_to(self.position) < 5:
		recieve(0.5)
		
	if Input.is_action_just_pressed("ui_down") && get_global_mouse_position().distance_to(self.position) < 5:
		print(self)
