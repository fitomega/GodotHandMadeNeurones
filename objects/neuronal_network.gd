extends Node2D
class_name NeuronalNetwork

var neurones = Array([], TYPE_OBJECT, "Node", Neurone)
var connections = []

var active_neurones

#test
var process_time = 0

func _ready() -> void:
	# Rellenamos las neuronas de forma random
	for i in range(1, 5): neurones.append(Neurone.InputN.new("N" + str(i) + "| Input", 0, 0))
	for i in range(5, 10): neurones.append(Neurone.OutputN.new("N" + str(i) + "| Output", 0, 0))
	for i in range(10, 15): neurones.append(Neurone.MiddleN.new("N" + str(i) + "| Middle", 0, 0))
	
	neurones.any(func(n:Neurone): 
		self.add_child(n)
		n.position.x = randi_range(20, 500)
		n.position.y = randi_range(20, 500)
	)
	
func _process(delta: float) -> void:
	process_time += 1
	active_neurones = neurones.filter(func(n): return n.state == true)
	
	# active_neurones.any(func(n : Neurone): print(n is Neurone.OutputN))
	
	for n1 : Neurone in active_neurones:
		active_neurones.any(
			func(n2): 
				if(n1 == n2): return false
				elif(n1 is Neurone.OutputN): return false
				elif(n1 is Neurone.MiddleN && n2 is Neurone.InputN): return false
				elif n1.connections.filter(func(c : Connection): return c.target == n2 || c.origin == n2).size() == 0:
					print(n1.id, "->", n2.id, " delta: " + str(process_time))
					var new_conn = Connection.new(n1.id + " " + n2.id, n1, n2)
					connections.append(new_conn)
					self.add_child(new_conn)
		)
