extends Sprite

signal fire_bullet(pos, flipped)

var flipped = false
var enabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	visible = enabled
	
	flip_h = flipped
	if flipped:
		$CPUParticles2D.direction.x = -1
		$CPUParticles2D.transform.origin.x = -20
	else:
		$CPUParticles2D.direction.x = 1
		$CPUParticles2D.transform.origin.x = 20
		
func fire(pos):
	$CPUParticles2D.emitting = true
	emit_signal("fire_bullet", pos, flipped)
