extends Area2D


@export var currentAnim = "idle"
@export var discussionMode = false
@export var currentAnimFlip = false
@export var invisible = false 

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(name.to_int())
	
@rpc("any_peer")
func set_visibility(vis):
	visible = vis
	
@rpc("any_peer", "call_local") 
func showMeme(_number):
	pass
	
@rpc("any_peer", "call_local") 
func fire():
	pass

@rpc("any_peer")
func setCollision(active):
	rpc("setCollision", active)
	
func _process(_delta):
	pass
