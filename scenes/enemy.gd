extends CharacterBody2D
class_name EnemyAI

@export var neuronalNetwork : NeuronalNetwork
var main

func _ready() -> void:
	main = self.get_parent()

func move(value : Vector2):
	self.velocity = value
	move_and_slide() #if I put the move and slide on the move function it will only move each time move is called

	

func _physics_process(delta: float) -> void:
	#sends the movument
	var inputs = neuronalNetwork.neurones.filter(func(n : Neurone): return n is Neurone.InputN)
	
	
	if self.position.x != inputs[0].value: 
		inputs[0].value =( self.position.x - 0) / (main.MAX_MAP_X - 0)
		inputs[0].send()
	if self.position.y != inputs[1].value: 
		inputs[1].value = ( self.position.y - 0) / (main.MAX_MAP_Y - 0)
		inputs[1].send()
	
	if get_slide_collision_count() > 0:
		inputs[2].value = 1
		inputs[2].send()
		neuronalNetwork.punish(0.1)
	else: 
		inputs[2].value = 0
