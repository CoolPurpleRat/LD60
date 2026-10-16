extends "res://DialogueManager/Character/Character.gd"

@onready var _portraitAnimRef: AnimationPlayer = %PortraitAnim
@onready var _talkingAnimRef: AnimationPlayer = %TalkingAnim

func changePortrait(portrait:StringName)->void:
	if not _portraitAnimRef.has_animation(portrait):
		push_error(name+" dont has portrait animation "+portrait)
		return
	_portraitAnimRef.play(portrait)

func talkAnim(isTalking:bool)->void:
	if isTalking:
		_talkingAnimRef.play(&"Talk")
	else:
		_talkingAnimRef.play(&"NoTalk")

func flipChar()->void:
	var scaleTweener:=create_tween()
	scaleTweener.tween_property(self, "scale", Vector2(scale.x*-1, scale.y), 0.2)
	_isFlipped=not _isFlipped

func unflip()->void:
	if _isFlipped:
		scale.x*=-1
		_isFlipped=false
