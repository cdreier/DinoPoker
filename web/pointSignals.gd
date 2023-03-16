extends Node

signal visibility_has_changed

func _ready():
	pass 

func visibilityChanged(_vis):
	emit_signal("visibility_has_changed")
