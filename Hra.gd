extends Control

var current_dice_roll = 0
var turn = "CerveneKameny"

var redDone = 0
var blueDone = 0

func _process(d):
	var pos = $Planek.rect_position
	$Grid.margin_left = -137 + (int(pos.x) % 137) - 3
	$Grid.margin_top = -238 + (int(pos.y) % 238) - 12
	$RedPath.position = pos
	$BluePath.position = pos

func get_stones_in_index(idx):
	var r = []
	for x in $CerveneKameny.get_children():
		var pos = get_point_from_pos(x.rect_global_position + x.rect_pivot_offset,"CerveneKameny")
		if pos == idx: r.append(x)
	
	for x in $ModreKameny.get_children():
		var pos = get_point_from_pos(x.rect_global_position + x.rect_pivot_offset,"ModreKameny")
		if pos == idx: r.append(x)
	
	return r

func get_point_from_pos(v: Vector2,color):
	if color == "CerveneKameny":
		var i = $RedPath.curve.get_point_count()
		for p in range(i):
			if v == $RedPath.curve.get_point_position(p):
				return p
	if color == "ModreKameny":
		var i = $BluePath.curve.get_point_count()
		for p in range(i):
			if v == $BluePath.curve.get_point_position(p):
				return p

func move_enemies_to_start(pos):
	var st = get_stones_in_index(pos)
	for stone in st:
		var n = stone.get_node("..").name
		if n != turn:
			var nt = get_not_turn()
			move_stone_to(stone, get_curve(nt).curve.get_point_position(0) - stone.rect_pivot_offset)

func _ready():
	connect("resized",self,"_resized")
	if randi()%2 == 1: swap_turn()
	for x in range(6):
		$CerveneKameny.add_child($CerveneKameny/kamen.duplicate())
		$ModreKameny.add_child($ModreKameny/kamen.duplicate())
	
	for x in $CerveneKameny.get_children():
		x.rect_global_position = $RedPath.curve.get_point_position(0) - x.rect_pivot_offset
		x.connect("pressed",self,"click_kamen",[x])
		x.connect("mouse_entered",self,"hint_stone",[x])
	
	for x in $ModreKameny.get_children():
		x.rect_global_position = $BluePath.curve.get_point_position(0) - x.rect_pivot_offset
		x.connect("pressed",self,"click_kamen",[x])
		x.connect("mouse_entered",self,"hint_stone",[x])

func test_move(pos):
	print("test for destination: ",pos," ",pos+current_dice_roll)
	if pos+current_dice_roll > 14: return false
	var naMiste = get_stones_in_index(pos+current_dice_roll)
	
	if len(naMiste) == 0: return 1
	if len(naMiste) == 1:
		print(naMiste[0].get_node("..").name)
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
	var pos = get_point_from_pos(obj.rect_position + obj.rect_pivot_offset,trn)
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
	var pos = get_point_from_pos(obj.rect_global_position + obj.rect_pivot_offset,color)
	if pos == null: return
	
	var t = test_move(pos)
	if t:
		if pos + current_dice_roll == 14:
			if turn == "CerveneKameny": redDone += 1
			elif turn == "ModreKameny": blueDone += 1
		if t == 2:
			move_enemies_to_start(pos + current_dice_roll)
		move_stone_to(obj, get_curve(turn).curve.get_point_position(pos + current_dice_roll) - obj.rect_pivot_offset)
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
		var pos = get_point_from_pos(kamen.rect_global_position + kamen.rect_pivot_offset,turn)
		if test_move(pos): return true
	
	return false

func swap_turn():
	$HintLine.hide()
	turn = get_not_turn()
	if turn == "ModreKameny":
		$Status/Label.text = "FIALOVÝ"
		$Status.self_modulate = Color("7f2aff")
	else:
		$Status/Label.text = "ČERVENÝ"
		$Status.self_modulate = Color("e02424")

func get_not_turn():
	if turn == "CerveneKameny": return "ModreKameny"
	else: return "CerveneKameny"

func get_curve(t):
	if t == "CerveneKameny": 
		return $RedPath
	else: return $BluePath

func toast(txt):
	$Message/Label.text = txt
	$Tween.interpolate_property($Message,"modulate:a",1,0,8,Tween.TRANS_EXPO,Tween.EASE_IN)
	$Tween.start()

func _on_Hzet_pressed():
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
		print(dices[i])
		if dices[i] == 1:
			print("A")
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

func move_stone_to(obj,to):
	$Tween.interpolate_property(obj,"rect_global_position",null,to,0.5,Tween.TRANS_SINE,Tween.EASE_OUT)
	$Tween.start()
	

func get_line_curve(from,to,curve):
	var r = PoolVector2Array()
	for p in range(from,to+1):
		r.append(curve.curve.get_point_position(p))
	return r

func win():
	$Trofej.show()
	if turn == "ModreKameny":
		$Trofej/TextureRect/Label.text += "FIALOVÝ"
	else:
		$Trofej/TextureRect/Label.text += "ČERVENÝ"


func konec():
	get_tree().change_scene("res://Main.tscn")
