extends CanvasLayer

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name=="Won!":
		get_tree().change_scene_to_file("res://UI/MainMenu/MainMenu.tscn")
		Input.set_mouse_mode(Input.MouseMode.MOUSE_MODE_VISIBLE)

func playAnim()->void:
	$AnimationPlayer.play(&"Won!")
