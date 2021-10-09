extends Control

const txt_nastartu = "Na startu: "
const txt_vcili = "V cíli: "

var current_dice_roll = 0
var turn = "CerveneKameny"

var redDone = 0
var blueDone = 0

var gameBoard = []

var kb_cursor = 5
var kb_target;

func _process(d):
	var pos = $Planek.rect_position
	$Grid.margin_left = -137 + (int(pos.x) % 137) - 3
	$Grid.margin_top = -238 + (int(pos.y) % 238) - 12
	$RedPath.position = pos
	$BluePath.position = pos
	$HintLine.position = pos
	
	$ColorRect.rect_pivot_offset.x = $ColorRect.rect_size.x/2
	$ColorRect.rect_pivot_offset.y = $ColorRect.rect_size.y
	
	for place in range(len(gameBoard)): # 0 - 14
		for stone in gameBoard[place]:
			if stone.disabled: return
			var stonePos: Vector2
			if stone.get_node("..").name == "CerveneKameny":
				stonePos = pos + $RedPath.curve.get_point_position(place)
			if stone.get_node("..").name == "ModreKameny":
				stonePos = pos + $BluePath.curve.get_point_position(place)
			
			stone.rect_global_position = stonePos - stone.rect_pivot_offset

func get_stones_in_index(idx):
	return gameBoard[idx]

func get_point_from_pos(kamen,pop=false):
	for place in range(len(gameBoard)): # 0 - 14
		for stone in gameBoard[place]:
			if stone == kamen:
				if pop: gameBoard[place].erase(kamen)
				return place

func move_enemies_to_start(pos):
	var st = get_stones_in_index(pos)
	for stone in st:
		var n = stone.get_node("..").name
		if n != turn:
			move_stone_to(stone, 0)

func _ready():
	if randi()%2 == 1: swap_turn()
	for x in range(15): gameBoard.append([])
	for x in range(6):
		$CerveneKameny.add_child($CerveneKameny/kamen.duplicate())
		$ModreKameny.add_child($ModreKameny/kamen.duplicate())
	
	for x in $CerveneKameny.get_children():
		gameBoard[0].append(x)
		x.connect("pressed",self,"click_kamen",[x])
		x.connect("mouse_entered",self,"hint_stone",[x])
	
	for x in $ModreKameny.get_children():
		gameBoard[0].append(x)
		x.connect("pressed",self,"click_kamen",[x])
		x.connect("mouse_entered",self,"hint_stone",[x])
	
	var blue = 0
	var red = 0
	for s in get_stones_in_index(0):
		if s.get_node("..").name == "CerveneKameny":
			red += 1
		if s.get_node("..").name == "ModreKameny":
			blue += 1
	$RedStatus/Start.text = txt_nastartu + str(red)
	$BlueStatus/Start.text = txt_nastartu + str(blue)

func test_move(pos):
	if pos+current_dice_roll > 14: return false
	var naMiste = get_stones_in_index(pos+current_dice_roll)
	
	if len(naMiste) == 0: return 1
	if len(naMiste) == 1:
		if naMiste[0].get_node("..").name == turn:
			pass
		else:
			if not pos+current_dice_roll in [5,9]:
				if pos+current_dice_roll > 3 and pos+current_dice_roll < 11:
					return 2
				else:
					return 1
	if len(naMiste) >= 1:
		if pos+current_dice_roll == 14:
			return 3
	
	return false

func hint_stone(obj):
	if current_dice_roll < 1: return
	var trn = obj.get_node("..").name
	if trn != turn: return
	var pos = get_point_from_pos(obj)
	if pos == 14 or pos+current_dice_roll > 14: return
	
	var c 
	if obj.get_node("..").name == "CerveneKameny": c = $RedPath
	else: c = $BluePath
	
	$HintLine.show()
	$HintLine.points = get_line_curve(pos,pos+current_dice_roll,c)

