extends Node2D

var MAX_TURN_SPEED := 3.0
var START_TURN_SPEED := 1.0
var TURN_ACC := 2.0
var TURN_DEC := 3.0
var TURN_DAMP := 1.5
#
var TARGET_SPRING := 2.0
var TARGET_LEAD_AMOUNT := PI*0.7
var STOPPING_FACTOR := 0.8
#
var target_angle := 0.0
var turn_speed := 0.0

# when cranking is true we acc up to a constant max turn speed
# when cranking is false, we damp the turn speed and target angle gets
var cranking := false
var active_cranking := false


#### helpers ####
func d_a(a1: float, a2: float):
	return wrapf(a1-a2, -PI, PI)


#### builtins ####
func _process(delta):
	$debug/arm.position = position
	$debug/arm.rotation = target_angle

func _physics_process(delta):
	if not active_cranking:
		var amnt = abs(d_a(target_angle, rotation))*TARGET_SPRING*delta
		target_angle = lerp_angle(target_angle, rotation, amnt)
	if cranking:
		var target_speed = MAX_TURN_SPEED*target_direction()
		turn_speed = move_toward(turn_speed, target_speed, TURN_ACC*delta)
		var old_rot = rotation
		rotate_not_past_target(delta)
		print(turn_speed)
		print(d_a(rotation, target_angle))
		if abs(d_a(rotation, target_angle)) < 0.00001:
			cranking = false
			var leftover_a = turn_speed*delta - d_a(rotation,old_rot)
			rotation += leftover_a*STOPPING_FACTOR
			turn_speed *= STOPPING_FACTOR
	else:
		var damp_amount = (TURN_DEC + abs(turn_speed)*TURN_DAMP)*delta
		turn_speed = move_toward(turn_speed, 0, damp_amount)
		print(turn_speed)
		rotation += turn_speed*delta
		rotation = wrapf(rotation, 0, PI*2)
		target_angle = rotation

func rotate_not_past_target(delta):
	if turn_speed == 0:
		return
	var old_rot = rotation
	rotation += turn_speed*delta
	if (d_a(target_angle, old_rot) > 0) != (d_a(target_angle, rotation) > 0):
		rotation = target_angle

func target_is_cw():
	return d_a(target_angle, rotation) < 0

func target_direction():
	if target_is_cw():
		return -1
	else:
		return 1 

func apply_wheel_turn(delta_a: float):
	if abs(delta_a) > PI*0.25:
		delta_a *= PI*0.25/abs(delta_a)
	target_angle = wrapf(target_angle + delta_a, 0, PI*2)
	if d_a(target_angle, rotation) > TARGET_LEAD_AMOUNT:
		target_angle = rotation + TARGET_LEAD_AMOUNT
	elif d_a(target_angle, rotation) < -TARGET_LEAD_AMOUNT:
		target_angle = rotation - TARGET_LEAD_AMOUNT
	if not active_cranking:
		turn_speed = START_TURN_SPEED*target_direction()
	cranking = true
	active_cranking = true

func set_inactive():
	active_cranking = false
