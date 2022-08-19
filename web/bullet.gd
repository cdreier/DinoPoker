extends Area2D

var speed = 750
var flipped = false

func _physics_process(delta):
	if flipped:
		position -= transform.x * speed * delta
	else:
		position += transform.x * speed * delta


func _on_Bullet_body_entered(body):
	if body.has_method("hit"):
		var hitCheck = body.hit(position)
		if hitCheck:
			queue_free()


func _on_Bullet_area_entered(area: Area2D):
	if area.name.begins_with("bounds_"):
		queue_free()
