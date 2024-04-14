extends Node3D

var water_speed = 0.25  # Speed of water movement
var water_height = 0.15  # Maximum height of water
var time_accumulator = 0.0

func _physics_process(delta):
	time_accumulator += delta
	
	# Calculate the position of the water using sine function
	var offset = sin(time_accumulator / 3.0 * PI) * water_height / 2.0
	
	# Set the position of the water
	$water.position.y = offset
