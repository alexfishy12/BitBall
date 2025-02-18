extends CanvasLayer

signal transitioned_in()
signal transitioned_out()

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var loading_label: Label = $MarginContainer/LoadingLabel

@export_category("Scenes")
@export var MainMenuScene: PackedScene
@export var GameScene: PackedScene

var current_scene: Node = null

func _ready():
	load_main_menu()

func transition_out() -> void:
	animation_player.play("fade_out")
	
func transition_in() -> void:
	animation_player.play("fade_in")

func transition_to(new_scene: Node) -> void:
	transition_out()
	await transitioned_out

	var root: Window = get_tree().get_root()
	
	if current_scene:
		current_scene.free()
	root.add_child(new_scene)
	
	new_scene.load_scene()
	await new_scene.loaded
	
	transition_in()
	await transitioned_in
	
	new_scene.activate()
	current_scene = new_scene

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print(anim_name + " finished...")
	if anim_name == "fade_out":
		transitioned_out.emit()
	elif anim_name == "fade_in":
		transitioned_in.emit()

func load_game(game_type: String):
	var game_scene = GameScene.instantiate()
	game_scene.game_type = game_type
	transition_to(game_scene)
	
func load_main_menu():
	var main_menu = MainMenuScene.instantiate()
	transition_to(main_menu)
