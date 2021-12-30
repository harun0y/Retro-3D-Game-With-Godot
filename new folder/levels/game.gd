extends Node

onready var label = $Areas/Label

func _on_ctrlArea_area_entered(area):
	print("eğilmek için ctrl bas")
	label.text = "egilmek icin ctrl bas";


func _on_wasdArea_area_entered(area):
	print("wasd ile hareket et space ile zıpla")
	label.text = "wasd ile hareket et space ile zipla";

func _on_attackArea_area_entered(area):
	label.text = "Hey! bu yengeçler kocaman! Dost olmaya geldiklerini sanmiyorum!";

func _on_Timer_timeout():
	label.text = " ";


func _on_wasdArea_area_exited(area):
	$Areas/Timer.start()


func _on_ctrlArea_area_exited(area):
	$Areas/Timer.start()

func _input(event):
	if event.is_action_pressed("r"):
		get_tree(). reload_current_scene()


