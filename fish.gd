extends CharacterBody2D

var _RADIUS := 14.0
#
var MASS := 20.0
var TARGET :=  Vector2(960, 540)
#
var last_position := Vector2.ZERO

func _ready():
	last_position = position

func _physics_process(delta):
	last_position = position
	position += velocity*delta
	velocity *= 0.99
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var to_center = TARGET - position
	position += to_center.normalized()*sqrt(to_center.length())*0.2


func handle_impulse(impulse: Vector2):
	#print("----")
	#print(impulse)
	#print("vel "+str(velocity))
	velocity += (1.0/MASS) * impulse
	#print("vel "+str(velocity))


func nudge_outside(p: Vector2, normal: Vector2, boom_width: float, centrif: float):
	var dist_from_line = abs(normal.dot(position - p))
	var radius = _RADIUS*scale.x*1.02
	var required_dist = boom_width+radius+1
	var required_move = normal*(required_dist - dist_from_line)
	position += required_move
	var length = (position-p).length()
	#velocity += normal*centrif*sqrt(length)
	velocity += (position - p).normalized()*centrif*sqrt(length)
