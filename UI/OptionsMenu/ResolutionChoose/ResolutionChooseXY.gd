extends SpinBox

func _onFocusEntered() -> void:
	get_line_edit().grab_focus()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		return
	if get_line_edit().has_focus():
		if event.is_action_pressed("ui_up"):
			value+=step
		elif event.is_action_pressed("ui_down"):
			value-=step
		elif event.is_action_pressed("ui_left")\
		or event.is_action_pressed("ui_focus_prev"):
			get_node(focus_previous).grab_focus()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_right")\
		or event.is_action_pressed("ui_focus_next"):
			get_node(focus_next).grab_focus()
			get_viewport().set_input_as_handled()
		get_viewport().set_input_as_handled()
