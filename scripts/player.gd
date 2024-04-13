extends CharacterBody2D

# emmited when this player wins the round
signal round_win

@export var speed = 300.0
@export var jump_velocity = -400.0

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var sword = $SwordArea/SwordHitbox

@onready var player_number = 1 if name == "Player1" else 2
@onready var move_left_action = "move_left_p%d" % player_number
@onready var move_right_action = "move_right_p%d" % player_number
@onready var move_up_action = "move_up_p%d" % player_number
@onready var move_down_action = "move_down_p%d" % player_number
@onready var action_attack = "action_attack_p%d" % player_number
@onready var action_guard = "action_guard_p%d" % player_number
@onready var action_low = "action_low_p%d" % player_number
@onready var action_mid = "action_mid_p%d" % player_number
@onready var action_high = "action_high_p%d" % player_number

var opponent : CharacterBody2D
var opponent_sword : CollisionPolygon2D
var opponent_hitbox : CollisionShape2D

var idling = true
var guarding = false


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
# var last_direction = -1

func _ready():
	var parent = get_parent()
	var children = parent.get_children()
	
	for child in children:
		if child.is_class("CharacterBody2D") and child.get_rid() != get_rid():
			opponent = child
			break
	
	opponent_sword = opponent.get_node("SwordArea/SwordHitbox")
	opponent_hitbox = opponent.get_node("PlayerHitbox")

	animation_player.play("idle")

	sword.set_deferred("disabled", true)

func _physics_process(delta):
	#velocity.y += delta * gravity
	velocity.y = gravity
	
	# TODO: correctly handle input
	# see https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html
	if idling:# not animation_player.is_playing():
		var direction = 0
		
		if Input.is_action_pressed(move_left_action):
			direction -= 1
			
		if Input.is_action_pressed(move_right_action):
			direction += 1
		
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

		# process actions
		if Input.is_action_pressed(action_attack):
			if Input.is_action_pressed(action_low):
				idling = false
				animation_player.play("attack_low")
			elif Input.is_action_pressed(action_mid):
				idling = false
				animation_player.play("attack_mid")
			elif Input.is_action_pressed(action_high):
				idling = false
				animation_player.play("attack_high")
		elif Input.is_action_pressed(action_guard):
			if Input.is_action_pressed(action_low):
				idling = false
				# animation_player.play("guard_low")
			elif Input.is_action_pressed(action_mid):
				idling = false
				animation_player.play("guard_mid")
			elif Input.is_action_pressed(action_high):
				idling = false
				# animation_player.play("guard_high")

			guarding = not idling

		if not idling:
			velocity.x = 0
		# elif Input.is_action_pressed("action_guard"):
		# 	velocity.x = 0
		
	
		move_and_slide()
	else:
		var collision = move_and_collide(delta * velocity)
		if collision != null:
			print(collision.get_local_shape(), " -> ", collision.get_collider_shape())
		if collision != null and collision.get_local_shape() == sword:
			if collision.get_collider_shape() == opponent_sword:
				if opponent.guarding:
					reverse_animation()
					opponent.animation_player.play("attack_mid") # TODO
				else:
					var normal = collision.get_normal()
					normal.y = 0
					velocity = velocity.bounce(normal.normalized())
					sword.disabled = true
					opponent_sword.disabled = true
					#sword.set_deferred("disabled", true)
					#opponent_sword.set_deferred("disabled", true)
					move_and_slide()
			elif collision.get_collider_shape() == opponent_hitbox: # hit the body
				round_win.emit()

func _on_animation_player_animation_finished(_anim_name):
	animation_player.play("idle")
	idling = true
	guarding = false

func reverse_animation():
	var played = animation_player.current_animation_position
	var length = animation_player.current_animation_length
	var current = animation_player.assigned_animation

	#animation_player.stop()
	animation_player.play_backwards(current)
	animation_player.seek(length - played)

func _on_sword_area_body_entered(body):
	# detect the hitboxes
	if body == opponent:
		round_win.emit()

func _on_sword_area_area_entered(area):
	# detect the opponent's sword
	if area == opponent.get_node("SwordArea"):
		velocity.x -= (2 * player_number - 3) * speed
	move_and_slide()
