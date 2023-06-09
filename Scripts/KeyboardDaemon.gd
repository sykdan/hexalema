extends Node

var inputType 

enum inputs {
	INPUT_MOUSE
	INPUT_KB
}

# Called when the node enters the scene tree for the first time.
func _input(event):
	if event is InputEventMouseButton:
		inputType = inputs.INPUT_MOUSE
	if event is InputEventKey:
		inputType = inputs.INPUT_KB
	if event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = !OS.window_fullscreen
		get_tree().set_input_as_handled()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
