extends Control



@onready var beachStageBtn = $beach/BeachStageBtn;
@onready var cityStageBtn = $city/CityStageBtn;
@onready var westernStageBtn = $western/WesternStageBtn;
@onready var howToPlayStageBtn = $howToPlay/HowToPlayBtn;

@onready var sceneBtns = {
	"res://scenes/beach_stage.tscn"		: beachStageBtn,
	"res://scenes/city_stageV3.scn"		: cityStageBtn,
	"res://scenes/western_stage.tscn"	: westernStageBtn
	};

func _on_menuBtn_pressed():
	$howToPlayMenu.visible = true;

func _on_stageBtn_pressed(sceneName):
	# Prevent from multiple clicks
	for btn in sceneBtns.values():
		btn.disabled = true;
	get_tree().change_scene_to_file(sceneName);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# connect each btn to load the correct scene
	for sceneName in sceneBtns.keys():
		sceneBtns.get(sceneName).pressed.connect(_on_stageBtn_pressed.bind(sceneName));
		
