extends KinematicBody2D

export var dummy = false
export (int) var run_speed = 200
export (int) var jump_speed = -600
export (int) var gravity = 1200

export (String) var playerName = ""

const WORLD_SIZE = 1024

var velocity = Vector2()

puppet var puppet_pos = Vector2()
puppet var puppet_anim = "idle"
puppet var puppet_animFlip = false

var currentAnim = "idle"
var jumping = false
var invisible = false

func _ready():
	$NameLabel.text = playerName

func get_input():
	velocity.x = 0
	var right = Input.is_action_pressed('right')
	var left = Input.is_action_pressed('left')
	var jump = Input.is_action_just_pressed('up')
	var toggleInvisible = Input.is_action_just_pressed('ui_accept')
	
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
	
	if !isSelf():
		$AnimatedSprite.play(puppet_anim)
		$AnimatedSprite.flip_h = puppet_animFlip
		return
	
	if invisible:
		$AnimatedSprite.modulate.a = 0.5
		set_collision_mask_bit(1, false)
	else:
		$AnimatedSprite.modulate.a = 1
		set_collision_mask_bit(1, true)
	
	if velocity.y < 0:
		currentAnim = "jump"
	elif velocity.x < 0:
		$AnimatedSprite.flip_h = true
		currentAnim = "run"
	elif velocity.x > 0:
		$AnimatedSprite.flip_h = false
		currentAnim = "run"
	else:
		currentAnim = "idle"
	
	$AnimatedSprite.play(currentAnim)
	rset_unreliable("puppet_anim", currentAnim)
	rset_unreliable("puppet_animFlip", $AnimatedSprite.flip_h)

func isSelf():
	return is_network_master()

func _physics_process(delta):
	if dummy:
		return
	if isSelf():
		get_input()
		velocity.y += gravity * delta
		if jumping and is_on_floor():
			jumping = false
		velocity = move_and_slide(velocity, Vector2(0, -1))
		rset_unreliable("puppet_pos", position)
	else:
		position = puppet_pos

puppet func set_visibility(vis):
	visible = vis
	var pointSignals = get_tree().get_root().get_node("root/world/points")
	if pointSignals.has_method("visibilityChanged"):
		pointSignals.visibilityChanged(visible)
	