func click_kamen(obj):
	var color = obj.get_node("..").name
	if not color == turn: return
	if current_dice_roll == 0: return
	var pos = get_point_from_pos(obj)
	if pos == null: return
	
	var t = test_move(pos)
	if t:
		if t == 2:
			move_enemies_to_start(pos + current_dice_roll)
		move_stone_to(obj, pos + current_dice_roll)
		if pos+current_dice_roll in [5,9]:
			swap_turn()
			toast("Stoupli jste na sublimační políčko!\nMůžete házet znovu.")
		current_dice_roll = 0
		
		if max(redDone,blueDone) == 7:
			win()
		$"Házet".show()
		swap_turn()

func walk_possible_moves():
	var kameny = get_node(turn).get_children()
	for kamen in kameny:
		var pos = get_point_from_pos(kamen)
		if test_move(pos): 
			kb_target = kamen
			kb_cursor = pos
			if Kb.inputType == 1:
				lockon()
				hint_stone(kamen)
			return true
	
	return false

func swap_turn():
	unlockon()
	$ColorRect.hide()
	$HintLine.hide()
	turn = get_not_turn()
	if turn == "ModreKameny":
		$RedStatus.modulate.a = 0.5
		$BlueStatus.modulate.a = 1
	else:
		$RedStatus.modulate.a = 1
		$BlueStatus.modulate.a = 0.5

func get_not_turn():
	if turn == "CerveneKameny": return "ModreKameny"
	else: return "CerveneKameny"

func get_curve(t):
	if t == "CerveneKameny": 
		return $RedPath
	else: return $BluePath

