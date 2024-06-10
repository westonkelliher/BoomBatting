extends CharacterBody2D
class_name Fish

signal done_swimming(fish)

var _RADIUS := 14.0
var AQUARIUM = null
var POST = null
#
var MASS := 20.0
var TARGET :=  Vector2(960, 540)
var BASE_SCALE := 1.0
var MAX_DEPTH := 100
#
var SWIM_TIME_MIN := 5.0
var SWIM_TIME_PLUS := 14.0
#
var MOMENTUM := 0.96
var DECEL_AIR := 1.0
var DECEL_WATER := 20.0
var DECEL_LAND:= 200.0
var DAMP_AIR := 0.001
var DAMP_WATER := 0.01
var DAMP_LAND:= 0.04
#
var damping := DAMP_WATER
var decel := DECEL_WATER
var last_position := Vector2.ZERO
var height := -30.0
var height_v := 0.0
#
var is_swimming := true
var is_done := false
var is_on_land := false

func _ready():
	last_position = position

func _process(delta):
	if is_done:
		return
	if velocity.length() < 0.001:
		is_done = true
		POST.add_score()
	overwrite()

func overwrite():
	return
	MOMENTUM = .99

func _physics_process(delta):
	if is_done:
		return
	last_position = position
	# damp
	var damp_amount = (decel + damping*velocity.length())*delta
	var speed = velocity.length()
	if speed != 0:
		var new_speed = move_toward(speed, 0, damp_amount)
		velocity *= new_speed/speed
	# average current velocity with velocity required to get to target
	if is_swimming:
		var req_vel = 1.01*(TARGET - position)/($SwimTimer.time_left + 0.01)
		velocity = velocity*MOMENTUM + req_vel*(1-MOMENTUM)
	#
	position += velocity*delta
	#
	if is_on_land:
		if not AQUARIUM.is_loc_on_land(position):
			splash_down()
	else:
		handle_height()

func handle_height():
	var old_h = height
	var progress_of_timer = 1.0 - $SwimTimer.time_left/$SwimTimer.wait_time
	height = -30 + sin(-progress_of_timer*PI*2)*60.0
	if height > 0:
		scale = Vector2.ONE * (1.1 + height/200)
		if old_h <= 0:
			leap()
	else:
		var coveredness = 0.75 - 0.25*height/MAX_DEPTH
		$Cover.modulate = Color(1.0, 1.0, 1.0, coveredness)
		scale = Vector2.ONE * (1 + height/400)
		if old_h > 0:
			if AQUARIUM.is_loc_on_land(position):
				touch_down()
			else:
				splash_down()


func handle_impulse(impulse: Vector2):
	velocity += (1.0/MASS) * impulse

func reflect_velocity(normal: Vector2):
	velocity += velocity.bounce(normal)*0.01

func nudge_outside(p: Vector2, normal: Vector2, boom_width: float, centrif: float):
	var dist_from_line = abs(normal.dot(position - p))
	var radius = _RADIUS*scale.x*1.04
	var required_dist = boom_width+radius+1
	var remaining_dist = max(0, required_dist - dist_from_line)
	var required_move = normal*remaining_dist
	position += required_move
	velocity += normal
	var length = (position-p).length()
	#velocity += normal*centrif*length*0.1
	#velocity += (position - p).normalized()*centrif*sqrt(length)

func splash_down():
	decel = DECEL_WATER
	damping = DAMP_WATER
	$Cover.visible = true
	is_swimming = true
	is_on_land = false
	collision_layer = 0b1000
	start_swim()

func touch_down():
	print("touchdown")
	decel = DECEL_LAND
	damping = DAMP_LAND
	$Cover.visible = false
	is_swimming = false
	is_on_land = true
	collision_layer = 0b10000

func leap():
	decel = DECEL_AIR
	damping = DAMP_AIR
	$Cover.visible = false
	is_swimming = false
	is_on_land = false
	velocity = (TARGET - position)/$SwimTimer.time_left
	collision_layer = 0b0100


func start_swim():
	TARGET = AQUARIUM.new_swim_location(position)
	$SwimTimer.wait_time = randf()*SWIM_TIME_PLUS + SWIM_TIME_MIN
	$SwimTimer.start()
	# TODO: diff depth to smooth fish height


func _on_swim_timer_timeout():
	print("doneswim")
	#position = TARGET
	#velocity = Vector2.ZERO
	done_swimming.emit(self)
