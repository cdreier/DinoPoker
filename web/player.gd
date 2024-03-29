extends KinematicBody2D

export var dummy = false
export (int) var run_speed = 200
export (int) var jump_speed = -600
export (int) var gravity = 1200

export (String) var playerName = ""

const _type = "PLAYER"
const SHOOTING_SPEED = 2
const WORLD_SIZE = 1024

var velocity = Vector2()

puppet var puppet_pos = Vector2()
puppet var puppet_anim = "idle"
puppet var puppet_animFlip = false
puppet var puppet_discussionMode = false

var currentAnim = "idle"
var jumping = false
# cannot use the visible flag, as we want our player only to modulate
var invisible = false 
var discussionMode = false
var dead = false

# this flags toggels to only sync on every second frame
var shouldSync = true

func _ready():
	$NameLabel.text = playerName

func get_input():
	if dead:
		return
	velocity.x = 0
	var right = Input.is_action_pressed('right')
	var left = Input.is_action_pressed('left')
	var jump = Input.is_action_just_pressed('up')
	var toggleInvisible = Input.is_action_just_pressed('ui_accept')
	
	if Input.is_key_pressed(KEY_1):
		rpc_unreliable("showMeme", 0)
	if Input.is_key_pressed(KEY_2):
		rpc_unreliable("showMeme", 1)
	if Input.is_key_pressed(KEY_3):
		rpc_unreliable("showMeme", 2)
	if Input.is_key_pressed(KEY_4):
		rpc_unreliable("showMeme", 3)
		
	if discussionMode && Input.is_action_just_pressed('ui_shoot') && $bullet_time_r.is_stopped() && !invisible:
		rpc_unreliable("fire")
	
	if toggleInvisible:
		invisible = !invisible
		rpc_unreliable("set_visibility", !invisible)
	
	if jump and is_on_floor():
		jumping = true
		velocity.y = jump_speed
	if right:
		velocity.x += run_speed
	if left:
		velocity.x -= run_speed
	
func _process(delta):
	shouldSync = !shouldSync
	
	if !isSelf():
		$AnimatedSprite.play(puppet_anim)
		$AnimatedSprite.flip_h = puppet_animFlip
		$gun.enabled = puppet_discussionMode
		$gun.flipped = puppet_animFlip
		return
	
	if invisible:
		$AnimatedSprite.modulate.a = 0.5
	else:
		$AnimatedSprite.modulate.a = 1
	
	$gun.enabled = discussionMode
	
	if dead:
		currentAnim = "hit"
	elif velocity.y < 0:
		currentAnim = "jump"
	elif velocity.x < 0:
		$AnimatedSprite.flip_h = true
		$gun.flipped = true
		currentAnim = "run"
	elif velocity.x > 0:
		$AnimatedSprite.flip_h = false
		$gun.flipped = false
		currentAnim = "run"
	else:
		currentAnim = "idle"
	
	$AnimatedSprite.play(currentAnim)
	if shouldSync:
		rset_unreliable("puppet_discussionMode", discussionMode)
		rset_unreliable("puppet_anim", currentAnim)
		rset_unreliable("puppet_animFlip", $AnimatedSprite.flip_h)

func isSelf():
	return is_network_master()

func _physics_process(delta):
	if dummy:
		get_input()
		return
	if isSelf():
		get_input()
		velocity.y += gravity * delta
		if jumping and is_on_floor():
			jumping = false
		# TODO: perhaps only move when not dead?
		velocity = move_and_slide(velocity, Vector2(0, -1))
		rset_unreliable("puppet_pos", position)
	else:
		position = puppet_pos

puppet func set_visibility(vis):
	visible = vis
	var pointSignals = get_tree().get_root().get_node("root/world/points")
	if pointSignals.has_method("visibilityChanged"):
		pointSignals.visibilityChanged(visible)
	

remote func setCollision(active):
	set_collision_mask_bit(1, active)

func hit(bulletPos: Vector2):
	if invisible || !visible: 
		return false
	if bulletPos.x < position.x:
		velocity.x = 100
	else:
		velocity.x = -100
	dead = true
	return true
	
puppetsync func fire():
	$bullet_time_r.start(SHOOTING_SPEED)
	$gun.fire(position)

const memes = [
	preload("res://sprites/memes/overload.png"),
	preload("res://sprites/memes/okguy.png"),
	preload("res://sprites/memes/yuno.png"),
	preload("res://sprites/memes/megusta.png"),
]

puppetsync func showMeme(number):
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
