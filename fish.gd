extends CharacterBody2D


#var _is_submerged := true :
	#set(value):
		#_is_submerged = value
		#$Cover.visible = _is_submerged
	#get:
		#_is_submerged

var _RADIUS := 14.0
#
var MASS := 20.0
var TARGET :=  Vector2(960, 540)
var BASE_SCALE := 1.0
var MAX_DEPTH := 100
#
var last_position := Vector2.ZERO
var height := -30.0
var height_v := 0.0
#
var t := 0.0

func _ready():
	last_position = position

func _physics_process(delta):
	t += delta
	last_position = position
	position += velocity*delta
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var to_center = TARGET - position
	velocity += to_center.normalized()*sqrt(to_center.length())*0.4
	velocity *= 0.993
	#
	handle_height()

func handle_height():
	var old_h = height
	height = 100*sin(t) #height += height_v
	if height > 0:
		$Cover.visible = false
		scale = Vector2.ONE * (1.07 + height/300)
	else:
		$Cover.visible = true
		var coveredness = 0.6 - 0.4*height/MAX_DEPTH
		$Cover.modulate = Color(1.0, 1.0, 1.0, coveredness)
		scale = Vector2.ONE * (1 + height/400)
	
	

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
	$Cover.visible = true

func leap():
	$Cover.visible = false
