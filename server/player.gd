extends Area2D


var puppet_pos = Vector2(100,100)
var puppet_anim = "idle"
var puppet_animFlip = false
var puppet_discussionMode = false

func _ready():
	pass
	
@rpc("any_peer") 
func set_visibility(vis):
	visible = vis
	
@rpc("any_peer") 
func showMeme(_number):
	pass
	
@rpc("any_peer") 
func fire():
	pass
	
func setCollision(active):
	rpc("setCollision", active)
	
func _process(_delta):
	position = puppet_pos
