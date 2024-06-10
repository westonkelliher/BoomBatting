extends Node2D

signal times_up()

var secs_left := 60

func _ready():
	$Number.text = str(secs_left)

func _on_timer_timeout():
	secs_left -= 1
	$Number.text = str(secs_left)
	if secs_left <= 0:
		times_up.emit()
		$Timer.stop()
		
