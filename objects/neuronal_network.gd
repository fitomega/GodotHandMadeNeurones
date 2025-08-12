extends Node2D
class_name NeuronalNetwork

var neurones = Array([], TYPE_OBJECT, "Node", Neurone)
var connections = []
@export var Enemy : EnemyAI
var active_neurones

# Learning parameters
var base_learning_rate : float = 0.05
var learning_rate : float = 0.05
var adaptation_timer : int = 0
var max_connections : int = 50  # Limit total connections to prevent memory explosion
var reset_cooldown : int = 0  # Pause learning after emergency reset
var exploration_bonus : float = 0.1  # Encourage trying different actions
var last_fired_output : Neurone = null  # Track which output fired last

#test
var process_time = 0

func _ready() -> void:
	# Create output neurons with higher thresholds (need more input to fire)
	var n0 : Neurone = Neurone.OutputN.new("N" + str(1) + "| Output", 1, 2.0)
	var n1 : Neurone = Neurone.OutputN.new("N" + str(2) + "| Output", 1, 2.0)
	var n2 : Neurone = Neurone.OutputN.new("N" + str(3) + "| Output", 1, 2.0)
	var n3 : Neurone = Neurone.OutputN.new("N" + str(4) + "| Output", 1, 2.0)
	neurones.append(n0)
	n0.value = Vector2(20, 0)
	n0.fired.connect(func(value): 
		track_output_firing(n0)
		Enemy.move(value))
	
	neurones.append(n1)
	n1.value =  Vector2(0, 20)
	n1.fired.connect(func(value): 
		track_output_firing(n1)
		Enemy.move(value))
	
	neurones.append(n2)
	n2.value =  Vector2(-20, 0)
	n2.fired.connect(func(value): 
		track_output_firing(n2)
		Enemy.move(value))
	
	neurones.append(n3)
	n3.value =  Vector2(0, -20)
	n3.fired.connect(func(value): 
		track_output_firing(n3)
		Enemy.move(value))
	
	# Input neurons with lower thresholds (easier to activate from sensors)
	# Input 0: X position, Input 1: Y position, Input 2: Collision
	neurones.append(Neurone.InputN.new("N5| Input X", 0.0, 0.5))
	neurones.append(Neurone.InputN.new("N6| Input Y", 0.0, 0.5))
	neurones.append(Neurone.InputN.new("N7| Input Collision", 0.0, 0.5))
	# Middle neurons with moderate thresholds
	for i in range(10, 35): neurones.append(Neurone.MiddleN.new("N" + str(i) + "| Middle", 1, 1.5))
	
	neurones.any(func(n:Neurone): 
		self.add_child(n)
		n.position.x = randi_range(20, 500)
		n.position.y = randi_range(20, 500)
	)
	
	# Clamp weights immediately in case of restart
	clamp_all_weights()
	
func _process(delta: float) -> void:
	process_time += 1
	# Count down reset cooldown
	if reset_cooldown > 0:
		reset_cooldown -= 1
		if reset_cooldown == 0:
			print("Learning cooldown ended, resuming...")
			
	active_neurones = neurones.filter(func(n): return n.state == true)
	
	# active_neurones.any(func(n : Neurone): print(n is Neurone.OutputN))
	
	for n1 : Neurone in active_neurones:
		active_neurones.any(
			func(n2): 
				if(n1 == n2): return false
				elif(n1 is Neurone.OutputN): return false
				elif(n1 is Neurone.MiddleN && n2 is Neurone.InputN): return false
				elif(n1 is Neurone.InputN && n2 is Neurone.InputN): return false
				elif n1.connections.filter(func(c : Connection): return c.target == n2 || c.origin == n2).size() == 0:
					# Only create new connections if under the limit
					if connections.size() < max_connections:
						print(n1.id, "->", n2.id, " delta: " + str(process_time))
						var new_conn = Connection.new(n1.id + " " + n2.id, n1, n2)
						connections.append(new_conn)
						self.add_child(new_conn)
				elif n1.connections.filter(func(c : Connection): return c.target == n2 || c.origin == n2).size() >= 0:
					# Connection exists - reinforce it with proper bounds
					n1.connections.any(
						func(c:Connection):
							if( c.target == n2 || c.origin == n2): 
								# Use controlled learning rate and enforce bounds
								c.weight = min(c.weight + (0.01 * learning_rate), 2.0))
		)

	# Frequently clamp weights to prevent explosion
	if process_time % 10 == 0:
		clamp_all_weights()
		
	# Adapt neuron thresholds periodically
	if process_time % 100 == 0:
		adapt_network()
	
	# Add exploration - randomly stimulate different neurons
	if process_time % 120 == 0:
		explore_network()
	
	#temporarely auto stimulate
	if (process_time < 1000 && process_time % 50 == 0): first_stimulate()
	
