extends AnimatedButton

@export var focusEscapeRef:Control
@onready var changelogRef:RichTextLabel=%Changelog

func _ready() -> void:
	super()
	changelogRef.visible=false
	await get_tree().physics_frame

func _onPressed() -> void:
	changelogRef.grab_focus()
	changelogRef.visible=true 	
	changelogRef.offset_transform_scale=Vector2.ZERO
	var animTween:=create_tween()
	animTween.tween_property(changelogRef, "offset_transform_scale", Vector2.ONE, 0.5)


func _onCloseChangelogPressed() -> void:
	var animTween:=create_tween()
	animTween.tween_property(changelogRef, "offset_transform_scale", Vector2.ZERO, 0.5)
	animTween.finished.connect(func()->void:changelogRef.visible=false)
	if focusEscapeRef:
		focusEscapeRef.grab_focus()
