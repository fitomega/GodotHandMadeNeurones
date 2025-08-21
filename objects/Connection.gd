extends Node2D
class_name Connection

var weight = 0.0
var origin : Neurone
var target : Neurone

func _draw() -> void:
	draw_line(self.origin.position, self.target.position, Color.WHITE, 1)

func _init(id : String, origin : Neurone, target : Neurone, weight) -> void:
	self.name = id
	self.origin = origin
	self.target = target
	self.weight = weight
	
	self.origin.connections.append(self)
	
func fire(origin : Neurone, value):
	self.target.recieve(value * weight)
	self.get_parent().logConnectionFired(self.name)
