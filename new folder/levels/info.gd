extends Node2D

var toplamItem = 2
var sigir = 0
var yosun = 0
var mantar = 0
var kabuk = 0
var su = 2
var sise = 0
var yengecGozu = 0


onready var itemList = $Lists/ItemList
onready var simyaList = $Lists/SimyaList
onready var infoLabel = $info

func _ready():
	$Lists.visible = false

func _process(delta):
	if $Lists.visible == true:
		potionCheck()
	if Input.is_action_just_pressed("tab"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if $Lists.visible == false:
			$Lists.visible = true
		else:
			$Lists.visible = false

func _on_Collectables_send_name_info(name, image, is_e_pressed):
	infoLabel.text = name
	if is_e_pressed == true:
		_add_item(name, image)
		changeItemCount(name)
	$Timer.start()

func _on_Timer_timeout():
	infoLabel.text = " "

func _add_item(name, image):
	itemList.add_item(name, image, true)

func _delete_item():
	pass

func _on_SimyaList_item_selected(index):
	$Lists/Panel.visible = true
	match index:
		0:
			$Lists/Panel/Sprite.texture = load("res://Inventory/simya/siseler/bDayan_info.png")
		1:
			$Lists/Panel/Sprite.texture = load("res://Inventory/simya/siseler/can_info.png")
		2:
			$Lists/Panel/Sprite.texture = load("res://Inventory/simya/siseler/bCan_info.png")
		3:
			$Lists/Panel/Sprite.texture = load("res://Inventory/simya/siseler/day_info.png")



func _on_SimyaList_mouse_exited():
	$Lists/Panel.visible = false
	$Lists/Panel/Sprite.texture = null

func potionCheck():
	if (su>0 && yosun>0):
		simyaList.set_item_disabled(0, false)
	else:
		simyaList.set_item_disabled(0, true)
	if (su>0 && sigir>0 && mantar>0):
		simyaList.set_item_disabled(1, false)
	else:
		simyaList.set_item_disabled(1, true)
	if (su>0 && sigir>0):
		simyaList.set_item_disabled(2, false)
	else:
		simyaList.set_item_disabled(2, true)
	if (su>0 && yosun>0 && yengecGozu>0):
		simyaList.set_item_disabled(3, false)
	else:
		simyaList.set_item_disabled(3, true)


func _on_SimyaList_item_activated(index):
	if not simyaList.is_item_disabled(index):
		match index:
			0:
				su-=1
				yosun-=1
				deleteFromItemList("Su")
				deleteFromItemList("Yosun")
				simyaList.set_item_disabled(index, true)
				itemList.add_item(simyaList.get_item_text(index), simyaList.get_item_icon(index))
			1:
				su-=1
				sigir-=1
				mantar-=1
				deleteFromItemList("Su")
				deleteFromItemList("Sahil Sıgırkuyrugu")
				deleteFromItemList("Zehirli Mantar")
				simyaList.set_item_disabled(index, true)
				itemList.add_item(simyaList.get_item_text(index), simyaList.get_item_icon(index))
			2:
				su-=1
				sigir-=1
				deleteFromItemList("Su")
				deleteFromItemList("Sahil Sıgırkuyrugu")
				simyaList.set_item_disabled(index, true)
				itemList.add_item(simyaList.get_item_text(index), simyaList.get_item_icon(index))
			3:
				su-=1
				yosun-=1
				yengecGozu-=1
				deleteFromItemList("Su")
				deleteFromItemList("Yosun")
				deleteFromItemList("Yengec Gozu")
				simyaList.set_item_disabled(index, true)
				itemList.add_item(simyaList.get_item_text(index), simyaList.get_item_icon(index))

func changeItemCount(var name:String):
	toplamItem += 1
	match name:
		"Yosun":
			yosun+=1
		"Sahil Sıgırkuyrugu":
			sigir+=1
		"Zehirli Mantar":
			mantar+=1
		"Istiridye Kabugu":
			kabuk+=1
		"Yengec Gozu":
			yengecGozu+=1
		"Su":
			su+=1
		"Sise":
			sise+=1

func deleteFromItemList(var name):
	for i in range(toplamItem):
		if itemList.get_item_text(i) == name:
			itemList.remove_item(i)
			break


func _on_ItemList_item_activated(index):
	for i in range(4):
		if itemList.get_item_text(index) == simyaList.get_item_text(i):
			itemList.remove_item(index)
			itemList.add_item("Sise", load("res://Inventory/simya/siseler/bosise.png"))
			sise+=1


