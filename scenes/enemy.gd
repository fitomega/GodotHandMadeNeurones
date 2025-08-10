extends CharacterBody2D
class_name EnemyAI

@export var neuronalNetwork : NeuronalNetwork

func move(value : Vector2):
	self.velocity = value
	

func _process(delta: float) -> void:
	move_and_slide() #if I put the move and slide on the move function it will only move each time move is called
