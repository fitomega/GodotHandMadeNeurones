extends Node2D
class_name Main
const MAX_SCENE_WIDTH = 1152
const MIN_SCENE_WIDTH = 0
const MAX_SCENE_HEIGHT = 648
const MIN_SCENE_HEIGHT = 0

var time = 0.0
var frame = 0.0

func _process(delta: float) -> void:
	frame = delta
	time += delta
	
func get_time():
	return time

func get_frame():
	return frame
