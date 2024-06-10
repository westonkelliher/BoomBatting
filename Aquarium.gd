extends Node2D


func _ready():
	pass

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
