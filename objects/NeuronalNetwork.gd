extends Node2D
class_name NeuronalNetwork

@export var enemy : EnemyAI

var neurones = []
var connections = []

func _ready() -> void:
	setup_network()
	#neurones[0].recieve(10)

func setup_network():
	var input1 = Neurone.new()
	neurones.append(input1)
	neurones.any(func(n): self.add_child(n))
func run_network(): pass
func backpropagation(): pass #Not decided if its ideal
