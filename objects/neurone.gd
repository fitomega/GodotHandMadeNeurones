extends Node2D
class_name Neurone

var id : String
var value
var threshold : float
var base_threshold : float  # Original threshold for reference
var timer : Timer
var timer_connected : bool = false  # Track if timer is already connected
var recieved_value : float
var connections : Array
var state : bool
var activation_count : int = 0  # Track how often this neuron fires

signal fired(value)

var color : Color = Color.WHITE
#Only for testing
func _draw() -> void: draw_circle(Vector2(0,0),5,color,true)
func _init(id, value, threshold = 0) -> void:
	self.id = id
	self.value = value
	self.threshold = threshold
	self.base_threshold = threshold  # Store original threshold
	self.state = false
	self.name = id
func _ready() -> void:
	timer = Timer.new()
	self.add_child(timer)
	# Connect timer once to avoid memory leaks
	timer.timeout.connect(_reset_neuron_state)
	timer_connected = true

func fire(): 
	self.state = true
	self.activation_count += 1  # Track activations
	emit_signal("fired", value)
	for c in connections:
		c.send(self, self.value)
		
	# Reset received_value immediately after firing to prevent accumulation
	self.recieved_value = 0
	
	self.color = Color.RED
	queue_redraw()
	
# Adapt threshold based on usage - prevents over/under activation
func adapt_threshold():
	# If firing too often, increase threshold
	if activation_count > 10:
		threshold = min(threshold * 1.1, base_threshold * 3.0)
	# If rarely firing, decrease threshold  
	elif activation_count < 2:
		threshold = max(threshold * 0.9, base_threshold * 0.3)
	
	activation_count = 0  # Reset counter

func recieve(new_value):
	self.recieved_value += new_value 
	# Safety clamp to prevent runaway accumulation
	self.recieved_value = clamp(self.recieved_value, -100.0, 100.0)
	
	if self.recieved_value >= threshold:
		self.fire()
		# Start timer only after firing
		timer.start(1.0)
	else:
		# If we didn't fire, we might still need to decay over time
		if not timer.time_left > 0:
			timer.start(1.0)
	
func _reset_neuron_state():
	self.state = false
	self.recieved_value = 0
	self.color = Color.WHITE
	queue_redraw()

class OutputN: 
	extends Neurone
	func fire(): super()

class InputN: 
	extends Neurone
	func send(): 
		self.fire()  # Properly call fire method
	
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
