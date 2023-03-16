extends Node


var activeCount = 0

signal active_base_count_changed
signal base_active_state_changed


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func process(node: String, dir: String):
	if dir == "entered":
		activeCount += 1
	elif dir == "exited":
		activeCount = max(activeCount - 1, 0)
		
	emit_signal("active_base_count_changed", activeCount)
	emit_signal("base_active_state_changed", node, dir == "entered")

func _on_1points__area_shape_entered(_area_id, _area, _area_shape, _self_shape):
	process("1", "entered")


func _on_1points__area_shape_exited(_area_id, area, _area_shape, _self_shape):
	if(area != null):
		process("1", "exited")


func _on_3points__area_shape_entered(_area_id, _area, _area_shape, _self_shape):
	process("3", "entered")


func _on_3points__area_shape_exited(_area_id, area, _area_shape, _self_shape):
	if(area != null):
		process("3", "exited")


func _on_8points__area_shape_entered(_area_id, _area, _area_shape, _self_shape):
	process("8", "entered")


func _on_8points__area_shape_exited(_area_id, area, _area_shape, _self_shape):
	if(area != null):
		process("8", "exited")


func _on_5points__area_shape_entered(_area_id, _area, _area_shape, _self_shape):
	process("5", "entered")


func _on_5points__area_shape_exited(_area_id, area, _area_shape, _self_shape):
	if(area != null):
		process("5", "exited")


func _on_13points__area_shape_entered(_area_id, _area, _area_shape, _self_shape):
	process("13", "entered")


func _on_13points__area_shape_exited(_area_id, area, _area_shape, _self_shape):
	if(area != null):
		process("13", "exited")


func _on_20points__area_shape_entered(_area_id, _area, _area_shape, _self_shape):
	process("20", "entered")


func _on_20points__area_shape_exited(_area_id, area, _area_shape, _self_shape):
	if(area != null):
		process("20", "exited")
