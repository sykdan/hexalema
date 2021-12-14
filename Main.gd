extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	if OS.get_name() == "HTML5": $Options/Panel/VBoxContainer/konec.hide()
	$HTTPRequest.request("https://hexalema.znachor.cz/version.txt")

func _on_Button_pressed():
	get_tree().change_scene("res://Hra.tscn")


func _on_Button2_pressed():
	$Options.visible = !$Options.visible
	if $Options.visible:
		$MoreThings.text = "X"
	else:
		$MoreThings.text = "+"

func _on_Pravidla_pressed():
	get_tree().change_scene("res://Informace.tscn")


func _on_Zdroje_pressed():
	$AcceptDialog.popup()
	$Options.visible = false
	$MoreThings.text = "+"

func _on_konec_pressed():
	get_tree().quit()

func verize(ver):
	ver = Array(ver.rsplit("."))
	for i in range(len(ver)):
		ver[i] = int(ver[i])
	return ver

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var ver = body.get_string_from_utf8()
	var server = verize(ver)
	var local = verize($Label2.text)
	if server[0] > local[0]:
		$Label3.text = "Z našich stránek můžete stáhnout novou verzi hry!"
	elif server[1] > local[1]:
		$Label3.text = "Z našich stránek můžete stáhnout novou verzi hry!"
	elif server[2] > local[2]:
		$Label3.text = "Z našich stránek můžete stáhnout novou verzi hry!"
