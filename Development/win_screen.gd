extends Control

@export var unchecked_box: Resource
@export var checked_box: Resource
@export var player_1_checkbox: Node
@export var player_2_checkbox: Node
@export var checkbox_container: Node
@export var player_1_wins: Node
@export var player_2_wins: Node

func blue_wins():
	$AnimationPlayer.play("blue_wins")
	
func red_wins():
	$AnimationPlayer.play("red_wins")

func check_player_1():
	player_1_checkbox.texture = checked_box
	
func check_player_2():
	player_2_checkbox.texture = checked_box

func hide_checkboxes():
	checkbox_container.hide()
	
func update_win_label():
	player_1_wins.text = str(Singleton.blue_wins)
	player_2_wins.text = str(Singleton.red_wins)
