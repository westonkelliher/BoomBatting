extends Node2D

var score = 0

func add_score():
	score += 1
	$Number.text = str(score)
