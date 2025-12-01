extends Node2D

@export var speed = 2.0;

var rng;

func wait(seconds: float) -> void:
	await get_tree().create_timer(seconds).timeout;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng = RandomNumberGenerator.new();
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	transform.origin = transform.origin + Vector2(speed, 0);


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	# Wait for a random amount of time then start the tumbleweed again
	var waitTime = rng.randf_range(3.0,15.0);
	await wait(waitTime);
	transform.origin.x = 0
