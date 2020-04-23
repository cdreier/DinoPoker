extends Area2D

var active = 0
export var hide_tree = false

func _ready():
	if hide_tree:
		$Dead_Tree_6.hide()

func applyVisibility():
	if active > 0:
		$sp.modulate.a = 1
	else: 
		$sp.modulate.a = 0.3

func _on_body_entered(body):
	if body is KinematicBody2D && body.has_method("isSelf"):
		active = active + 1
		if body.is_visible_in_tree():
			applyVisibility()


func _on_body_exited(body):
	if body is KinematicBody2D && body.has_method("isSelf"):
		active = active - 1
		if body.is_visible_in_tree():
			applyVisibility()

