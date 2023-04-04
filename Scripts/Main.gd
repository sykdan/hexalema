extends TextureRect

const GAME_VERSION = "v1_3_0"

func _ready():
	randomize()
	if OS.get_name() == "HTML5": $Options/Panel/ls/End.hide()
	CheckForUpdates()
	
	for lang in $OptionsCover/Languages.get_children():
		lang.connect("pressed", TranslationServer, "set_locale", [lang.name])

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

func CheckForUpdates():
	$HTTPRequest.request("https://api.github.com/repos/sykdan/hexalema/releases/latest")

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	var recv = body.get_string_from_utf8()
	var data = JSON.parse(recv).result
	
	if data.tag_name != GAME_VERSION:
		$UpdateTxt.visible = true
