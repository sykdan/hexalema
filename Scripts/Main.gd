extends TextureRect

func _ready():
	randomize()
	if OS.get_name() == "HTML5": $Options/Panel/ls/End.hide()
	$HTTPRequest.request("https://hexalema.znachor.cz/version.txt")

func Play():
	get_tree().change_scene("res://Scenes/Game.tscn")

func MoreThings():
	$OptionsCover.visible = !$OptionsCover.visible
	if $OptionsCover.visible:
		$MoreThings.text = "X"
	else:
		$MoreThings.text = "+"

func Rules():
	get_tree().change_scene("res://Scenes/Information.tscn")

func Credits():
	$Credits.popup()
	$OptionsCover.visible = false
	$MoreThings.text = "+"

func WhatsNew():
	$WhatsNewTxt.popup()
	$OptionsCover.visible = false
	$MoreThings.text = "+"

func Quit():
	get_tree().quit()

func verize(ver):
	ver = Array(ver.rsplit("."))
	for i in range(len(ver)):
		ver[i] = int(ver[i])
	return ver

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var ver = body.get_string_from_utf8()
	var server = verize(ver)
	var local = verize($Version.text)
	if server[0] > local[0]:
		$UpdateTxt.text = tr("UpdateNudgeText")
	if server[0] < local[0]: return
	if server[1] > local[1]:
		$UpdateTxt.text = tr("UpdateNudgeText")
	if server[1] < local[1]: return
	if server[2] > local[2]:
		$UpdateTxt.text = tr("UpdateNudgeText")
