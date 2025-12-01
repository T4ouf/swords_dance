extends Control

const MAXPAGENUM : int = 4;

func _on_pageBtn_pressed(pageID):
	for i in range(MAXPAGENUM):
		var node = get_node("Page"+str(i+1));
		node.visible = false;
		
	get_node("Page"+str(pageID)).visible = true;
	
func _on_exitBtn_pressed():	
	self.visible = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	$HowToPlayBtn.pressed.connect(_on_pageBtn_pressed.bind(1));
	$ControllerBtn.pressed.connect(_on_pageBtn_pressed.bind(2));
	$KeyboardBtn.pressed.connect(_on_pageBtn_pressed.bind(3));
	$StageListBtn.pressed.connect(_on_pageBtn_pressed.bind(4));
	$ExitBtn.pressed.connect(_on_exitBtn_pressed.bind());
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
