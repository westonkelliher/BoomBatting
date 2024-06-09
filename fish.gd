extends RigidBody2D

var TARGET := Vector2(1000, 540)
var ACC := 2.0
var move_on := false#true

func _physics_process(delta):
	if move_on:
		var target_vel = (TARGET - position).normalized()*400
		linear_velocity = lerp(linear_velocity, target_vel, ACC*delta)
	#move_and_collide(linear_velocity)

func _on_body_entered(body):
	print("ssas")
	move_on = false

func _integrate_forces(state):
	for i in range(state.get_contact_count()):
		var collider = state.get_collider_object(i)
		print("asa")
	# Add more specific reaction logic here
