extends Spatial

func _ready():
	$kaolzaogoch/AnimationPlayer.get_animation("running").loop = true


func _on_Button_pressed():
	get_tree().change_scene("res://new folder/levels/game.tscn")
