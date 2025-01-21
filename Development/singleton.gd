extends Node

var blue_wins: int = 0
var red_wins: int = 0
var main_menu = preload("res://main_menu.tscn")

func add_win_score(player: String):
	if player == "blue":
		blue_wins += 1
	if player == "red":
		red_wins += 1
		
func leave_game():
	blue_wins = 0
	red_wins = 0
	get_tree().change_scene_to_packed(main_menu)
