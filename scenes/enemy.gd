extends CharacterBody2D
class_name EnemyAI

@export var neuronalNetwork : NeuronalNetwork
var main
var input_cooldown : int = 0  # Rate limit input signals

func _ready() -> void:
	main = self.get_parent()

func move(value : Vector2):
	self.velocity = value
	# Don't call move_and_slide here - do it in physics_process

func _physics_process(delta: float) -> void:
	# Move the character every frame
	move_and_slide()
	
	# Rate limit input signals - only send every 10 frames (6 times per second)
	input_cooldown += 1
	if input_cooldown < 10:
		return
	input_cooldown = 0
	
	# Send sensor data to input neurons
	var inputs = neuronalNetwork.neurones.filter(func(n : Neurone): return n is Neurone.InputN)
	
	# Make sure we have enough input neurons
	if inputs.size() >= 3:
		# Input 0: X position (normalized 0-1)
		var norm_x = self.position.x / main.MAX_MAP_X
		if norm_x != inputs[0].value: 
			inputs[0].value = norm_x
			inputs[0].send()
			
		# Input 1: Y position (normalized 0-1)
		var norm_y = self.position.y / main.MAX_MAP_Y
		if norm_y != inputs[1].value: 
			inputs[1].value = norm_y
			inputs[1].send()
		
		# Input 2: Collision detection
		var collision_detected = get_slide_collision_count() > 0
		if collision_detected:
			inputs[2].value = 1.0
			inputs[2].send()
			# Use targeted punishment - punish the specific action that caused collision
			neuronalNetwork.punish_specific_action(0.1)  # Strong targeted punishment
		else: 
			inputs[2].value = 0.0
			# Significant reward for moving without colliding
			if velocity.length() > 0:  # Only reward if actually moving
				neuronalNetwork.approve(0.05)  # Much stronger reward
