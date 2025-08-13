extends Node2D
class_name Connection

var weight = 0.0
var origin : Neurone
var targert : Neurone

func _init(origin : Neurone, target : Neurone, weight) -> void:
	self.origin = origin
	self.targert = target
	self.weight = weight
	
	self.origin.connections.append(self)
	
func fire(origin : Neurone, value):
	self.target.recieve(value * weight)
