extends Node2D

signal start_game(client)

var last_angle := 0.01
var first := true
var current_client := "0"
var progress := 0.0

func _process(delta):
	modify_progress(-delta*0.33)
	
func _on_controlpads_message_received(client, message):
	current_client = client
	if message == "let-go":
		return
	var new_angle = float(message)
	if first:
		first = false
		last_angle = new_angle
	var delta_a = wrapf(new_angle - last_angle, -PI, PI)
	modify_progress(abs(delta_a)*0.1)
	last_angle = new_angle


func modify_progress(amount):
	var old_progress = progress
	var new_progress = move_toward(old_progress, 1.0, amount)
	if amount < 0:
		new_progress = move_toward(old_progress, 0.01, -amount)
	progress = new_progress
	var move_amnt = 0.01 + abs(progress - $Next/FillBar/Progress.scale.x)*0.05
	$Next/FillBar/Progress.scale.x = move_toward($Next/FillBar/Progress.scale.x, progress, move_amnt)
	start_game.emit()