func first_stimulate():
	var inputs = neurones.filter(func(n): return n is Neurone.InputN)
	neurones.pick_random().recieve(10)
	
# Encourage exploration by stimulating underused output neurons
func explore_network():
	var outputs = neurones.filter(func(n): return n is Neurone.OutputN)
	for output in outputs:
		# If this output hasn't been used much, give it a boost
		if output != last_fired_output:
			print("Exploring: stimulating ", output.id)
			output.recieve(1.0)  # Small exploration stimulus

# Clamp all connection weights to prevent explosion
func clamp_all_weights():
	connections.any(func(c: Connection): 
		c.weight = clamp(c.weight, -2.0, 2.0)
	)
	
# Help recover dead networks by slowly pushing weights toward neutral
func weight_recovery():
	var all_negative = true
	var avg_weight = 0.0
	
	for c in connections:
		avg_weight += c.weight
		if c.weight > -0.9:
			all_negative = false
			
	if connections.size() > 0:
		avg_weight /= connections.size()
		
	# If network is too negative, apply stronger recovery
	if avg_weight < -0.5:
		print("Network too negative (avg: ", avg_weight, "), applying recovery...")
		connections.any(func(c: Connection): 
			# Stronger push toward neutral
			c.weight += 0.02  # Much faster recovery
		)
		
	# Emergency reset if network is getting too negative
	if avg_weight < -0.8:
		print("Network severely negative, emergency reset!")
		connections.any(func(c: Connection): 
			# Reset to more positive values
			c.weight = randf_range(-0.1, 0.3)  # Slightly positive bias
		)
		reset_cooldown = 300  # Pause learning for 5 seconds
	
# Adapt the entire network's thresholds and learning rate
func adapt_network():
	neurones.any(func(n: Neurone): n.adapt_threshold())
	# Adaptive learning rate - decrease over time for stability
	learning_rate = base_learning_rate * exp(-process_time / 5000.0)
	# Help recover dead networks
	weight_recovery()
	# Clamp weights every adaptation cycle
	clamp_all_weights()
	
# Track which output neuron fired
func track_output_firing(output_neuron: Neurone):
	last_fired_output = output_neuron

# Targeted punishment - only punish the specific action that caused collision
func punish_specific_action(value: float):
	if last_fired_output != null and reset_cooldown <= 0:
		var adjusted_value = value * learning_rate
		print("Punishing connections to: ", last_fired_output.id)
		# Only punish connections TO the problematic output neuron
		for c in connections:
			if c.target == last_fired_output:
				c.weight = max(c.weight - adjusted_value * 2.0, -1.0)  # Stronger punishment
				
# Improved punishment system with adaptive learning rate
func punish(value : float):
	var adjusted_value = value * learning_rate
	active_neurones.any(
		func(n : Neurone): 
			n.connections.any(func(c : Connection): 
				# Don't let weights go too negative
				c.weight = max(c.weight - adjusted_value, -1.0)
			)
	)
	
# Improved approval system with adaptive learning rate
func approve(value : float):
	var adjusted_value = value * learning_rate
	active_neurones.any(
		func(n : Neurone): 
			n.connections.any(func(c : Connection): 
				# Cap positive weights to prevent explosion
				c.weight = min(c.weight + adjusted_value, 2.0)
			)
	)
