extends CanvasLayer

var scoreP1
var scoreP2
@export var scoreLimit = 15

signal game_end

enum{ PLAYER1, PLAYER2 }

# Called when the node enters the scene tree for the first time.
func _ready():
	set_score(PLAYER1, 0)
	set_score(PLAYER2, 0)

func set_score(playerID, score):
	if(playerID == PLAYER1):
		scoreP1 = score;
		$ScoreLabelP1.text = str(scoreP1)
		if scoreP1 >= scoreLimit:
			$VictoryLabel.text = "Player1 wins"
			$VictoryLabel.visible = true
			game_end.emit()
	elif(playerID == PLAYER2):
		scoreP2 = score
		$ScoreLabelP2.text = str(scoreP2)
		if scoreP2 >= scoreLimit:
			$VictoryLabel.text = "Player2 wins"
			$VictoryLabel.visible = true
			game_end.emit()

func up_score(playerID):
	if(playerID == PLAYER1):
		set_score(PLAYER1, scoreP1+1)
	elif(playerID == PLAYER2):	
		set_score(PLAYER2, scoreP2+1)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
