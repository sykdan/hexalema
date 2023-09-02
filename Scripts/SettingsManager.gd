extends Node

var lang = "cs"

const should_save = ["lang"]

func _ready():
	var file = File.new()
	if file.open("user://hexalema_settings.dat", File.READ) != OK:
		store_save()
		return
	
	var savedata = file.get_as_text()
	var json: Dictionary = JSON.parse(savedata).result
	
	if json == null:
		return
	
	for variable in should_save:
		if not json.has(variable):
			set(variable, get(variable))
		else:
			set(variable, json[variable])

func store_save():
	var file = File.new()
	file.open("user://hexalema_settings.dat", File.WRITE)
	var savedata = {}
	for variable in should_save:
		 savedata[variable] = get(variable)
	
	file.store_string(JSON.print(savedata))
