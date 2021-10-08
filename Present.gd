extends Control

var snimek = 0

func left():
	get_child(snimek).hide()
	snimek -= 1
	x()
func right():
	get_child(snimek).hide()
	snimek += 1
	x()
func x():
	snimek = clamp(snimek,0,get_child_count()-1)
	get_child(snimek).show()

func _input(event):
	if event.is_action_pressed("left"):
		left()
	if event.is_action_pressed("right"):
		right()

func _on_Button_pressed():
	get_tree().change_scene("res://Main.tscn")
