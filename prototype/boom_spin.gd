extends Node2D

var WHEEL_MULTIPLE := 1.6

var last_angle := 0.0
var new_angle := 0.0


func _ready():
	for i in range(10):
		var f = $Aquarium.get_spawned_fish()
		var s = randf()*1.5 + 0.75
		f.scale *= s
		f.MASS *= s*s
		f.TARGET += Vector2(randf()*800 - 200, randf()*800 -200)
		add_child(f)

func _on_controlpads_message_received(client, message):
	if message == "let-go":
		$Boom.set_inactive()
		return
	#
	last_angle = new_angle
	new_angle = float(message)
	var delta_a = new_angle - last_angle
	if delta_a > PI:
		delta_a -= PI*2
	elif delta_a < -PI:
		delta_a += PI*2
	#
	$Boom.apply_wheel_turn(delta_a/WHEEL_MULTIPLE)
