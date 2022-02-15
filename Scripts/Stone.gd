extends Sprite

signal input(e)
# Called when the node enters the scene tree for the first time.
func _input(e):
	emit_signal("input",e)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
