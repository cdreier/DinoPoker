extends Area2D

remote var puppet_pos = Vector2(100,100)
remote var puppet_anim = "idle"
remote var puppet_animFlip = false
remote var puppet_discussionMode = false

func _ready():
	pass
	
remote func set_visibility(vis):
	visible = vis
	
remote func showMeme(number):
	pass
	
remote func fire():
	pass
	
func setCollision(active):
	rpc("setCollision", active)
	
func _process(delta):
	position = puppet_pos
