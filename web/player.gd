extends CharacterBody2D

@export var dummy = false
@export var run_speed = 200
@export var jump_speed = -600
@export var gravity = 1200

const _type = "PLAYER"
const SHOOTING_SPEED = 2
const WORLD_SIZE = 1024

@export var currentAnim = "idle"
@export var currentAnimFlip = false
var jumping = false
# cannot use the visible flag, as we want our player only to modulate
@export var invisible = false 
@export var discussionMode = false
var dead = false


func _enter_tree():
	$MultiplayerSynchronizer.set_multiplayer_authority(name.to_int())
	$NameLabel.text = ""
	discussionMode = dummy

func get_input():
	if dead:
		return
	velocity.x = 0
	var right = Input.is_action_pressed('right')
	var left = Input.is_action_pressed('left')
	var jump = Input.is_action_just_pressed('up')
	var toggleInvisible = Input.is_action_just_pressed('ui_accept')
	
	if Input.is_key_pressed(KEY_1):
		rpc("showMeme", 0)
	if Input.is_key_pressed(KEY_2):
		rpc("showMeme", 1)
	if Input.is_key_pressed(KEY_3):
		rpc("showMeme", 2)
	if Input.is_key_pressed(KEY_4):
		rpc("showMeme", 3)
		
	if discussionMode && Input.is_action_just_pressed('ui_shoot') && $bullet_time_r.is_stopped() && !invisible:
		rpc("fire")
	
	if toggleInvisible:
		invisible = !invisible
		rpc("set_visibility", !invisible)
	
	if jump and is_on_floor():
		jumping = true
		velocity.y = jump_speed
	if right:
		velocity.x += run_speed
	if left:
		velocity.x -= run_speed
	
func _process(_delta):
	
	if invisible:
		$AnimatedSprite2D.modulate.a = 0.5
	else:
		$AnimatedSprite2D.modulate.a = 1
	
	if isSelf():
		if dead:
			currentAnim = "hit"
		elif velocity.y < 0:
			currentAnim = "jump"
		elif velocity.x < 0:
			currentAnimFlip = true
			currentAnim = "run"
		elif velocity.x > 0:
			currentAnimFlip = false
			currentAnim = "run"
		else:
			currentAnim = "idle"
	
	$gun.enabled = discussionMode
	$gun.flipped = currentAnimFlip
	$AnimatedSprite2D.flip_h = currentAnimFlip
	$AnimatedSprite2D.play(currentAnim)

func isSelf():
	return $MultiplayerSynchronizer.is_multiplayer_authority()

func _physics_process(delta):
	if dummy or isSelf():
		get_input()
		velocity.y += gravity * delta
		if jumping and is_on_floor():
			jumping = false
		set_up_direction(Vector2(0, -1))
		move_and_slide()

@rpc("any_peer")
func set_visibility(vis):
	visible = vis
	var pointSignals = get_tree().get_root().get_node("root/world/points")
	if pointSignals.has_method("visibilityChanged"):
		pointSignals.visibilityChanged(visible)
	

@rpc("any_peer")
func setCollision(active):
	set_collision_mask_value(1, active)
	pass
	

func hit(bulletPos: Vector2):
	if invisible || !visible: 
		return false
	if bulletPos.x < position.x:
		velocity.x = 100
	else:
		velocity.x = -100
	dead = true
	return true
	
@rpc("any_peer", "call_local") 
func fire():
	$bullet_time_r.start(SHOOTING_SPEED)
	$gun.fire(position)

const memes = [
	preload("res://sprites/memes/overload.png"),
	preload("res://sprites/memes/okguy.png"),
	preload("res://sprites/memes/yuno.png"),
	preload("res://sprites/memes/megusta.png"),
]

@rpc("any_peer", "call_local") 
func showMeme(number):
	$emote/Timer.stop()
	$emote.texture = memes[number]
	$emote.show()
	$emote/AnimationPlayer.play("pop")
	$emote/Timer.start()

func _on_Emote_Timer_timeout():
	$emote.hide()

func _on_AnimatedSprite_animation_finished():
	if currentAnim == "hit":
		currentAnim = "idle"
		dead = false

func _debug_timer():
	$gun.fire(position)
