extends Node2D
class_name NeuronalNetwork

@export var enemy : EnemyAI

var neurones = []
var connections = []
var active_neurones = []
var timer = 0.0
var _log = []
func _ready() -> void:
	pass
	#neurones[0].recieve(10)

func _process(delta: float) -> void:
	#timer += delta
	#if(timer < 60): 
		#initial_random_activation()

	create_connection()
func setup_network():
	var inputX = Neurone.new("Input-Pos-X", 1, Neurone.types.INPUT)
	var inputY = Neurone.new("Input-Pos-Y", 1, Neurone.types.INPUT)
	var inputHunger = Neurone.new("InputHunger", 1, Neurone.types.INPUT)
	var inputPlayerInRange = Neurone.new("InputPlayerInRange", 1, Neurone.types.INPUT)
	var inputPlayerHeard = Neurone.new("InputPlayerHeard", 1, Neurone.types.INPUT)
	var inputCloseToFood = Neurone.new("InputCloseToFood", 1, Neurone.types.INPUT)
	var inputFlashed = Neurone.new("InputFlashed", 1, Neurone.types.INPUT)
	
	neurones.append(inputX)
	neurones.append(inputY)
	neurones.append(inputHunger)
	neurones.append(inputPlayerInRange)
	neurones.append(inputPlayerHeard)
	neurones.append(inputCloseToFood)
	neurones.append(inputFlashed)
	
	var outputSeekPlayer = Neurone.new("outputSeekPlayer", 1, Neurone.types.OUTPUT)
	var outputAvoidPlayer = Neurone.new("outputAvoidPlayer", 1, Neurone.types.OUTPUT)
	var outputHideFromPlayer = Neurone.new("outputHideFromPlayer", 1, Neurone.types.OUTPUT)
	var outputSeekFood = Neurone.new("outputSeekFood", 1, Neurone.types.OUTPUT)

	neurones.append(outputSeekPlayer)
	neurones.append(outputAvoidPlayer)
	neurones.append(outputHideFromPlayer)
	neurones.append(outputSeekFood)


	outputSeekPlayer.fired.connect(func(n): enemy.seek_player())
	outputSeekPlayer.fired.connect(func(n): enemy.seek_food())
	
	for i in range(0, 10): neurones.append(Neurone.new("Middle" + str(i), 1, Neurone.types.MIDDLE))
	
	neurones.any(func(n): self.add_child(n))
	
	neurones.any(func(n): n.position = Vector2(randi_range(0, 500), randi_range(0, 500)))
	
	
func run_network(): 
	pass
func backpropagation(): pass #Not decided if its ideal
func initial_random_activation():
	neurones.pick_random().recieve(10)
func create_connection():
	active_neurones = neurones.filter(func(n): return n.state == true)
	
	# active_neurones.any(func(n : Neurone): print(n is Neurone.OutputN))
	
	for n1 : Neurone in active_neurones:
		active_neurones.any(
			func(n2): 
				if(n1 == n2): return false
				elif(n1.type == Neurone.types.OUTPUT): return false
				elif(n1.type == Neurone.types.MIDDLE && n2.type == Neurone.types.INPUT): return false
				elif(n1.type == Neurone.types.INPUT && n2.type == Neurone.types.OUTPUT): return false
				elif(n1.type == Neurone.types.INPUT && n2.type == Neurone.types.INPUT): return false
				elif connections.filter(func(c : Connection): return c.origin == n1 && c.target == n2 || c.origin == n2 && c.target == n1).size() == 0:
					print(n1.name, "->", n2.name)
					var new_conn = Connection.new(n1.name + " " + n2.name, n1, n2, randf_range(-0.5, 0.5))
					connections.append(new_conn)
					self.add_child(new_conn)
				elif connections.filter(func(c : Connection): return c.origin == n1 && c.target == n2 || c.origin == n2 && c.target == n1).size() > 0:
					var connetion_with_n2 : Connection = connections.filter(func(c : Connection): return c.origin == n1 && c.target == n2 || c.origin == n2 && c.target == n1)[0]
					connetion_with_n2.weight += 0.001
		)
func punishment():
	var fired_connections = _log.filter(func(s : String): return s.to_lower().contains("connection") && s.contains("fired"))
	for f:String in fired_connections:
		connections.any(func(c : Connection): 
			if(c.name == f.split("|")[0]): 
				c.weight -= 0.02
		)
func logConnectionFired(connection_name):
	_log.append(str(connection_name) + "|" + "connection" + "|" + "fired" + "|" + str(timer))
	if(_log.size() > 10): _log.pop_front()
