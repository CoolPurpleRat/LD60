extends Node3D

@onready var animationPlayerRef: AnimationPlayer = %AnimationPlayer2

@export var vinesToBurn:int=1
var vinesBorn:=0

func open()->void:
	vinesBorn+=1
	if vinesBorn==vinesToBurn:
		animationPlayerRef.play(&"Open")
		MusicSystem.playSfx(%DoorOpen, 0.4, 0.8)
	else:
		return
