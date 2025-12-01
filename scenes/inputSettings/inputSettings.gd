extends Control

# Loads the scene used for the btns
@onready var inputBtnScene = preload("res://scenes/inputSettings/inputBtn.tscn");
# Get the list where to add btns
@onready var actionList = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList

var isRemapping = false;
var actionToRemap = null;
var remappingBtn = null;

var inputActions = {
	"move_left_p1"		:	"Player 1 - Move Left",
	"move_right_p1"		:	"Player 1 - Move Right",
	"action_attack_p1"	:	"Player 1 - Attack Stance",
	"action_guard_p1"	:	"Player 1 - Block Stance",
	"action_bait_p1"	:	"Player 1 - Bait Stance",
	"action_high_p1"	:	"Player 1 - Action High",
	"action_mid_p1"		:	"Player 1 - Action Middle",
	"action_low_p1"		:	"Player 1 - Action Low",
	
	"move_left_p2"		:	"Player 2 - Move Left",
	"move_right_p2"		:	"Player 2 - Move Right",
	"action_attack_p2"	:	"Player 2 - Attack Stance",
	"action_guard_p2"	:	"Player 2 - Block Stance",
	"action_bait_p2"	:	"Player 2 - Bait Stance",
	"action_high_p2"	:	"Player 2 - Action High",
	"action_mid_p2"		:	"Player 2 - Action Middle",
	"action_low_p2"		:	"Player 2 - Action Low"
}

func createActionList() : 
	InputMap.load_from_project_settings();
	
	# empty the action list (if it had anything)
	for item in actionList.get_children():
		item.queue_free();
		
	for action in inputActions :
		var btn = inputBtnScene.instantiate();
		var actionLabel = btn.find_child("labelAction");
		var inputLabel = btn.find_child("labelInput");
		
		actionLabel.text = inputActions[action];
		# get the inputs mapped to this action
		var events = InputMap.action_get_events(action);

		# Filter for keyborard inputs
		if events.size() > 0 and events[0] is InputEventKey:
			inputLabel.text = events[0].as_text().trim_suffix(" (Physical)");
		else : 
			inputLabel.text = "";
			
		actionList.add_child(btn);
		btn.pressed.connect(_on_input_button_pressed.bind(btn, action));

func _on_input_button_pressed(btn, action) :
	if !isRemapping:
		isRemapping = true;
		actionToRemap = action;
		remappingBtn = btn;
		btn.find_child("labelInput").text = "Press key to bind...";
		
func _input(event):
	if isRemapping:
		# We only accept keyboard input
		if(event is InputEventKey) :
			var currentKeys = InputMap.action_get_events(actionToRemap);
			var keyToRemove = null;
			
			# Check for the current keyboard key bound to this action 
			for key in currentKeys :
				if key is InputEventKey :
					keyToRemove = key;
					break;
			
			# Remove the previous key bound and add the new key
			InputMap.action_erase_event(actionToRemap, keyToRemove);
			InputMap.action_add_event(actionToRemap, event);
			
			# Update the menu
			_update_action_list(remappingBtn, event);
			
			# reset buffers
			isRemapping = false;
			actionToRemap = null;
			remappingBtn = null;
			
			# Stop event propagation
			accept_event();

func _update_action_list(remapBtn, event):
	remapBtn.find_child("labelInput").text = event.as_text().trim_suffix(" (Physical)");

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	createActionList();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_reset_btn_pressed() -> void:
	createActionList();
