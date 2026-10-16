extends TextureButton
class_name AnimatedTextureButton
##Like button but with hover animation


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	offset_transform_enabled=true
	mouse_entered.connect(onHoverAnim)
	mouse_exited.connect(unHoverAnim)
	focus_entered.connect(onHoverAnim)
	focus_exited.connect(unHoverAnim)
	
func onHoverAnim()->void:
	var Anim:=create_tween()
	Anim.tween_property(self, "offset_transform_scale", Vector2.ONE*1.2, 0.2)

func unHoverAnim()->void:
	if (get_viewport().gui_get_focus_owner()==self) or is_hovered():
		return
	var Anim:=create_tween()
	Anim.tween_property(self, "offset_transform_scale", Vector2.ONE, 0.2)
