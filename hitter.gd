extends CharacterBody2D

var last_position

func _physics_process(delta):
	self.last_position = position
	
	move_and_slide()
