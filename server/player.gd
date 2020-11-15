extends Area2D

remote var puppet_pos = Vector2(100,100)

func _ready():
	pass
	
remote func set_visibility(vis):
	print("visibility", vis)
	visible = vis
	
remote func showMeme(number):
	print("show meme", number)
	pass
	
func setCollision(active):
	rpc("setCollision", active)
	
func _process(delta):
	position = puppet_pos
