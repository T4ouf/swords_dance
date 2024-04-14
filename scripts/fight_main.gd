extends Node2D

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
	$FightUi.up_score($FightUi.PLAYER1)
	await player2.animation_player.animation_finished
	print("p1 won")
	start()


func _on_player_2_round_win():
	$FightUi.up_score($FightUi.PLAYER2)
	await player1.animation_player.animation_finished
	print("p2 won")
	start()

func start():
	for player in [player1, player2]:
		# while player.animation_player.is_playing() && not player.animation_player.current_animation == "idle":
		# 	await player.animation_player.animation_finished
		# 	
		player.velocity = Vector2.ZERO
		player.wait = false

	player1.position = p1_initial_position
	player1.animation_player.play("idle")
	player1.idling = true
	player2.position = p2_initial_position
	player2.animation_player.play("idle")
	player2.idling = true
	

func _on_fight_ui_game_end():
	$ReturnToMainTimer.start(3)

func _on_return_to_main_timer_timeout():
	get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
