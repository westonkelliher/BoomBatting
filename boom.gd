extends Node2D

var _BOOM_LENGTH := 200.0
var _BOOM_WIDTH := 16.0
#
var MAX_TURN_SPEED := 4.0 #3.0
var START_TURN_SPEED := 2.0 #1.0
var TURN_ACC := 5.0 #2.0
var TURN_DEC := 3.0
var TURN_DAMP := 1.5
#
var TARGET_SPRING := 2.0
var TARGET_ACC := 2.0
var TARGET_LEAD_AMOUNT := 2.0 #PI*0.7
var STOPPING_FACTOR := 0.8
#
var BASEMASS := 20
var HALFMASS := 100
#
var target_angle := 0.0
var turn_speed := 0.0
#
var colliders := []

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
		var da = d_a(target_angle, rotation)
		var amnt = (TARGET_ACC + abs(da)*TARGET_SPRING) * delta
		target_angle = lerp_angle(target_angle, rotation, amnt)
	if cranking:
		var target_speed = MAX_TURN_SPEED*target_direction()
		turn_speed = move_toward(turn_speed, target_speed, TURN_ACC*delta)
		var old_rot = rotation
		rotate_not_past_target(delta)
		if abs(d_a(rotation, target_angle)) < 0.00001:
			cranking = false
			var leftover_a = turn_speed*delta - d_a(rotation,old_rot)
			rotation += leftover_a*STOPPING_FACTOR
			turn_speed *= STOPPING_FACTOR
	else:
		var damp_amount = (TURN_DEC + abs(turn_speed)*TURN_DAMP)*delta
		turn_speed = move_toward(turn_speed, 0, damp_amount)
		rotation += turn_speed*delta
		rotation = wrapf(rotation, 0, PI*2)
		target_angle = rotation
	#
	for body in colliders:
		nudge_body(body)

func nudge_body(body):
	var angle_to_body = (body.last_position - position).angle()
	var hit_perpen = PI/2
	if d_a(rotation, angle_to_body) > 0:
		hit_perpen *= -1
	var hit_direction = Vector2.RIGHT.rotated(rotation + hit_perpen)
	body.nudge_outside(position, hit_direction, scale.y*_BOOM_WIDTH*0.5, abs(turn_speed))

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
		turn_speed = 0.0*START_TURN_SPEED*target_direction() #TODO
	cranking = true
	active_cranking = true

func set_inactive():
	active_cranking = false


func _on_detector_body_entered(body):
	colliders.append(body)
	# calculate hit direction based on what side
	# and swing direction based on turn_speed
	var angle_to_body = (body.last_position - position).angle()
	var hit_perpen = PI/2
	if d_a(rotation, angle_to_body) > 0:
		hit_perpen *= -1
	var hit_direction = Vector2.RIGHT.rotated(rotation + hit_perpen)
	var turn_perpen = -PI/2
	if turn_speed < 0:
		turn_perpen *= -1
	var swing_direction = Vector2.RIGHT.rotated(rotation + turn_perpen)
	#
	var lever_length = (body.position - position).length()
	var lever_factor = lever_length/(_BOOM_LENGTH*scale.x/2)
	var effective_mass = BASEMASS*0 + 1.0/lever_factor * HALFMASS
	var effective_velocity = swing_direction*abs(turn_speed)*lever_length
	#
	var relative_v = effective_velocity - body.velocity
	var the_dot = relative_v.dot(hit_direction)
	if the_dot > 0:
		print("non-colliding overlap")
		return
	var hitting_speed = -1*the_dot
	var impulse_scalar = hitting_speed / (1/effective_mass + 1/body.MASS)
	#print(_BOOM_LENGTH*scale.x)
	#print(lever_length)
	#print("mass "+str(effective_mass) + ", speed "+str(effective_speed))
	var impulse = impulse_scalar*hit_direction
	body.handle_impulse(impulse)
	body.nudge_outside(position, hit_direction, scale.y*_BOOM_WIDTH*0.5, abs(turn_speed))
	#
	# handle leverpulse
	var strength = impulse.length()*lever_factor/(effective_mass+HALFMASS)
	turn_speed -= strength*hit_perpen*0.005 # hit_perpen for sign
	#target_angle += d_a(rotation, target_angle)*sqrt(1/strength)
	#target_angle = rotation


func _on_detector_body_exited(body):
	if body in colliders:
		colliders.erase(body)
