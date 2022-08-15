extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var speed = 750
var flipped = false

func _physics_process(delta):
	if flipped:
		position -= transform.x * speed * delta
	else:
		position += transform.x * speed * delta


func _on_Bullet_body_entered(body):
	if "_type" in body && body._type == "PLAYER":
		body.hit()


func _on_Bullet_area_entered(area):
#	print("area", area)
	pass # Replace with function body.
