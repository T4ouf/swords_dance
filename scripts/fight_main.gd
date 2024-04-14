extends Node2D

@export var score_limit = 15

var player1_score = 0
var player2_score = 0
var p1_initial_position : Vector2
var p2_initial_position : Vector2

@onready var player1 = $Player1
@onready var player2 = $Player2

# Called when the node enters the scene tree for the first time.
func _ready():
	p1_initial_position = player1.position
	p2_initial_position = player2.position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_1_round_win():
	print("p1 won")
	player1_score += 1
	if player1_score >= score_limit:
		pass
	start()


func _on_player_2_round_win():
	print("p2 won")
	
	player2_score += 1
	if player2_score >= score_limit:
		pass
	start()

func start():
	for player in [player1, player2]:
		if player.animation_player.is_playing():
			await player.animation_player.animation_finished
			
		player.velocity = Vector2.ZERO
		player.wait = false

	player1.position = p1_initial_position
	player2.position = p2_initial_position
	
	
