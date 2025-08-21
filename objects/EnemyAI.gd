extends CharacterBody2D
class_name EnemyAI
@export var neuronalNetwork : NeuronalNetwork
const SPEED = 20
@export var target : Node2D
@export var food : Node2D
var hunger = 0.0

var main : Main

func _ready() -> void:
	main = get_tree().get_root().get_children()[0]

func move(value):
	self.velocity = value * SPEED
	
	
func seek_player():
	print("seeking_player")
	velocity = self.position.direction_to(target.position) * SPEED

func seek_food():
	print("seeking_food")
	velocity = self.position.direction_to(food.position) * SPEED
	
func _process(delta: float) -> void:
	print(main.get_frame())
	"""
	var inputs = neuronalNetwork.neurones.filter(func(n : Neurone): return n.type == Neurone.types.INPUT)

	inputs[0].value = (self.position.x - 0) / (1152 - 0)
	inputs[0].recieve(1)

	inputs[1].value = (self.position.y - 0) / (1152 - 0)
	inputs[1].recieve(1)
		
	if(self.get_slide_collision_count() > 0): 
		inputs[2].recieve(1)
		neuronalNetwork.punishment()
	move_and_slide()
	var InputHunger : Neurone =  neuronalNetwork.neurones.filter(func(n:Neurone): return n.id == "InputHunger")[0]
	InputHunger.value = hunger
	InputHunger.fire()
	
	"""
	
