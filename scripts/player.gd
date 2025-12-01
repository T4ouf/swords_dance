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
@onready var action_bait = "action_bait_p%d" % player_number
@onready var action_other = "action_other_p%d" % player_number
@onready var action_low = "action_low_p%d" % player_number
@onready var action_mid = "action_mid_p%d" % player_number
@onready var action_high = "action_high_p%d" % player_number

var opponent : CharacterBody2D
var opponent_sword : CollisionPolygon2D
var opponent_hitbox : CollisionShape2D
var opponent_animator : AnimationPlayer

var idling = true
var guarding = false
var cancelling = false
var wait = false

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
	opponent_animator = opponent.get_node("AnimationPlayer")

	animation_player.play("idle")

	sword.set_deferred("disabled", true)

func _physics_process(delta):
	#velocity.y += delta * gravity
	velocity.y = gravity
	
	# TODO: correctly handle input
	# see https://docs.godotengine.org/en/stable/tutorials/inputs/controllers_gamepads_joysticks.html
	if not idling:
		var _collision = move_and_collide(delta * 0.01 * velocity)
	if idling:# not animation_player.is_playing():
		var direction = 0
		
		if Input.is_action_pressed(move_left_action):
			direction -= 1
			if(player_number == 1) : 
				animation_player.play("walk_forward_left");
			elif(player_number == 2) :
				animation_player.play("walk_backward_right");
			
		elif Input.is_action_pressed(move_right_action):
			direction += 1
			if(player_number == 1) : 
				animation_player.play("walk_backward_right");
			elif(player_number == 2) :
				animation_player.play("walk_forward_left");
		else :
			if animation_player.current_animation != "idle":
				animation_player.play("idle")
			# animation_player.play("idle");
		
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
		if Input.is_action_pressed(action_guard):
			if Input.is_action_pressed(action_low):
				idling = false
				guarding = true
				animation_player.play("guard_low")
			elif Input.is_action_pressed(action_mid):
				idling = false
				guarding = true
				animation_player.play("guard_mid")
			elif Input.is_action_pressed(action_high):
				idling = false
				guarding = true
				animation_player.play("guard_high")
		if Input.is_action_pressed(action_bait):
			if Input.is_action_pressed(action_low):
				idling = false
				animation_player.play("bait_low")
			elif Input.is_action_pressed(action_mid):
				idling = false
				animation_player.play("bait_mid")
			elif Input.is_action_pressed(action_high):
				idling = false
				animation_player.play("bait_high")
		if Input.is_action_pressed(action_other):
			if Input.is_action_pressed(action_low):
				idling = false
				animation_player.play("crouch")
			elif Input.is_action_pressed(action_mid):
				idling = false
				animation_player.play("attack_mid_strong")
			elif Input.is_action_pressed(action_high):
				idling = false
				animation_player.play("jump")


		if not idling:
			velocity.x = 0
		
		move_and_slide()
			
func _on_animation_player_animation_finished(_anim_name):
	animation_player.play("idle")
	idling = true
	guarding = false
	cancelling = false

func reverse_animation():
	animation_player.play_backwards()
	# animation_player.play("", -1, -1)

func _process(_delta):
	if wait:
		return

	var collides_sword = $SwordArea.overlaps_area(opponent.get_node("SwordArea"))
	var collides_body = $SwordArea.overlaps_body(opponent)

	if not guarding and collides_body and not cancelling:
		if not collides_sword:
			opponent_sword.disabled = true
			opponent.animation_player.play("hit")
			idling = false
			opponent.idling = false
			wait = true
			opponent.wait = true
			round_win.emit()
			return
	
	if collides_sword:
		if guarding:
			if not opponent.guarding:
				opponent.cancelling = true
				opponent.reverse_animation()
				guarding = false
				var attack_type = opponent.animation_player.current_animation.split("_")[1]
				animation_player.play("attack_%s" % attack_type)
		elif opponent.guarding:
			cancelling = true
			reverse_animation()
		else:
			var old_velocity = velocity
			velocity.x -= (2 * player_number - 3) * 4 * speed
			cancelling = true
			reverse_animation()
			velocity = old_velocity
			move_and_slide()

	# dead = false
	# swords_collided = false

# func _on_sword_area_body_entered(body):
# 	# print("body")
# 	# foo1 = true
# 	# detect the hitboxes
# 	if not guarding and body == opponent and not cancelling and not opponent.cancelling:
# 		# dead = true
# 		opponent_animator.play("hit")
# 		opponent.idling = false
# 		cancelling = true
# 		
#
#
# func _on_sword_area_area_entered(area):
# 	# print("area")
# 	# foo2 = true
# 	# detect the opponent's sword
# 	# swords_collided = false
# 	if area == opponent.get_node("SwordArea"):
# 		if guarding:
# 			opponent.cancelling = true
# 			opponent.reverse_animation()
# 			guarding = false
# 			animation_player.play("attack_mid")
# 		elif not opponent.guarding and not opponent.cancelling:
# 			var old_velocity = velocity
# 			velocity.x -= (2 * player_number - 3) * 4 * speed
# 			cancelling = true
# 			opponent.cancelling = true
# 			move_and_slide()
# 			velocity = old_velocity
# 		# swords_collided = true
# 		# cancelling = true
# 	
