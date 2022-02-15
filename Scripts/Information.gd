extends Control

func _ready():
	$Rules.bbcode_text = tr("RulesScreenText")

func GoBack():
	get_tree().change_scene("res://Scenes/Main.tscn") 
