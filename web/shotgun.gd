extends Sprite

signal fire_bullet(pos, flipped)

var flipped = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
