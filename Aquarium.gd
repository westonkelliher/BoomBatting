extends Node2D


func _ready():
	pass

func rand_loc_in_area():
	var p = Vector2(randf()*1920, randf()*1000 + 80)
	while not Geometry2D.is_point_in_polygon(p, $All/Shape.polygon):
		p = Vector2(randf()*1920, randf()*1000 + 80)
	return p

func get_spawned_fish():
	var fish = preload("res://fish.tscn").instantiate()
	fish.position = rand_loc_in_area()
	fish.apply_impulse((Vector2(1000, 600)-fish.position).normalized()*100)
	return fish
