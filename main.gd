extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_screen_start_game(client):
	$StartScreen.queue_free()
	var game = preload("res://prototype/boom_spin.tscn").instantiate()
	add_child(game)
