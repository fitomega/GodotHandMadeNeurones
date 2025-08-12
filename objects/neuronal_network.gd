extends Node2D
class_name NeuronalNetwork

var neurones = Array([], TYPE_OBJECT, "Node", Neurone)
var connections = []
@export var Enemy : EnemyAI
var active_neurones

#test
var process_time = 0

func _ready() -> void:
	# Rellenamos las neuronas de forma random
	var n0 : Neurone = Neurone.OutputN.new("N" + str(1) + "| Output", 1, 1)
	var n1 : Neurone = Neurone.OutputN.new("N" + str(2) + "| Output", 1, 1)
	var n2 : Neurone = Neurone.OutputN.new("N" + str(3) + "| Output", 1, 1)
	var n3 : Neurone = Neurone.OutputN.new("N" + str(4) + "| Output", 1, 1)
	neurones.append(n0)
	n0.value = Vector2(20, 0)
	n0.fired.connect(func(value): 
		Enemy.move(value))
	
	neurones.append(n1)
	n1.value =  Vector2(0, 20)
	n1.fired.connect(func(value): Enemy.move(value))
	
	neurones.append(n2)
	n2.value =  Vector2(-20, 0)
	n2.fired.connect(func(value): Enemy.move(value))
	
	neurones.append(n3)
	n3.value =  Vector2(0, -20)
	n3.fired.connect(func(value): Enemy.move(value))
	
	for i in range(2, 5): neurones.append(Neurone.InputN.new("N" + str(i) + "| Input", 1, 1))
	for i in range(10, 15): neurones.append(Neurone.MiddleN.new("N" + str(i) + "| Middle", 1, 1))
	
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
				elif(n1 is Neurone.InputN && n2 is Neurone.InputN): return false
				elif n1.connections.filter(func(c : Connection): return c.target == n2 || c.origin == n2).size() == 0:
					print(n1.id, "->", n2.id, " delta: " + str(process_time))
					var new_conn = Connection.new(n1.id + " " + n2.id, n1, n2)
					connections.append(new_conn)
					self.add_child(new_conn)
				elif n1.connections.filter(func(c : Connection): return c.target == n2 || c.origin == n2).size() >= 0:
					n1.connections.any(
						func(c:Connection):
							if( c.target == n2 || c.origin == n2): 
								c.weight += 0.1)
		)

	#temporarely auto stimulate
	if (process_time < 1000 && process_time % 50 == 0): first_stimulate()
	
func first_stimulate():
	var inputs = neurones.filter(func(n): return n is Neurone.InputN)
	neurones.pick_random().recieve(10)

func punish(value : float):
	active_neurones.any(
		func(n : Neurone): n.connections.any(func(c : Connection): if(c.weight > 0): c.weight -= value)
	)
func approve(value : float):
	active_neurones.any(
		func(n : Neurone): n.connections.any(func(c : Connection): if(c.weight > 0): c.weight += value)
	)
