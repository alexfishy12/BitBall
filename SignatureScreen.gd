extends Node

@export var time_before_fade_in = 0.5
@export var following_scene: PackedScene

var timer = Timer.new()

func _ready():
	timer.set_wait_time(time_before_fade_in)
	timer.set_one_shot(true)
	self.add_child(timer)
	timer.start()
	await timer.timeout
	fade_in()
	
func fade_in():
	$AnimationPlayer.play("fade_in")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "fade_in":
		$SignatureSound.play()
	elif anim_name == "fade_out":
# warning-ignore:return_value_discarded
		get_tree().change_scene_to_packed(following_scene)


func _on_SignatureSound_finished():
	$AnimationPlayer.play("fade_out")
