extends CharacterBody2D

@export var dummy = false
@export var run_speed = 200
@export var jump_speed = -600
@export var gravity = 1200

@export var playerName = ""

const _type = "PLAYER"
const SHOOTING_SPEED = 2
const WORLD_SIZE = 1024

var puppet_pos = Vector2()
var puppet_anim = "idle"
var puppet_animFlip = false
var puppet_discussionMode = false

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
	shouldSync = !shouldSync
	
	if !isSelf():
		$AnimatedSprite2D.play(puppet_anim)
		$AnimatedSprite2D.flip_h = puppet_animFlip
		$gun.enabled = puppet_discussionMode
		$gun.flipped = puppet_animFlip
		return
	
	if invisible:
		$AnimatedSprite2D.modulate.a = 0.5
	else:
		$AnimatedSprite2D.modulate.a = 1
	
	$gun.enabled = discussionMode
	
	if dead:
		currentAnim = "hit"
	elif velocity.y < 0:
		currentAnim = "jump"
	elif velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
		$gun.flipped = true
		currentAnim = "run"
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
		$gun.flipped = false
		currentAnim = "run"
	else:
		currentAnim = "idle"
	
	$AnimatedSprite2D.play(currentAnim)
	if shouldSync:
		rpc("syncState", discussionMode, currentAnim, $AnimatedSprite2D.flip_h)

func isSelf():
	return is_multiplayer_authority()

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
		set_velocity(velocity)
		set_up_direction(Vector2(0, -1))
		move_and_slide()
		velocity = velocity
		rpc("syncPos", position)
	else:
		position = puppet_pos

@rpc 
func set_visibility(vis):
	visible = vis
	var pointSignals = get_tree().get_root().get_node("root/world/points")
	if pointSignals.has_method("visibilityChanged"):
		pointSignals.visibilityChanged(visible)
	

@rpc("any_peer")
func syncState(_discussionMode: bool, _currentAnim: String, _animFlipped: bool):
	puppet_discussionMode = _discussionMode
	puppet_anim = _currentAnim
	puppet_animFlip = _animFlipped

@rpc("any_peer")
func syncPos(_pos: Vector2):
	puppet_pos = _pos

@rpc("any_peer") 
func setCollision(active):
	set_collision_mask_value(1, active)

func hit(bulletPos: Vector2):
	if invisible || !visible: 
		return false
	if bulletPos.x < position.x:
		velocity.x = 100
	else:
		velocity.x = -100
	dead = true
	return true
	
@rpc("call_local") 
func fire():
	$bullet_time_r.start(SHOOTING_SPEED)
	$gun.fire(position)

const memes = [
	preload("res://sprites/memes/overload.png"),
	preload("res://sprites/memes/okguy.png"),
	preload("res://sprites/memes/yuno.png"),
	preload("res://sprites/memes/megusta.png"),
]

@rpc("call_local") 
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
