extends TextureButton

@export var menu:TabContainer
func _ready() -> void:
	visible=false

func _on_pressed() -> void:
	menu.current_tab=0

func _on_menu_switcher_tab_changed(tab: int) -> void:
	if not tab==0:
		visible=true
	else:
		visible=false
