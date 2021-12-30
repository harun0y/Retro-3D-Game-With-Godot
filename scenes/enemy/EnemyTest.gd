extends KinematicBody

var health = 100
var value = 0

func _process(delta):
	if health <= 0:
		queue_free()

func get_damage(var _value):
	$Timer.start()
	value = _value


func _on_Timer_timeout():
	health -= value
	$AnimationPlayer.play("hurt")
