@icon("res://DialogueManager/SpeachBubble.png")
extends Control
class_name DialogueCharacter

##Name for code references. Do not translate
@export var charName:StringName
##Small sound when character talk
@export var talkSound:AudioStream

@onready var talkSFXPlayerRef: AudioStreamPlayer2D = %TalkSFX

var _isFlipped:=false

func changePortrait(_portrait:StringName)->void:
	pass

func talkAnim(_isTalking:bool)->void:
	pass

##Flip character portrait horizontaly
func flipChar()->void:
	pass
	
func unflip()->void:
	pass

func _ready() -> void:
	#replaces sound with own
	_isFlipped=false
	if talkSound:
		var player:=talkSFXPlayerRef.stream as AudioStreamRandomizer
		player.remove_stream(0)
		player.add_stream(0,talkSound)
