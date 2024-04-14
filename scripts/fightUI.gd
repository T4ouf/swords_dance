extends CanvasLayer

var scoreP1
var scoreP2
@export var scoreLimit = 15

signal limitReached;

enum{ PLAYER1, PLAYER2 }

# Called when the node enters the scene tree for the first time.
func _ready():
	set_score(PLAYER1, 0)
	set_score(PLAYER2, 0)

func set_score(playerID, score):
	if(score>=scoreLimit):
		limitReached.emit();
	
	if(playerID == PLAYER1):
		scoreP1 = score;
		$ScoreLabelP1.text = str(scoreP1)
	elif(playerID == PLAYER2):
		scoreP2 = score
		$ScoreLabelP2.text = str(scoreP2)

func up_score(playerID):
	
	if(playerID == PLAYER1):
		set_score(PLAYER1, scoreP1+1)
	elif(playerID == PLAYER2):	
		set_score(PLAYER2, scoreP2+1)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	up_score(PLAYER1)
	up_score(PLAYER2)
	pass
