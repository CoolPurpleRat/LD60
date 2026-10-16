@icon("res://DialogueManager/SpeachBubble.png")
extends Control

@onready var _popUpTemplateRef: RichTextLabel = %PopUp
@onready var _popUpListRef: VBoxContainer = %PopUpList

##Summons temporal pop up in corner of screen 
func popUp(userText:String, duration:float=5) -> void:
	var popUpRef:RichTextLabel=_popUpTemplateRef.duplicate()
	
	popUpRef.text=userText
	var popUpTweener:=create_tween()

	popUpRef.offset_transform_position=Vector2(0, 20)
	popUpTweener.tween_property(popUpRef, "offset_transform_position", Vector2.ZERO, 0.5)
	popUpTweener.tween_property(popUpRef, "modulate", Color(0.0, 0.0, 0.0, 0.2), duration)
	popUpTweener.finished.connect(func()->void:popUpRef.queue_free())
	
	_popUpListRef.add_child(popUpRef)
