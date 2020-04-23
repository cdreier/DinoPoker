extends Polygon2D

remote var puppet_pos = Vector2(100,100)
remote var puppet_anim = "idle"
remote var puppet_animFlip = false

func _ready():
	pass
	
remote func set_visibility(vis):
	visible = vis
	
func _process(delta):
	position = puppet_pos
