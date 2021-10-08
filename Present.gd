extends Control

var snimek = 0


# Called when the node enters the scene tree for the first time.
func _input(event):
	if event.is_action_pressed("ui_left"):
		get_child(snimek).hide()
		snimek -= 1
	if event.is_action_pressed("ui_right"):
		get_child(snimek).hide()
		snimek += 1
	
	snimek = clamp(snimek,0,get_child_count())
	
	get_child(snimek).show()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	get_tree().change_scene("res://Main.tscn")
