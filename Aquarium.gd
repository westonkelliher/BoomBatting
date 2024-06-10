extends Node2D

#
var sand_colliders := []
var flow_colliders := []

func _ready():
	pass

func _physics_process(delta):
	for body in flow_colliders:
		push_body_inward(body, delta)
	for body in sand_colliders:
		bump_body_inward(body, delta)


func is_loc_on_land(p: Vector2):
	return Geometry2D.is_point_in_polygon(p, $Land/Shape.polygon)

func is_loc_in_swim_area(p: Vector2):
	return Geometry2D.is_point_in_polygon(p, $Swim/Shape.polygon)
	
func rand_loc_in_area():
	var p = Vector2(randf()*1920, randf()*1000 + 80)
	while not is_loc_in_swim_area(p):
		p = Vector2(randf()*1920, randf()*1000 + 80)
	return p

func get_spawned_fish():
	var fish = preload("res://fish.tscn").instantiate()
	fish.position = rand_loc_in_area()
	#fish.velocity = (Vector2(1000, 600)-fish.position).normalized()*100
	return fish

func rand_dist_location(p):
	var theta = randf()*PI*2
	var r = randf()*650.0 + 150.0
	return p + Vector2.RIGHT.rotated(theta)*r

func new_swim_location(p):
	var pnew = rand_dist_location(p)
	var n = 0
	while not is_loc_in_swim_area(pnew):
		if n > 20:
			return Vector2(700, 700) 
		pnew = rand_dist_location(p)
		n += 1
	return pnew

###
func bump_body_inward(body, delta):
	var toward_targ = Vector2(700, 700) - position
	body.position += toward_targ*120.0*delta
	body.velocity += toward_targ*100.0*delta

func push_body_inward(body, delta):
	var toward_targ = Vector2(700, 700) - position
	body.velocity += toward_targ*500.0*delta
###

func _on_land_body_entered(body):
	if body is Fish:
		body.position = Vector2(700, 700)
		body.velocity = Vector2.ZERO
		body.start_swim()
		return
	# boat
	var toward_targ = Vector2(700, 700) - position
	body.velocity = body.velocity.bounce(toward_targ)
	body.velocity *= 0.6
	body.position += toward_targ*2
	body.velocity += toward_targ*10
	sand_colliders.append(body)

func _on_land_body_exited(body):
	if is_loc_in_swim_area(body.position):
		sand_colliders.erase(body)


func _on_flow_body_entered(body):
	sand_colliders.append(body)


func _on_flow_body_exited(body):
	if is_loc_in_swim_area(body.position):
		flow_colliders.erase(body)
