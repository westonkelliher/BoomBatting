extends Node2D

var WHEEL_MULTIPLE := 1.6

var last_angle := 0.0
var new_angle := 0.0

var first = true

var game_is_over = false

func _ready():
	for i in range(20):
		var f = $Aquarium.get_spawned_fish()
		add_child(f)
		f.AQUARIUM = $Aquarium
		f.POST = $ScorePost
		f.start_swim()

func _physics_process(delta):
	$S.rotation += -0.25*delta

func _on_controlpads_message_received(client, message):
	if game_is_over:
		return
	if first:
		first = false
		$TimePost/Timer.start()
	if message == "let-go":
		$S/Boat/Help/Boom.set_inactive()
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
	$S/Boat/Help/Boom.apply_wheel_turn(delta_a/WHEEL_MULTIPLE)


func _on_time_post_times_up():
	game_is_over = true
	$GameOver.visible = true
	$ScorePost.scale *= 2
	$ScorePost.position = Vector2(400, 300)
	$S/Boat/Help/Boom.set_process(false)
