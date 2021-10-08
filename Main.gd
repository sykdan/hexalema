extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_pressed():
	get_tree().change_scene("res://Hra.tscn")


func _on_Button2_pressed():
	$Options.visible = !$Options.visible

func prezentacni_rezim():
	get_tree().change_scene("res://Present.tscn")


func _on_Pravidla_pressed():
	get_tree().change_scene("res://Informace.tscn")


func _on_Zdroje_pressed():
	$AcceptDialog.popup()
	$Options.visible = false
