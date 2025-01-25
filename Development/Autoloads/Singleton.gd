extends Node


@export_category("Scenes")
@export var main_menu: PackedScene
@export var GameScene: PackedScene

var blue_wins: int = 0
var red_wins: int = 0
var game_is_paused: bool = false

func initialize_game(game_type: String):
	var game_scene = GameScene.instantiate()
	game_scene.game_type = game_type
	
	get_tree().root.add_child(game_scene)
	
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()
	get_tree().current_scene = game_scene
	
func add_win_score(player: String):
	if player == "blue":
		blue_wins += 1
	if player == "red":
		red_wins += 1
		
func leave_game():
	blue_wins = 0
	red_wins = 0
	game_is_paused = false
	get_tree().change_scene_to_packed(main_menu)

func toggle_pause():
	game_is_paused = !game_is_paused
	
func is_game_paused():
	return game_is_paused