func toast(txt):
	$Tween.stop($MsgAnchor/Message)
	$MsgAnchor/Message/Label.text = txt
	$MsgAnchor/Message.rect_position = Vector2.ZERO
	$Tween.interpolate_property($MsgAnchor/Message,"rect_position:x",0,-550,0.5,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.start()

func _on_Hzet_pressed():
	if $Trofej.visible or $Pauza.visible: return
	$ColorRect.show()
	$Tween.interpolate_property($ColorRect,"self_modulate:a",null,1,0.1,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.interpolate_property($ColorRect,"rect_scale",null,Vector2(1,1),0.1,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.start()
	$"Házet".hide()
	if not current_dice_roll == 0:
		return
	var dices = []
	for i in range(5):
		var n = randi() % 2
		if n == 1: current_dice_roll += 1
		dices.append(n)
	for i in $ColorRect/HBoxContainer.get_children(): 
		i.get_child(0).hide()
		i.hide()
	for i in range(len(dices)):
		$ColorRect/HBoxContainer.get_child(i).show()
		if dices[i] == 1:
			$ColorRect/HBoxContainer.get_child(i).get_child(0).show()
		yield(get_tree().create_timer(0.3),"timeout")
	yield(get_tree().create_timer(0.7),"timeout")
	
	hzet_2()
			
func hzet_2():
	var can = walk_possible_moves()
	if current_dice_roll == 0:
		toast("Nemůžete táhnout!\nNa kostkách jste hodili součet 0.")
		current_dice_roll = 0
		$"Házet".show()
		swap_turn()
	elif not can:
		toast("Nemůžete táhnout!\nVšechna pole jsou obsazena jinými kameny...")
		current_dice_roll = 0
		$"Házet".show()
		swap_turn()
	
	$Tween.interpolate_property($ColorRect,"self_modulate:a",null,0,0.01,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.interpolate_property($ColorRect,"rect_scale",null,Vector2(0.3,0.3),0.5,Tween.TRANS_CIRC,Tween.EASE_OUT)
	$Tween.start()

func move_stone_to(obj,index):
	var orig = get_point_from_pos(obj,true)
	gameBoard[index].append(obj)
	obj.disabled = true
	var curve = get_curve(obj.get_node("..").name)
	var to = curve.curve.get_point_position(index) - obj.rect_pivot_offset + curve.position
	$Tween.interpolate_property(obj,"rect_global_position",null,to,0.5,Tween.TRANS_SINE,Tween.EASE_OUT)
	$Tween.start()
	if index == 0 or orig == 0:
		var blue = 0
		var red = 0
		for s in get_stones_in_index(0):
			if s.get_node("..").name == "CerveneKameny":
				red += 1
			if s.get_node("..").name == "ModreKameny":
				blue += 1
		$RedStatus/Start.text = txt_nastartu + str(red)
		$BlueStatus/Start.text = txt_nastartu + str(blue)
	if index == 14:
		var blue = 0
		var red = 0
		for s in get_stones_in_index(14):
			if s.get_node("..").name == "CerveneKameny":
				red += 1
			if s.get_node("..").name == "ModreKameny":
				blue += 1
		redDone = red
		blueDone = blue
		$RedStatus/End.text = txt_vcili + str(red)
		$BlueStatus/End.text = txt_vcili + str(blue)

func get_line_curve(from,to,curve):
	var r = PoolVector2Array()
	for p in range(from,to+1):
		r.append(curve.curve.get_point_position(p))
	return r

func win():
	$Trofej.show()
	if turn == "ModreKameny":
		$Trofej/TextureRect/Label.text += "MODRÝ"
	else:
		$Trofej/TextureRect/Label.text += "ČERVENÝ"

func konec():
	get_tree().change_scene("res://Main.tscn")

func _on_Tween_tween_completed(object, key):
	if key == ":rect_global_position" and object is TextureButton:
		if object.disabled: object.disabled = false
	
	if key == ":rect_position:x" and object == $MsgAnchor/Message:
		$Tween.interpolate_property($MsgAnchor/Message,"modulate:a",1,1,6,Tween.TRANS_CIRC,Tween.EASE_IN)
		$Tween.start()
	if key == ":modulate:a" and object == $MsgAnchor/Message:
		$Tween.interpolate_property($MsgAnchor/Message,"rect_position:y",0,300,0.1,Tween.TRANS_CIRC,Tween.EASE_OUT)
		$Tween.start()

func _input(event):
	if event.is_action_pressed("debug"):
		toast("TEST")
	
	if event.is_action_pressed("roll") and $"Házet".visible:
		_on_Hzet_pressed()
	elif event.is_action_pressed("roll") and $LockOn.scale.x >= 1:
		click_kamen(kb_target)
	
	if event.is_action_pressed("left") and (current_dice_roll != 0) and $ColorRect.self_modulate.a != 1:
		var brk = false
		var target
		for i in range(kb_cursor-1,-1,-1):
			for loop_kamen in gameBoard[i]:
				if loop_kamen.get_node("..").name == turn:
					kb_cursor = i
					target = loop_kamen
					brk = true
					break
			if brk: break
		
		if target:
			target.grab_focus()
			hint_stone(target)
			kb_target = target
			lockon()
		else:
			lockon()
	
	if event.is_action_pressed("right") and (current_dice_roll != 0) and $ColorRect.self_modulate.a != 1:
		var brk = false
		var target
		for i in range(kb_cursor+1,14,1):
			for loop_kamen in gameBoard[i]:
				if loop_kamen.get_node("..").name == turn:
					kb_cursor = i
					target = loop_kamen
					brk = true
					break
			if brk: break
		
		if target:
			target.grab_focus()
			hint_stone(target)
			kb_target = target
			lockon()
		else:
			lockon()

func lockon():
	if not (kb_target is TextureButton): return
	var pos = kb_target.rect_global_position + kb_target.rect_pivot_offset
	if $LockOn.scale.x < 1:
		$LockOn.position = pos
	$Tween.interpolate_property($LockOn,"position",null,pos,0.5,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.interpolate_property($LockOn,"scale",Vector2.ONE * 1.2,Vector2.ONE,0.5,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.start()

func unlockon():
	$Tween.interpolate_property($LockOn,"scale",null,Vector2.ZERO,0.5,Tween.TRANS_QUAD,Tween.EASE_OUT)
	$Tween.start()

func _on_fullscreen_pressed():
	OS.window_fullscreen = !OS.window_fullscreen

func _on_pauseButton_pressed():
	$Pauza.visible = !$Pauza.visible
