extends Node2D



func _on_barrier_body_entered(body):
	body.velocity = 0.8*body.velocity.bounce(Vector2.DOWN)
